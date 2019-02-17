import Foundation

public protocol MessageParser {
    func parse(name: String, contents: String) throws -> Message
}

struct RosMessageParser: MessageParser {
    let messageMapper: MessageMapper

    func parse(name: String, contents: String) throws -> Message {
        guard name.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: nil) == nil else {
            throw RosMessageError.invalidName(name)
        }

        let fieldsList: [(String, String)] = try contents.split(separator: "\n").map { str -> String in
            guard let index = str.firstIndex(of: "#") else {
                return String(str)
            }
            return String(str[..<index])
            }.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { fieldLine in
                let contents = fieldLine.split(separator: " ")
                guard contents.count == 2 else {
                    throw RosMessageError.invalidVariableDeclaration(fieldLine)
                }
                let type = String(contents[0])
                let variableName = String(contents[1])
                return (variableName, type)
            }

        guard !fieldsList.isEmpty else {
            throw RosMessageError.noFields
        }

        return try Message(name: name, fields: try self.convert(fields: fieldsList))
    }

    private func convert(fields: [(String, String)]) throws -> [MessageField] {
        return try fields.map { (arg) -> MessageField in

            let (name, type) = arg
            return MessageField(name: name, type: try self.handleArraySyntax(type: type))
        }
    }

    private func handleArraySyntax(type: String) throws -> MessageType {
        if type.hasSuffix("[]") {
            let index = type.index(before: type.index(before: type.endIndex))
            return MessageType.array(try self.messageMapper.map(type: String(type[..<index])))
        }
        return MessageType.scalar(try self.messageMapper.map(type: type))
    }
}
