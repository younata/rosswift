import Foundation

public protocol RosMessage: Codable, Equatable {
    static var fields: [CodingKey] { get }
    static var definition: String { get }
}

struct Packet<T: RosMessage>: Equatable, Codable {
    let messageDefinition: String
    let callerid: String
    let latching: String
    let md5sum: String
    let topic: String
    let messageType: String
    let message: T
}

struct RosDecoder {
    enum Error: Swift.Error {
        case whatever
    }

    func decode<T: RosMessage>(data: Data, of type: T.Type) throws -> Packet<T> {
        throw Error.whatever
    }
}
