import Quick
import Nimble
import Foundation

@testable import MessageGeneratorKit

final class OracleSpec: QuickSpec {
    override func spec() {
        var subject: RosOracle!
        var directoryAnalyzer: FakeDirectoryAnalyzer!

        beforeEach {
            directoryAnalyzer = FakeDirectoryAnalyzer()
            subject = RosOracle(directoryAnalyzer: directoryAnalyzer)
        }

        describe("parser(rosEnvironment:)") {
            var parser: MessageParser?

            beforeEach {
                parser = nil
            }

            func assertConfiguredParser() -> DynamicMessageMapper? {
                expect(parser).toNot(beNil())
                guard parser != nil else { return nil }

                guard let rosParser = parser as? RosMessageParser else {
                    fail("too-smart test that assumes that returned parser is a RosMessageParser failed")
                    return nil
                }
                guard let composedMapper = rosParser.messageMapper as? ComposedMessageMapper else {
                    fail("too-smart test that assumes that returned parser's messageMapper is a ComposedMessageMapper failed.")
                    return nil
                }

                expect(composedMapper.mappers).to(haveCount(2))
                expect(composedMapper.mappers.first).to(beAKindOf(DictionaryMessageMapper.self))
                expect((composedMapper.mappers.first as? DictionaryMessageMapper)?.mappings).to(equal(BuiltInMessageMapper().mappings))

                expect(composedMapper.mappers.last).to(beAKindOf(DynamicMessageMapper.self))

                guard let dynamicMapper = composedMapper.mappers.last as? DynamicMessageMapper else {
                    fail("too-smart test that assumes that returned parser's ComposedMessageMapper has a DynamicMessageMapper failed.")
                    return nil
                }

                expect(dynamicMapper.shell).to(beAKindOf(ProcessShell.self))
                expect(dynamicMapper.messageParser).to(beIdenticalTo(rosParser))
                return dynamicMapper
            }

            describe("if given a non-nil rosEnvironment") {
                beforeEach {
                    do {
                        parser = try subject.parser(rosEnvironment: "/path/to/my/env")
                    } catch let parserError {
                        fail("Unexpected error \(parserError) thrown.")
                    }
                }

                it("returns a configured parser") {
                    expect(assertConfiguredParser()?.rosEnvironment).to(equal("/path/to/my/env"))
                }

                it("does not consult the directoryAnalyzer") {
                    expect(directoryAnalyzer.contentsCalls).to(beEmpty())
                }
            }

            describe("if given a nil rosEnvironment") {
                context("and no ros environments are at /opt/ros") {
                    beforeEach {
                        directoryAnalyzer.contentsReturns = { _ in return [] }
                    }

                    it("throws an error") {
                        expect { try subject.parser(rosEnvironment: nil) }.to(throwError(RosEnvironmentError.noneFound))
                    }

                    it("consults the directoryAnalyzer for the contents at /opt/ros") {
                        _ = try? subject.parser(rosEnvironment: nil)
                        expect(directoryAnalyzer.contentsCalls).to(equal(["/opt/ros"]))
                    }
                }

                context("and a multiple ros environments are found") {
                    beforeEach {
                        directoryAnalyzer.contentsReturns = { _ in return ["a", "b", "c"] }
                        do {
                            parser = try subject.parser(rosEnvironment: nil)
                        } catch let parserError {
                            fail("Unexpected error \(parserError) thrown.")
                        }
                    }

                    it("returns a configured parser, using the latest (last alphabetically) ros environment") {
                        expect(assertConfiguredParser()?.rosEnvironment).to(equal("/opt/ros/c"))
                    }

                    it("consults the directoryAnalyzer for the contents at /opt/ros") {
                        expect(directoryAnalyzer.contentsCalls).to(equal(["/opt/ros"]))
                    }
                }
            }
        }
    }
}

final class FileManagerDirectoryAnalyzerSpec: QuickSpec {
    override func spec() {
        it("does not include the directory it was given in the returned list of directories") {
            let subject: DirectoryAnalyzer = FileManager.default

            expect { return try subject.contentsOfDirectory(at: "/usr").first?.hasPrefix("/usr") }.toNot(beTrue())
        }
    }
}
