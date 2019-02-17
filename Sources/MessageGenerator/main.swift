import MessageGeneratorKit
import Foundation
import Utility

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

    do {
        let parsedArguments = try parser.parse(arguments)

        guard let messagePath = parsedArguments.get(path) else {
            print("Error: No message given to parse")
            return 1
        }

        let rosEnvironment = parsedArguments.get(rosEnv)

        print("Use environment if given and read message and convert it to non-message")
    }
    catch let error as ArgumentParserError {
        print(error.description)
        return 1
    }
    catch let error {
        print(error.localizedDescription)
        return 1
    }
    return 0
}

exit(main())
