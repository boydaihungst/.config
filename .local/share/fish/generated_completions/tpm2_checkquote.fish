# tpm2_checkquote
# Autogenerated from man page /usr/share/man/man1/tpm2_checkquote.1.gz
complete -c tpm2_checkquote -s u -l public -d 'File input for the public portion of the signature verification key'
complete -c tpm2_checkquote -s g -l hash-algorithm -d 'The hash algorithm used to digest the message'
complete -c tpm2_checkquote -s m -l message -d 'The quote message that makes up the data that is signed by the TPM'
complete -c tpm2_checkquote -s s -l signature -d 'The input signature file of the signature to be validated'
complete -c tpm2_checkquote -s f -l pcr -d 'Optional PCR input file to save the list of PCR values that were included in …'
complete -c tpm2_checkquote -s l -l pcr-list -d 'The list of PCR banks and selected PCRs[cq] ids for each bank'
complete -c tpm2_checkquote -s q -l qualification -d 'Qualification data for the quote.  Can either be a hex string or path'
complete -c tpm2_checkquote -s F -l format -d 'DEPRECATED and IGNORED  as it[cq]s superfluous'
complete -c tpm2_checkquote -s h -l help -d 'By default, it attempts to invoke the manpager for the tool, however, on fail…'
complete -c tpm2_checkquote -s v -l version -d 'tool, supported tctis and exit.  [bu] 2'
complete -c tpm2_checkquote -s V -l verbose -d 'tool prints to the console during its execution'
complete -c tpm2_checkquote -s Q -l quiet -d '[bu] 2'
complete -c tpm2_checkquote -s Z -l enable-errata -d 'errata fixups'
complete -c tpm2_checkquote -s n
