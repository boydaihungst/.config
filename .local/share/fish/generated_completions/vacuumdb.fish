# vacuumdb
# Autogenerated from man page /usr/share/man/man1/vacuumdb.1.gz
complete -c vacuumdb -o 'a
.br
--all' -d 'Vacuum all databases'
complete -c vacuumdb -l buffer-usage-limit -d 'Specifies the Buffer Access Strategy ring buffer size for a given invocation …'
complete -c vacuumdb -l disable-page-skipping -d 'Disable skipping pages based on the contents of the visibility map'
complete -c vacuumdb -o 'e
.br
--echo' -d 'Echo the commands that vacuumdb generates and sends to the server'
complete -c vacuumdb -o 'f
.br
--full' -d 'Perform "full" vacuuming'
complete -c vacuumdb -o 'F
.br
--freeze' -d 'Aggressively "freeze" tuples'
complete -c vacuumdb -l force-index-cleanup -d 'Always remove index entries pointing to dead tuples'
complete -c vacuumdb -s j -d 'Execute the vacuum or analyze commands in parallel by running njobs commands …'
complete -c vacuumdb -l min-mxid-age -d 'Only execute the vacuum or analyze commands on tables with a multixact ID age…'
complete -c vacuumdb -l min-xid-age -d 'Only execute the vacuum or analyze commands on tables with a transaction ID a…'
complete -c vacuumdb -s n -d 'Clean or analyze all tables in schema only'
complete -c vacuumdb -s N -d 'Do not clean or analyze any tables in schema'
complete -c vacuumdb -l no-index-cleanup -d 'Do not remove index entries pointing to dead tuples'
complete -c vacuumdb -l no-process-main -d 'Skip the main relation'
complete -c vacuumdb -l no-process-toast -d 'Skip the TOAST table associated with the table to vacuum, if any'
complete -c vacuumdb -l no-truncate -d 'Do not truncate empty pages at the end of the table'
complete -c vacuumdb -s P -d 'Specify the number of parallel workers for parallel vacuum'
complete -c vacuumdb -o 'q
.br
--quiet' -d 'Do not display progress messages'
complete -c vacuumdb -l skip-locked -d 'Skip relations that cannot be immediately locked for processing'
complete -c vacuumdb -s t -d 'Clean or analyze table only'
complete -c vacuumdb -o 'v
.br
--verbose' -d 'Print detailed information during processing'
complete -c vacuumdb -o 'V
.br
--version' -d 'Print the vacuumdb version and exit'
complete -c vacuumdb -o 'z
.br
--analyze' -d 'Also calculate statistics for use by the optimizer'
complete -c vacuumdb -o 'Z
.br
--analyze-only' -d 'Only calculate statistics for use by the optimizer (no vacuum)'
complete -c vacuumdb -l analyze-in-stages -d 'Only calculate statistics for use by the optimizer (no vacuum), like --analyz…'
complete -c vacuumdb -o '?
.br
--help' -d 'Show help about vacuumdb command line arguments, and exit'
complete -c vacuumdb -s h -d 'Specifies the host name of the machine on which the server is running'
complete -c vacuumdb -s p -d 'Specifies the TCP port or local Unix domain socket file extension on which th…'
complete -c vacuumdb -s U -d 'User name to connect as'
complete -c vacuumdb -o 'w
.br
--no-password' -d 'Never issue a password prompt'
complete -c vacuumdb -o 'W
.br
--password' -d 'Force vacuumdb to prompt for a password before connecting to a database'
complete -c vacuumdb -l maintenance-db -d 'Specifies the name of the database to connect to to discover which databases …'
complete -c vacuumdb -s a
complete -c vacuumdb -l all
complete -c vacuumdb -o a/--all -d 'is not used'
complete -c vacuumdb -s e
complete -c vacuumdb -l echo
complete -c vacuumdb -s f
complete -c vacuumdb -l full
complete -c vacuumdb -s F
complete -c vacuumdb -l freeze
complete -c vacuumdb -l jobs
complete -c vacuumdb -l schema
complete -c vacuumdb -l exclude-schema
complete -c vacuumdb -l parallel
complete -c vacuumdb -s q
complete -c vacuumdb -l quiet
complete -c vacuumdb -l table
complete -c vacuumdb -l analyze -d or
complete -c vacuumdb -l analyze-only -d 'options.  Multiple tables can be vacuumed by writing multiple'
complete -c vacuumdb -s v
complete -c vacuumdb -l verbose
complete -c vacuumdb -s V
complete -c vacuumdb -l version
complete -c vacuumdb -s z
complete -c vacuumdb -s Z
complete -c vacuumdb -s '?'
complete -c vacuumdb -l help
complete -c vacuumdb -l host
complete -c vacuumdb -l port
complete -c vacuumdb -l username
complete -c vacuumdb -s w
complete -c vacuumdb -l no-password
complete -c vacuumdb -s W
complete -c vacuumdb -l password
