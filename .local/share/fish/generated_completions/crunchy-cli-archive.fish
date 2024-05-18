# crunchy-cli-archive
# Autogenerated from man page /usr/share/man/man1/crunchy-cli-archive.1.gz
complete -c crunchy-cli-archive -s a -l audio -d 'Audio languages.  Can be used multiple times'
complete -c crunchy-cli-archive -s s -l subtitle -d 'Subtitle languages.  Can be used multiple times'
complete -c crunchy-cli-archive -s o -l output -d 'Name of the output file'
complete -c crunchy-cli-archive -l output-specials -d 'Name of the output file if the episode is a special'
complete -c crunchy-cli-archive -l universal-output -d 'Sanitize the output file for use with all operating systems'
complete -c crunchy-cli-archive -s r -l resolution -d 'The video resolution.  Can either be specified via the pixels (e. g'
complete -c crunchy-cli-archive -s m -l merge -d 'Because of local restrictions (or other reasons) some episodes with different…'
complete -c crunchy-cli-archive -l merge-auto-tolerance -d 'If the merge behavior is \\*(Aqauto\\*(Aq, only download multiple video tracks …'
complete -c crunchy-cli-archive -l sync-start -d 'Tries to sync the timing of all downloaded audios to match one video'
complete -c crunchy-cli-archive -l language-tagging -d 'Specified which language tagging the audio and subtitle tracks and language s…'
complete -c crunchy-cli-archive -l ffmpeg-preset -d 'Presets for converting the video to a specific coding format'
complete -c crunchy-cli-archive -l ffmpeg-threads -d 'The number of threads used by ffmpeg to generate the output file'
complete -c crunchy-cli-archive -l default-subtitle -d 'Set which subtitle language should be set as default / auto shown when starti…'
complete -c crunchy-cli-archive -l include-fonts -d 'Include fonts in the downloaded file'
complete -c crunchy-cli-archive -l include-chapters -d 'Includes chapters (e. g.  intro, credits, . )'
complete -c crunchy-cli-archive -l no-closed-caption -d 'Omit closed caption subtitles in the downloaded file'
complete -c crunchy-cli-archive -l skip-existing -d 'Skip files which are already existing by their name'
complete -c crunchy-cli-archive -l skip-existing-method -d 'Only works in combination with `--skip-existing`'
complete -c crunchy-cli-archive -l skip-specials -d 'Skip special episodes'
complete -c crunchy-cli-archive -s y -l yes -d 'Skip any interactive input'
complete -c crunchy-cli-archive -s t -l threads -d 'The number of threads used to download'
complete -c crunchy-cli-archive -s h -l help -d 'Print help (see a summary with \\*(Aq-h\\*(Aq)'
