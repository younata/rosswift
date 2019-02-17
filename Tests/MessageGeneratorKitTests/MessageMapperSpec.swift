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
