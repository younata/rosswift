import Quick
import Nimble
import Foundation

@testable import MessageGeneratorKit

final class RosMessageParserSpec: QuickSpec {
    override func spec() {
        var subject: RosMessageParser!

        beforeEach {
            subject = RosMessageParser(messageMapper: BuiltInMessageMapper())
        }

        describe("parse(name:contents:)") {
            describe("when the given message is composed of primitives") {
                let message = """
# ignore this comment

int16 variable_name
string other_variable_name
int32[] array_of_stuff
"""
                it("generates a struct of the message") {
                    let expectedMessage = try! Message(name: "MyCustomMessage", fields: [
                        MessageField(name: "variable_name", type: .scalar(try! Message(name: "int16", fields: []))),
                        MessageField(name: "other_variable_name", type: .scalar(try! Message(name: "string", fields: []))),
                        MessageField(name: "array_of_stuff", type: .array(try! Message(name: "int32", fields: [])))
                    ])
                    expect { return try subject.parse(name: "MyCustomMessage", contents: message) }.to(equal(expectedMessage))
                }
            }

            describe("when the given message is invalid") {
                it("throws an error if no fields are given") {
                    let message = ""
                    expect { try subject.parse(name: "NoFields", contents: message)}
                        .to(throwError(RosMessageError.noFields))
                }

                it("throws an error if the message name has spaces") {
                    let message = "int16 foo"
                    expect { try subject.parse(name: "has spaces", contents: message)}
                        .to(throwError(RosMessageError.invalidName("has spaces")))
                }

                it("throws an error if a variable declaration has too much going on") {
                    let message = "int16 foo bar"
                    expect { try subject.parse(name: "message", contents: message)}
                        .to(throwError(RosMessageError.invalidVariableDeclaration("int16 foo bar")))
                }

                it("throws an error if a variable declaration has too little going on") {
                    let message = "int16"
                    expect { try subject.parse(name: "message", contents: message)}
                        .to(throwError(RosMessageError.invalidVariableDeclaration("int16")))
                }

                it("throws an error if two variables have the same name") {
                    let message = "int16 foo\nstring foo"
                    expect { try subject.parse(name: "message", contents: message)}
                        .to(throwError(RosMessageError.duplicateVariables(["int16 foo", "string foo"])))
                }

                it("throws an error if two variables have the same name and same type") {
                    let message = "int16 foo\nint16 foo"
                    expect { try subject.parse(name: "message", contents: message)}
                        .to(throwError(RosMessageError.duplicateVariables(["int16 foo", "int16 foo"])))
                }
            }
        }
    }
}
