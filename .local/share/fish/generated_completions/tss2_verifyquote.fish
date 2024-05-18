# tss2_verifyquote
# Autogenerated from man page /usr/share/man/man1/tss2_verifyquote.1.gz
complete -c tss2_verifyquote -s Q -l qualifyingData
complete -c tss2_verifyquote -s l -l pcrLog -d 'stdin): Returns the PCR event log for the chosen PCR.  Optional parameter'
complete -c tss2_verifyquote -s q -l quoteInfo -d '(for stdin): The JSON-encoded structure holding the inputs to the quote opera…'
complete -c tss2_verifyquote -s k -l publicKeyPath -d 'Identifies the signing key.  MAY be a path to the public key hierarchy /ext'
complete -c tss2_verifyquote -s i -l signature -d '(for stdin): The signature over the quoted material'
complete -c tss2_verifyquote -s h -l help -d 'By default, it attempts to invoke the manpager for the tool, however, on fail…'
complete -c tss2_verifyquote -s v -l version -d 'tool, supported tctis and exit'
