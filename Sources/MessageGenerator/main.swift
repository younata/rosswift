import MessageGeneratorKit
import Foundation
import Utility

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

func main() -> Int32 {
    // The first argument is always the executable, drop it
    let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

    let parser = ArgumentParser(usage: "<options>", overview: "Generates Swift code from ROS message files")

    let rosEnv: OptionArgument<PathArgument> = parser.add(
        option: "--rosenv",
        shortName: "-e",
        kind: PathArgument.self,
        usage: "Path to the ros environment to use",
        completion: .filename
    )

    let path: PositionalArgument<PathArgument> = parser.add(
        positional: "message_file",
        kind: PathArgument.self,
        optional: true,
        usage: "ROS Message file to parse, uses alphabatically last ros environment installed if not specified",
        completion: .filename
    )

    var standardError = FileHandle.standardError

    do {
        let parsedArguments = try parser.parse(arguments)

        guard let messagePath = parsedArguments.get(path) else {
            print("Error: No message given to parse", to: &standardError)
            return 1
        }

        let rosEnvironment = parsedArguments.get(rosEnv)

        print(try generate(
            messageLocation: messagePath.path.asString,
            rosEnvironment: rosEnvironment?.path.asString
        ))
    }
    catch let error as ArgumentParserError {
        print(error.description)
        return 1
    }
    catch let error {
        print(error.localizedDescription, to: &standardError)
        return 1
    }
    return 0
}

exit(main())
