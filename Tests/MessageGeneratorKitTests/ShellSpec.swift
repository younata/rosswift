import Quick
import Nimble

@testable import MessageGeneratorKit

final class ProcessShellSpec: QuickSpec {
    override func spec() {
        var subject: ProcessShell!

        beforeEach {
            subject = ProcessShell()
        }

        it("returns the standard output of the program") {
            expect { return try subject.run(command: "/bin/echo", arguments: ["hello world"]) }.to(equal("hello world\n"))
        }

        it("throws if the program exits with nonzero status") {
            expect { try subject.run(command: "/bin/bash", arguments: ["-c 'exit 1'"]) }.to(throwError(ShellError.fatal(1, "", "")))
        }
    }
}
