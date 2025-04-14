use Command.{Arg, Flag, Option};


enum Command {
    case Arg({value = String})
    case Flag({name = String})
    case Option({name = String, value = String})
}

instance ToString[Command] {
    pub def toString(command: Command): String =
        match command {
            case Arg({value}) => "arg: ${value}"
            case Flag({name}) => "flag: ${name}"
            case Option({name, value}) => "option: ${name}=${value}"
        }
}

def getCommands(): List[Command] \ {IO, Sys} = 
    let args = run {
        Environment.getArgs()
    } with Environment.runWithIO;

    region rc {
        let commands = MutList.empty(rc);
        foreach (arg <- args) {
            let command = if (String.startsWith(prefix = "--", arg)) {
                let (name, value) = 
                    String.drop(2, arg) |>
                    String.breakOnLeft(substr = "=");

                if (value == "") {
                    Command.Flag({name = name})
                } else {
                    Command.Option({name = name, value = value |> String.drop(1)})
                }
            } else {
                Command.Arg({value = arg})
            };
            MutList.push(command, commands)
        };
        MutList.toList(commands)
    }
