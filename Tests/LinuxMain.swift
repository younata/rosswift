import XCTest
import Quick

import RosTests
@testable import MessageGeneratorKitTests

var tests = [XCTestCaseEntry]()
tests += RosTests.allTests()
XCTMain(tests)

QCKMain([
    RosMessageParserSpec.self,

    DictionaryMessageMapperSpec.self,
    ComposedMessageMapperSpec.self,

    StructMessageFormatterSpec.self
])
