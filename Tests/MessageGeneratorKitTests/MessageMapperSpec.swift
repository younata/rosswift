import Quick
import Nimble

@testable import MessageGeneratorKit

final class DictionaryMessageMapperSpec: QuickSpec {
    override func spec() {
        var subject: DictionaryMessageMapper!

        beforeEach {
            subject = DictionaryMessageMapper(mappings: [
                "foo": try! Message(name: "bar", fields: []),
                "baz": try! Message(name: "qux", fields: [])
            ])
        }

        describe("map(type:)") {
            it("returns the given mapping, if it exists") {
                expect { return try subject.map(type: "foo") }.to(equal(try! Message(name: "bar", fields: [])))
                expect { return try subject.map(type: "baz") }.to(equal(try! Message(name: "qux", fields: [])))
            }

            it("throws if a mapping is not found") {
                expect { return try subject.map(type: "whatever") }.to(throwError(MessageMapperError.noSuchType("whatever")))
            }
        }
    }
}

final class ComposedMessageMapperSpec: QuickSpec {
    override func spec() {
        var subject: ComposedMessageMapper!

        beforeEach {
            let mapper1 = DictionaryMessageMapper(mappings: [
                "foo": try! Message(name: "bar", fields: []),
                "snth": try! Message(name: "aoeu", fields: [])
            ])
            let mapper2 = DictionaryMessageMapper(mappings: [
                "baz": try! Message(name: "qux", fields: []),
                "foo": try! Message(name: "baz", fields: [])
            ])

            subject = ComposedMessageMapper(mappers: [mapper1, mapper2])
        }

        describe("map(type:)") {
            it("returns the given mapping, if it exists") {
                expect { return try subject.map(type: "snth") }.to(equal(try! Message(name: "aoeu", fields: [])))
                expect { return try subject.map(type: "baz") }.to(equal(try! Message(name: "qux", fields: [])))
            }

            it("prefers the first mapping found over the last one") {
                expect { return try subject.map(type: "foo") }.to(equal(try! Message(name: "bar", fields: [])))
                expect { return try subject.map(type: "foo") }.to(equal(try! Message(name: "bar", fields: [])))
            }

            it("throws if a mapping is not found in any of the mappers") {
                expect { return try subject.map(type: "whatever") }.to(throwError(MessageMapperError.noSuchType("whatever")))
            }
        }
    }
}

final class DynamicMessageMapperSpec: QuickSpec {
    override func spec() {
        var subject: DynamicMessageMapper!
        var shell: FakeShell!
        var messageParser: MessageParser!

        beforeEach {
            shell = FakeShell()
            let composedMessageMapper = ComposedMessageMapper(mappers: [BuiltInMessageMapper()])
            messageParser = RosMessageParser(messageMapper: composedMessageMapper)
            subject = DynamicMessageMapper(rosEnvironment: "/opt/ros/melodic", shell: shell, messageParser: messageParser)
            composedMessageMapper.mappers.append(subject)
        }

        describe("map(type:)") {
            describe("for a type that only depends on base types") {
                let type = "foo"
                let definition = """
[source/foo]:
int16 location
string whatever
""".trimmingCharacters(in: .whitespacesAndNewlines)
                let message = try! Message(name: type, fields: [
                    MessageField(name: "location", type: .scalar(try! Message(name: "int16", fields: []))),
                    MessageField(name: "whatever", type: .scalar(try! Message(name: "string", fields: [])))
                    ])

                var receivedMessage: Message?

                beforeEach {
                    shell.runReturns = { _ in definition }
                    receivedMessage = nil

                    do {
                        receivedMessage = try subject.map(type: type)
                    } catch let error {
                        fail("Expected to not throw an error, got \(error)")
                    }
                }

                it("converts what rosmsg returns into a message format") {
                    expect(receivedMessage).to(equal(message))
                }

                it("asks rosmsg on the given environment for the definition of the given message") {
                    expect(shell.runCalls).to(haveCount(1))
                    expect(shell.runCalls.last?.command).to(equal("/opt/ros/melodic/bin/rosmsg"))
                    expect(shell.runCalls.last?.arguments).to(equal(["show", type]))
                }

                describe("asking for the same type twice") {
                    var secondMessage: Message?

                    beforeEach {
                        secondMessage = nil
                        do {
                            secondMessage = try subject.map(type: type)
                        } catch let error {
                            fail("Expected to not throw an error, got \(error)")
                        }
                    }

                    it("returns the same result") {
                        expect(secondMessage).to(equal(receivedMessage))
                    }

                    it("does not ask rosmsg again (it caches the previous result)") {
                        expect(shell.runCalls).to(haveCount(1))
                    }
                }
            }

            describe("for a type that depends on other non-base types") {
                let definitions = [
                    "foo": "[]:\nbar whatever",
                    "bar": "[]:\nint32 a"
                ]

                var receivedMessage: Message?
                beforeEach {
                    shell.runReturns = { call in return definitions[call.arguments.last!]! }

                    receivedMessage = nil

                    do {
                        receivedMessage = try subject.map(type: "foo")
                    } catch let error {
                        fail("Expected to not throw an error, got \(error)")
                    }
                }

                let barMessage = try! Message(name: "bar", fields: [
                    MessageField(name: "a", type: .scalar(try! Message(name: "int32", fields: [])))
                ])
                let fooMessage = try! Message(name: "foo", fields: [
                    MessageField(name: "whatever", type: .scalar(barMessage))
                ])

                it("converts what rosmsg returns into a message format") {
                    expect(receivedMessage).to(equal(fooMessage))
                }

                it("asks rosmsg on the given environment for the definition of the given message and it's dependencies") {
                    expect(shell.runCalls).to(haveCount(2))
                    expect(shell.runCalls.first?.command).to(equal("/opt/ros/melodic/bin/rosmsg"))
                    expect(shell.runCalls.first?.arguments).to(equal(["show", "foo"]))

                    expect(shell.runCalls.last?.command).to(equal("/opt/ros/melodic/bin/rosmsg"))
                    expect(shell.runCalls.last?.arguments).to(equal(["show", "bar"]))
                }

                it("caches the results for the given message") {
                    expect { return try subject.map(type: "foo") }.to(equal(fooMessage))
                    expect(shell.runCalls).to(haveCount(2))
                }

                it("caches the results for any of the dependencies") {
                    expect { return try subject.map(type: "bar") }.to(equal(barMessage))
                    expect(shell.runCalls).to(haveCount(2))
                }
            }

            describe("for a recursive message") {
                let definitions = [
                    "foo": "[]\nbar name1",
                    "bar": "[]\nfoo name2"
                ]

                beforeEach {
                    shell.runReturns = { call in return definitions[call.arguments.last!]! }
                }

                it("throws an error complaining about the recursion") {
                    expect { return try subject.map(type: "foo") }.to(throwError(MessageMapperError.recursiveMessageDefinition("foo", ["foo", "bar"])))
                }
            }
        }
    }
}
