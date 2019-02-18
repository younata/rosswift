import Quick
import Nimble
import Foundation

@testable import Ros

final class RosNodeSpec: QuickSpec {
    override func spec() {
        var subject: RosNode!

        beforeEach {
            subject = RosNode()
        }

        describe("subscribe(topic:callback:)") {
            describe("happy path") {
                var subscribeCalls: [String] = []
                beforeEach {
                    subscribeCalls = []

                    subject.subscribe(topic: "/foo") { (str: String) in
                        subscribeCalls.append(str)
                    }
                }
            }
        }

        describe("publisher(topic:)") {

        }
    }
}

/*
 Subscribe
  - Does the handshake to subscribe
  - Sets up socket to communicate messages.
  - receives packets
  - decodes packet
  - issues callback with only message part of callback.
  - What do if packet is bad?
 */
