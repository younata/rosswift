import Foundation

public enum RosEnvironmentError: Error {
    case noneFound

    public var localizedDescription: String {
        switch self {
        case .noneFound:
            return "No ROS installation detected (/opt/ros is empty or does not exist)"
        }
    }
}

public protocol Oracle {
    func parser(rosEnvironment: String?) throws -> MessageParser
    func formatter() -> MessageFormatter
    func messageName(path: String) -> String
}

protocol DirectoryAnalyzer {
    func contentsOfDirectory(at path: String) throws -> [String]
}

extension FileManager: DirectoryAnalyzer {
    func contentsOfDirectory(at path: String) throws -> [String] {
        return try self.contentsOfDirectory(atPath: path)
    }
}

struct RosOracle: Oracle {
    let directoryAnalyzer: DirectoryAnalyzer

    func parser(rosEnvironment: String?) throws -> MessageParser {
        let installation = try rosEnvironment.unwrap(fallback: self.defaultRosEnvironment)

        let composedMapper = ComposedMessageMapper(mappers: [BuiltInMessageMapper()])

        let parser = RosMessageParser(messageMapper: composedMapper)
        let dynamicMapper = DynamicMessageMapper(rosEnvironment: installation, shell: ProcessShell(), messageParser: parser)

        composedMapper.mappers.append(dynamicMapper)

        return parser
    }

    func formatter() -> MessageFormatter {
        return StructMessageFormatter()
    }

    func messageName(path: String) -> String {
        return URL(fileURLWithPath: path, isDirectory: false).deletingPathExtension().lastPathComponent
    }

    private func defaultRosEnvironment() throws -> String {
        let directory = "/opt/ros"
        guard let latestInstall = try self.directoryAnalyzer.contentsOfDirectory(at: directory).sorted().last else {
            throw RosEnvironmentError.noneFound
        }
        return URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(latestInstall).path
    }
}

extension Optional {
    fileprivate func unwrap(fallback: () throws -> Wrapped) throws -> Wrapped {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .none:
            return try fallback()
        }
    }
}
