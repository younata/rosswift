protocol MessageFormatter {
    func string(message: Message) -> String
}

struct StructMessageFormatter: MessageFormatter {
    func string(message: Message) -> String {
        let fields = message.fields.map { (field: MessageField) -> String in
            return "    var \(field.name): \(self.format(rosField: field.type))"
        }.joined(separator: "\n")
        return "struct \(message.name): RosMessage {\n\(fields)\n}"
    }

    private func format(rosField: MessageType) -> String {
        let name = self.convertBuiltInType(field: rosField.name)
        switch rosField {
        case .scalar:
            return name
        case .array:
            return "[\(name)]"
        }
    }

    private func convertBuiltInType(field: String) -> String {
        let builtInTypes = [
            "bool": "Bool",
            "int8": "Int8",
            "uint8": "UInt8",
            "int16": "Int16",
            "uint16": "UInt16",
            "int32": "Int32",
            "uint32": "UInt32",
            "int64": "Int64",
            "uint64": "UInt64",
            "float32": "Float",
            "float64": "Double",
            "string": "String",
            "time": "UInt32",
            "duration": "Int32"
        ]

        return builtInTypes[field] ?? field
    }
}
