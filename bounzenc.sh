#!/bin/zsh -f

PIPE=/tmp/bounzend_pipe

if [[ ! -p $PIPE ]]; then
    [[ -e $PIPE ]] && rm -f $PIPE
    mkfifo $PIPE
fi

print -- $@ > $PIPE &

return 0
