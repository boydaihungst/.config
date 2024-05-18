# repo-diffmanifests
# Autogenerated from man page /usr/share/man/man1/repo-diffmanifests.1.gz
complete -c repo-diffmanifests -s h -l help -d 'show this help message and exit'
complete -c repo-diffmanifests -l raw -d 'display raw diff'
complete -c repo-diffmanifests -l no-color -d 'does not display the diff in color'
complete -c repo-diffmanifests -l pretty-format -d 'print the log using a custom git pretty format string . SS Logging options:'
complete -c repo-diffmanifests -s v -l verbose -d 'show all output'
complete -c repo-diffmanifests -s q -l quiet -d 'only show errors . SS Multi-manifest options:'
complete -c repo-diffmanifests -l outer-manifest -d 'operate starting at the outermost manifest'
complete -c repo-diffmanifests -l no-outer-manifest -d 'do not operate on outer manifests'
complete -c repo-diffmanifests -l this-manifest-only -d 'only operate on this (sub)manifest'
complete -c repo-diffmanifests -l no-this-manifest-only -l all-manifests -d 'operate on this manifest and its submanifests'
