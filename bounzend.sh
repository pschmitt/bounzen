#!/bin/zsh

PIDFILE=/tmp/bounzend.pid
PIPE=/tmp/bounzend_pipe
echo $$ > $PIDFILE

echo $(pwd)

cleanup() {
    rm -f $PIDFILE $PIPE
    return $?
}

trap 'source $conf' 1
trap 'cleanup; exit' 0
trap 'cleanup; exit' 2 # ctrl-c
trap 'cleanup; exit' 3
trap 'cleanup; exit' 15

[[ ! -p $PIPE ]] && mkfifo $PIPE
exec 4<$PIPE

i=0

# loop forever
while :;do
    # echo "n = $(( i = $i +1 ))"
    unset foo arg
    read -u 4 arg foo
    if [[ -n $arg ]]; then
        if [[ $arg =~ "\-[bdmnu]" ]];then
            bounzen $arg $foo & bpid=$!
        else
            bounzen "$arg $foo" & bpid=$!
        fi
        wait $bpid
    elif [[ -n $foo ]];then
        bounzen.sh "$foo" & bpid=$!
        wait $bpid
    fi
    # echo "n $1 ended"
    sleep 1
done &

return 0
