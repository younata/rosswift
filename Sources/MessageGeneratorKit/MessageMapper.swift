import Foundation

public protocol MessageMapper {
    func map(type: String) throws -> Message
}

enum MessageMapperError: Error, Equatable {
    case noSuchType(String)
    case recursiveMessageDefinition(String, [String])

    var localizedDescription: String {
        // TODO: Actually localize this. Also, track this in a story.
        switch self {
        case .noSuchType(let type):
            return "No message definition found for \(type)"
        case .recursiveMessageDefinition(let type, let dependencies):
            let dependencyString = dependencies.joined(separator: "->")
            return "Recursive message definition for \(type) detected. \(dependencyString)"
        }
    }
}

struct DictionaryMessageMapper: MessageMapper {
    let mappings: [String: Message]

    func map(type: String) throws -> Message {
        guard let convertedType = self.mappings[type] else {
            throw MessageMapperError.noSuchType(type)
        }

        return convertedType
    }
}

final class ComposedMessageMapper: MessageMapper {
    var mappers: [MessageMapper]

    init(mappers: [MessageMapper]) {
        self.mappers = mappers
    }

    func map(type: String) throws -> Message {
        var lastError: Error?
        for mapper in self.mappers {
            do {
                return try mapper.map(type: type)
            } catch let error {
                lastError = error
            }
        }
        throw lastError ?? MessageMapperError.noSuchType(type)
    }
}

func BuiltInMessageMapper() -> DictionaryMessageMapper {
    let builtIns = builtInMessages()
    return DictionaryMessageMapper(mappings: Dictionary(uniqueKeysWithValues: zip(builtIns.map { $0.name }, builtIns)))
}

final class DynamicMessageMapper: MessageMapper {
    private var messageCache: [String: Message] = [:]
    private var messageDependencies: Array<String> = []

    let rosEnvironment: String
    let shell: Shell
    let messageParser: MessageParser

    init(rosEnvironment: String, shell: Shell, messageParser: MessageParser) {
        self.rosEnvironment = rosEnvironment
        self.shell = shell
        self.messageParser = messageParser
    }

    func map(type: String) throws -> Message {
        if let message = self.messageCache[type] {
            return message
        }

        guard !self.messageDependencies.contains(type) else {
            throw MessageMapperError.recursiveMessageDefinition(type, self.messageDependencies)
        }

        var messageLines = try shell.run(
            command: "\(self.rosEnvironment)/bin/rosmsg",
            arguments: ["show", type]
        ).split(separator: "\n")
        messageLines.removeFirst()
        let messageDefinition = messageLines.joined(separator: "\n")


        self.messageDependencies.append(type)
        let message = try self.messageParser.parse(name: type, contents: messageDefinition)
        self.messageDependencies.removeAll { $0 == type }
        self.messageCache[type] = message
        return message
    }
}
