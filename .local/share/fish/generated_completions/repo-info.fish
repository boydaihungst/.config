# repo-info
# Autogenerated from man page /usr/share/man/man1/repo-info.1.gz
complete -c repo-info -s h -l help -d 'show this help message and exit'
complete -c repo-info -s d -l diff -d 'show full info and commit diff including remote branches'
complete -c repo-info -s o -l overview -d 'show overview of all local commits'
complete -c repo-info -s c -l current-branch -d 'consider only checked out branches'
complete -c repo-info -l no-current-branch -d 'consider all local branches'
complete -c repo-info -s l -l local-only -d 'disable all remote operations . SS Logging options:'
complete -c repo-info -s v -l verbose -d 'show all output'
complete -c repo-info -s q -l quiet -d 'only show errors . SS Multi-manifest options:'
complete -c repo-info -l outer-manifest -d 'operate starting at the outermost manifest'
complete -c repo-info -l no-outer-manifest -d 'do not operate on outer manifests'
complete -c repo-info -l this-manifest-only -d 'only operate on this (sub)manifest'
complete -c repo-info -l no-this-manifest-only -l all-manifests -d 'operate on this manifest and its submanifests'
