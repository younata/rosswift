import Quick
import Nimble
import Foundation

@testable import MessageGeneratorKit

final class StructMessageFormatterSpec: QuickSpec {
    override func spec() {
        var subject: StructMessageFormatter!

        beforeEach {
            subject = StructMessageFormatter()
        }

        describe("string(message:)") {
            it("prints a struct representation of the message") {
                let message = try! Message(name: "MyMessage", fields: [
                    MessageField(name: "a", type: .scalar(try! Message(name: "bool", fields: []))),
                    MessageField(name: "b", type: .scalar(try! Message(name: "int8", fields: []))),
                    MessageField(name: "c", type: .scalar(try! Message(name: "uint8", fields: []))),
                    MessageField(name: "d", type: .scalar(try! Message(name: "int16", fields: []))),
                    MessageField(name: "e", type: .scalar(try! Message(name: "uint16", fields: []))),
                    MessageField(name: "f", type: .scalar(try! Message(name: "int32", fields: []))),
                    MessageField(name: "g", type: .scalar(try! Message(name: "uint32", fields: []))),
                    MessageField(name: "h", type: .scalar(try! Message(name: "int64", fields: []))),
                    MessageField(name: "i", type: .scalar(try! Message(name: "uint64", fields: []))),
                    MessageField(name: "j", type: .scalar(try! Message(name: "float32", fields: []))),
                    MessageField(name: "k", type: .scalar(try! Message(name: "float64", fields: []))),
                    MessageField(name: "l", type: .scalar(try! Message(name: "string", fields: []))),
                    MessageField(name: "m", type: .scalar(try! Message(name: "time", fields: []))),
                    MessageField(name: "n", type: .scalar(try! Message(name: "duration", fields: [])))
                ])
                let expectedStruct = """
struct MyMessage: RosMessage {
    var a: Bool
    var b: Int8
    var c: UInt8
    var d: Int16
    var e: UInt16
    var f: Int32
    var g: UInt32
    var h: Int64
    var i: UInt64
    var j: Float
    var k: Double
    var l: String
    var m: UInt32
    var n: Int32
}
""".trimmingCharacters(in: .whitespacesAndNewlines).appending("\n")
                expect(subject.string(message: message)).to(equal(expectedStruct))
            }

            it("handles arrays properly") {
                let message = try! Message(name: "MyMessage", fields: [
                    MessageField(name: "a", type: .array(try! Message(name: "bool", fields: []))),
                    MessageField(name: "b", type: .array(try! Message(name: "int8", fields: []))),
                    MessageField(name: "c", type: .array(try! Message(name: "uint8", fields: []))),
                    MessageField(name: "d", type: .array(try! Message(name: "int16", fields: []))),
                    MessageField(name: "e", type: .array(try! Message(name: "uint16", fields: []))),
                    MessageField(name: "f", type: .array(try! Message(name: "int32", fields: []))),
                    MessageField(name: "g", type: .array(try! Message(name: "uint32", fields: []))),
                    MessageField(name: "h", type: .array(try! Message(name: "int64", fields: []))),
                    MessageField(name: "i", type: .array(try! Message(name: "uint64", fields: []))),
                    MessageField(name: "j", type: .array(try! Message(name: "float32", fields: []))),
                    MessageField(name: "k", type: .array(try! Message(name: "float64", fields: []))),
                    MessageField(name: "l", type: .array(try! Message(name: "string", fields: []))),
                    MessageField(name: "m", type: .array(try! Message(name: "time", fields: []))),
                    MessageField(name: "n", type: .array(try! Message(name: "duration", fields: [])))
                    ])
                let expectedStruct = """
struct MyMessage: RosMessage {
    var a: [Bool]
    var b: [Int8]
    var c: [UInt8]
    var d: [Int16]
    var e: [UInt16]
    var f: [Int32]
    var g: [UInt32]
    var h: [Int64]
    var i: [UInt64]
    var j: [Float]
    var k: [Double]
    var l: [String]
    var m: [UInt32]
    var n: [Int32]
}
""".trimmingCharacters(in: .whitespacesAndNewlines).appending("\n")
                expect(subject.string(message: message)).to(equal(expectedStruct))
            }
        }
    }
}
