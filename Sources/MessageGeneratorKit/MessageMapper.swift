import Foundation

public protocol MessageMapper {
    func map(type: String) throws -> Message
}

enum MessageMapperError: Error, Equatable {
    case noSuchType(String)
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

struct ComposedMessageMapper: MessageMapper {
    let mappers: [MessageMapper]

    func map(type: String) throws -> Message {
        for mapper in self.mappers {
            if let type = try? mapper.map(type: type) {
                return type
            }
        }
        throw MessageMapperError.noSuchType(type)
    }
}

func BuiltInMessageMapper() -> MessageMapper {
    let builtIns = builtInMessages()
    return DictionaryMessageMapper(mappings: Dictionary(uniqueKeysWithValues: zip(builtIns.map { $0.name }, builtIns)))
}
