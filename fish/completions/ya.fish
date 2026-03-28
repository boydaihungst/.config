# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_ya_global_optspecs
	string join \n V/version h/help
end

function __fish_ya_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_ya_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_ya_using_subcommand
	set -l cmd (__fish_ya_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c ya -n "__fish_ya_needs_command" -s V -l version -d 'Print version'
complete -c ya -n "__fish_ya_needs_command" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_needs_command" -f -a "emit" -d 'Emit an action to be executed by the current instance'
complete -c ya -n "__fish_ya_needs_command" -f -a "emit-to" -d 'Emit an action to be executed by the specified instance'
complete -c ya -n "__fish_ya_needs_command" -f -a "exec" -d 'Execute an action on the current instance and print its result'
complete -c ya -n "__fish_ya_needs_command" -f -a "pkg" -d 'Manage packages'
complete -c ya -n "__fish_ya_needs_command" -f -a "pub" -d 'Publish a message to the current instance'
complete -c ya -n "__fish_ya_needs_command" -f -a "pub-to" -d 'Publish a message to the specified instance'
complete -c ya -n "__fish_ya_needs_command" -f -a "sub" -d 'Subscribe to messages from all remote instances'
complete -c ya -n "__fish_ya_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c ya -n "__fish_ya_using_subcommand emit" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand emit-to" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand exec" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "add" -d 'Add packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "delete" -d 'Delete packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "install" -d 'Install all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "list" -d 'List all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "upgrade" -d 'Upgrade all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and not __fish_seen_subcommand_from add delete install list upgrade help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from delete" -l discard -d 'Discard local changes made to packages while deleting'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from delete" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from install" -l discard -d 'Discard local changes made to packages while installing'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from upgrade" -l discard -d 'Discard local changes made to packages while upgrading'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from upgrade" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "add" -d 'Add packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "delete" -d 'Delete packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "install" -d 'Install all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "list" -d 'List all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "upgrade" -d 'Upgrade all packages'
complete -c ya -n "__fish_ya_using_subcommand pkg; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c ya -n "__fish_ya_using_subcommand pub" -l str -d 'Send the message with a string body' -r
complete -c ya -n "__fish_ya_using_subcommand pub" -l json -d 'Send the message with a JSON body' -r
complete -c ya -n "__fish_ya_using_subcommand pub" -l list -d 'Send the message as a list of strings' -r
complete -c ya -n "__fish_ya_using_subcommand pub" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand pub-to" -l str -d 'Send the message with a string body' -r
complete -c ya -n "__fish_ya_using_subcommand pub-to" -l json -d 'Send the message with a JSON body' -r
complete -c ya -n "__fish_ya_using_subcommand pub-to" -l list -d 'Send the message as a list of strings' -r
complete -c ya -n "__fish_ya_using_subcommand pub-to" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand sub" -s h -l help -d 'Print help'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "emit" -d 'Emit an action to be executed by the current instance'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "emit-to" -d 'Emit an action to be executed by the specified instance'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "exec" -d 'Execute an action on the current instance and print its result'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "pkg" -d 'Manage packages'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "pub" -d 'Publish a message to the current instance'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "pub-to" -d 'Publish a message to the specified instance'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "sub" -d 'Subscribe to messages from all remote instances'
complete -c ya -n "__fish_ya_using_subcommand help; and not __fish_seen_subcommand_from emit emit-to exec pkg pub pub-to sub help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c ya -n "__fish_ya_using_subcommand help; and __fish_seen_subcommand_from pkg" -f -a "add" -d 'Add packages'
complete -c ya -n "__fish_ya_using_subcommand help; and __fish_seen_subcommand_from pkg" -f -a "delete" -d 'Delete packages'
complete -c ya -n "__fish_ya_using_subcommand help; and __fish_seen_subcommand_from pkg" -f -a "install" -d 'Install all packages'
complete -c ya -n "__fish_ya_using_subcommand help; and __fish_seen_subcommand_from pkg" -f -a "list" -d 'List all packages'
complete -c ya -n "__fish_ya_using_subcommand help; and __fish_seen_subcommand_from pkg" -f -a "upgrade" -d 'Upgrade all packages'
