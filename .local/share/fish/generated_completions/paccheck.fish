# paccheck
# Autogenerated from man page /usr/share/man/man1/paccheck.1.gz
complete -c paccheck -l config -d 'X Item "--config=path" Set an alternate configuration file path'
complete -c paccheck -l dbpath -d 'X Item "--dbpath=path" Set an alternate database path'
complete -c paccheck -l root -d 'X Item "--root=path" Set an alternate installation root'
complete -c paccheck -l sysroot -d 'X Item "--sysroot=path" Set an alternate system root'
complete -c paccheck -l null -d 'X Item "--null[=sep]" Set an alternate separator for values parsed from stdin'
complete -c paccheck -l list-broken -d 'X Item "--list-broken" Only print the names of packages that fail the selecte…'
complete -c paccheck -l quiet -d 'X Item "--quiet" Only display messages if a problem is found'
complete -c paccheck -l recursive -d 'X Item "--recursive" Recursively perform checks on packages\' dependencies as …'
complete -c paccheck -l depends -d 'X Item "--depends" Check that all package dependencies are satisfied'
complete -c paccheck -l opt-depends -d 'X Item "--opt-depends" Check that all package optional dependencies are satis…'
complete -c paccheck -l files -d 'X Item "--files" Check package files against the local database'
complete -c paccheck -l file-properties -d 'X Item "--file-properties" Check package files against MTREE data'
complete -c paccheck -l md5sum -d 'X Item "--md5sum" Check file md5sums against MTREE data'
complete -c paccheck -l sha256sum -d 'X Item "--sha256sum" Check file sha256sums against MTREE data'
complete -c paccheck -l require-mtree -d 'X Item "--require-mtree" Treat missing MTREE data as an error for --db-files …'
complete -c paccheck -l db-files -d 'X Item "--db-files" Include database files in --files and --file-properties c…'
complete -c paccheck -l backup -d 'X Item "--backup" Include backup files in file modification checks'
complete -c paccheck -l noextract -d 'X Item "--noextract" Include NoExtract files in file modification checks'
complete -c paccheck -l noupgrade -d 'X Item "--noupgrade" Include NoUpgrade files in file modification checks'
complete -c paccheck -l help -d 'X Item "--help" Display usage information and exit'
complete -c paccheck -l version
