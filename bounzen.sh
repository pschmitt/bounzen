#!/usr/bin/env zsh
# Author: Philipp Schmitt
# Credits: livibetter (Yu-Jie Lin)
# Bzen2.sh fork 
# https://github.com/livibetter/dotfiles/blob/master/bin/bzen2.sh

# TODO: read data from pipe, queue etc

ICON_DIR=/usr/share/icons/bounzen

# Config section
CHAR_WIDTH=15
FONT="Envy Code R-20"
HEIGHT=40
ALIGNMENT=c
Y_POS=15
FG_COLOR='#8c8b8e'
BG_COLOR='#161616'
TIMEOUT=5000 # leave blank for making persistant
read _ S_WIDTH <<< "$(xwininfo -root | egrep Width)"
DEFAULT_WINDOW_TITLE=bounzen
BAT_ICON="^i($ICON_DIR/bat_low.xpm)"
DB_ICON="^i($ICON_DIR/dropbox.xpm)"
MAIL_ICON="^i($ICON_DIR/gmail.xpm)"
MUSIC_ICON="^i($ICON_DIR/noteR.xbm)"
URGENT_ICON="^i($ICON_DIR/warning.xpm)"

#PIDFILE=bounzen.pid
#echo $$ > $PIDFILE

# Parse options
while getopts "b d: m: n u:" opt; do
    case $opt in
        b) # battery low
            ICON=$BAT_ICON
            TEXT="Plug or pray ..."
            FG_COLOR='#ffffff'
            BG_COLOR='#603030'
            ;;
        d) # dropbox
            ICON=$DB_ICON
            TEXT="$OPTARG"
            ;;
        m) # new mail
            ICON=$MAIL_ICON
            TEXT="You got mail ($OPTARG)"
            ;;
        n) # new song
            ICON=$MUSIC_ICON
            TEXT=$(mpc current)
            ;;
        u) #urgent
            ICON=$URGENT_ICON
            FG_COLOR='#ffffff'
            BG_COLOR='#603030' 
            TEXT="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))

# set text if not already set (case: no option)
[[ -z $TEXT ]] && TEXT="$@"
WIDTH=$(( CHAR_WIDTH * ${#TEXT} + CHAR_WIDTH / 2 + 32 ))

# $1: window title, default is BOUNZEN
try_getting_win_id() {
    unset win_id
    local title
    # [[ -z $1 ]] && title=$DEFAULT_WINDOW_TITLE || title=$1
    # win_id=$(xwininfo -root -children | grep $title | sed -n '/^ \+0x/ {s/ \+\(0x[0-9a-z]\+\).*/\1/;p}')
    # [[ -z $win_id ]] && return 1 || return 0
    wids=$(xwininfo -root -children | sed -n '/^ \+0x/ {s/ \+\(0x[0-9a-z]\+\).*/\1/;p}')
    for wid in $wids; do
        wid_pid=$(xprop -id "$wid" _NET_WM_PID | grep -o '[0-9]\+')
        if [[ "$wid_pid" == "$1" ]]; then
            win_id=$wid
            return 0
        else
            return 1
        fi
    done
}

get_win_id() {
    # give it 10 tries (1 second max)
    for i in {1..10}; do
        echo $i
        try_getting_win_id $BOUNZEN_PID
        [[ $? -eq 0 ]] && break
        sleep 0.1
    done
    if [[ -z $win_id ]]; then
        # echo "Cannot find window ID of dzen2, killing..."
        kill $BOUNZEN_PID
        exit 1
    fi
}
echo "$ICON$TEXT" | dzen2 -title-name $DEFAULT_WINDOW_TITLE \
                          -ta $ALIGNMENT \
                          -x "$((S_WIDTH - WIDTH))" -y $Y_POS \
                          -h $HEIGHT \
                          -fg $FG_COLOR -bg $BG_COLOR \
                          -fn $FONT \
                          -p &
BOUNZEN_PID=$!

echo $BOUNZEN_PID

get_win_id

#wmctrl -i -r $win_id -e 0,$((S_WIDTH-WIDTH)),$Y_POS,1,1

slide_in() {
    for i in {0..$(( WIDTH/3 ))}; do
        wmctrl -i -r $win_id -e 2,$((S_WIDTH - 3*i)),$Y_POS,$WIDTH,$HEIGHT
        # 400 times per second
        sleep 0.0025
      done
}
slide_in

damocles() {
    time_start=$(date +%s%N)
    while (( $(date +%s%N) - time_start < TIMEOUT * 1000000 )); do
        sleep 0.025
    done
}
damocles

# clean up
kill $BOUNZEN_PID
#rm $PIDFILE

return 0
