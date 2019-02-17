import Foundation

public enum ShellError: Error {
    case fatal(Int, String, String)
    case badOS(String)
}

public protocol Shell {
    func run(command: String, arguments: [String]) throws -> String
}

struct ProcessShell: Shell {
    public func run(command: String, arguments: [String]) throws -> String {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments

        let output = Pipe()
        let error = Pipe()

        process.standardOutput = output
        process.standardError = error


        #if os(OSX)
        guard #available(OSX 10.13, *) else { throw ShellError.badOS("Uses APIs unavailable on OS X 10.12 or earlier (before High Sierra)") }
        try process.run()
        #else
        try process.run()
        #endif

        process.waitUntilExit()

        let stdout = String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            throw ShellError.fatal(Int(process.terminationStatus), stdout, stderr)
        }

        return stdout
    }
}
