# tpm2_changeauth
# Autogenerated from man page /usr/share/man/man1/tpm2_changeauth.1.gz
complete -c tpm2_changeauth -s c -l object-context -d 'The key context object to be used for the operation'
complete -c tpm2_changeauth -s p -l object-auth -d 'The old authorization value for the TPM object specified with'
complete -c tpm2_changeauth -s C -l parent-context -d 'The parent object'
complete -c tpm2_changeauth -s r -l private -d 'contains the new sensitive portion of the object whose auth was being changed'
complete -c tpm2_changeauth -l cphash -d 'File path to record the hash of the command parameters'
complete -c tpm2_changeauth -l rphash -d 'File path to record the hash of the response parameters'
complete -c tpm2_changeauth -s S -l session -d 'The session created using tpm2_startauthsession'
complete -c tpm2_changeauth -s h -l help -d 'By default, it attempts to invoke the manpager for the tool, however, on fail…'
complete -c tpm2_changeauth -s v -l version -d 'tool, supported tctis and exit.  [bu] 2'
complete -c tpm2_changeauth -s V -l verbose -d 'tool prints to the console during its execution'
complete -c tpm2_changeauth -s Q -l quiet -d '[bu] 2'
complete -c tpm2_changeauth -s Z -l enable-errata -d 'errata fixups'
