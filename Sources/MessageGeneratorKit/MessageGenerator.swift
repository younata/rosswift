import Foundation

public func generate(messageLocation: String, rosEnvironment: String?, oracle: Oracle? = nil) throws -> String {
    let oracle = oracle ?? RosOracle(directoryAnalyzer: FileManager.default)
    let parser = try oracle.parser(rosEnvironment: rosEnvironment)
    let formatter = oracle.formatter()

    return formatter.string(message: try parser.parse(
        name: oracle.messageName(path: messageLocation),
        contents: try String(contentsOfFile: messageLocation)
    ))
}
