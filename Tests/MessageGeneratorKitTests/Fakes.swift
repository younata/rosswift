@testable import MessageGeneratorKit

struct ShellCall: Hashable {
    let command: String
    let arguments: [String]
}

final class FakeShell: Shell {
    var runReturns: (ShellCall) throws -> String = { _ in return "" }

    var runCalls: [ShellCall] = []
    func run(command: String, arguments: [String]) throws -> String {
        let call = ShellCall(command: command, arguments: arguments)
        self.runCalls.append(call)

        return try self.runReturns(call)
    }
}

final class FakeDirectoryAnalyzer: DirectoryAnalyzer {
    var contentsReturns: (String) throws -> [String] = { _ in return [] }
    var contentsCalls: [String] = []
    func contentsOfDirectory(at path: String) throws -> [String] {
        self.contentsCalls.append(path)
        return try self.contentsReturns(path)
    }
}
