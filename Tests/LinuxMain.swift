import XCTest

@testable import RosTests
@testable import MessageGeneratorKitTests

let messageGeneratorTests: [QuickSpec.self] = [
    StructMessageFormatterSpec.self, // MessageFormatterSpec

    DictionaryMessageMapperSpec.self, // MessageMapperSpec
    ComposedMessageMapperSpec.self, // MessageMapperSpec
    DynamicMessageMapperSpec.self, // MessageMapperSpec

    RosMessageParserSpec.self, // MessageParserSpec

    ProcessShellSpec.self, // ShellSpec

    RosOracleSpec.self, // OracleSpec
    FileManagerDirectoryAnalyzerSpec.self // OracleSpec
]

let rosTests: [QuickSpec.self] = [
    RosMessageDecoderSpec.self, // RosMessageDecoderSpec
    RosNodeSpec.self // NodeSpec
]

QCKMain(messageGeneratorTests + rosTests)
