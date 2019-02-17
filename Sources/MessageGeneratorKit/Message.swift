enum RosMessageError: Error, Equatable {
    case invalidName(String)
    case noFields
    case invalidVariableDeclaration(String)
    case duplicateVariables([String])
}

public struct Message: Equatable, CustomDebugStringConvertible {
    public let name: String
    public let fields: [MessageField]

    fileprivate init(name: String) {
        self.name = name
        self.fields = []
    }

    public init(name: String, fields: [MessageField]) throws {
        guard name.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: nil) == nil else {
            throw RosMessageError.invalidName(name)
        }
        try verifyFields(fields: fields)
        self.name = name
        self.fields = fields
    }

    public var debugDescription: String {
        let fieldsString = fields.map { field -> String in field.debugDescription }.joined(separator: " ")
        return "<\(self.name) \(fieldsString)/>"
    }
}

public enum MessageType: Equatable, CustomDebugStringConvertible {
    case scalar(Message)
    case array(Message)

    public var name: String {
        return self.message.name
    }

    public var debugDescription: String {
        switch self {
        case .scalar(let message):
            return message.name
        case .array(let message):
            return "Array<\(message.name)>"
        }
    }

    public var message: Message {
        switch self {
        case .scalar(let message):
            return message
        case .array(let message):
            return message
        }
    }
}

public struct MessageField: Equatable, CustomDebugStringConvertible {
    public let name: String
    public let type: MessageType

    public var debugDescription: String {
        return "\(name)=\"\(type.debugDescription)\""
    }
}

func builtInMessages() -> [Message] {
    return [
        Message(name: "bool"),
        Message(name: "int8"),
        Message(name: "uint8"),
        Message(name: "int16"),
        Message(name: "uint16"),
        Message(name: "int32"),
        Message(name: "uint32"),
        Message(name: "int64"),
        Message(name: "uint64"),
        Message(name: "float32"),
        Message(name: "float64"),
        Message(name: "string"),
        Message(name: "time"),
        Message(name: "duration")
    ]
}

private func verifyFields(fields: [MessageField]) throws {
    var items = Dictionary<String, String>(minimumCapacity: fields.count)
    var duplicateFields: [String] = []
    for field in fields {
        guard items[field.name] == nil else {
            let fieldContent = "\(field.type.name) \(field.name)"
            if !duplicateFields.contains(fieldContent) {
                let existingContent = "\(items[field.name]!) \(field.name)"
                duplicateFields.append(existingContent)
            }
            duplicateFields.append(fieldContent)
            continue
        }
        items[field.name] = field.type.name
    }
    guard duplicateFields.isEmpty else {
        throw RosMessageError.duplicateVariables(duplicateFields)
    }
}
