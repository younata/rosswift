public protocol Node {
    func subscribe<T: RosMessage>(topic: String, callback: (T) -> Void)
    func publisher<T: RosMessage>(topic: String) -> Publisher<T>
}

public struct Publisher<T: RosMessage> {
    public let topic: String

    public func publish(_ message: T) {}
}

struct RosNode: Node {
    func subscribe<T: RosMessage>(topic: String, callback: (T) -> Void) {
    }

    func publisher<T: RosMessage>(topic: String) -> Publisher<T> {
        return Publisher<T>(topic: topic)
    }
}
