#!/bin/bash
case $1/$2 in
pre/*)
  # Put here any commands expected to be run when suspending or hibernating.
  # modprobe -r mt7925e
  ;;
post/*)
  # Put here any commands expected to be run when resuming from suspension or thawing from hibernation.
  # modprobe mt7925e

  ;;
esac
