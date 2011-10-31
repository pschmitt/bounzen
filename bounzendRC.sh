#!/bin/bash -f

. /etc/rc.conf
. /etc/rc.d/functions

DAEMON=bounzend
ARGS=
USER=pschmitt

[ -r /etc/conf.d/$DAEMON ] && . /etc/conf.d/$DAEMON

[ -r /tmp/bounzend.pid ] && PID=$(cat /tmp/bounzend.pid)
case "$1" in
    start)
        stat_busy "Starting $DAEMON"
        [ -z "$PID" ] && su $USER -c "$DAEMON $ARGS &" &>/dev/null &
        if [ $? = 0 ]; then
            add_daemon $DAEMON
            stat_done
        else
            stat_fail
            exit 1
        fi
        ;;
    stop)
        stat_busy "Stopping $DAEMON"
        [ -n "$PID" ] && kill $PID &>/dev/null
        if [ $? = 0 ]; then
            rm_daemon $DAEMON
            stat_done
        else
            stat_fail
            exit 1
        fi
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    *)
    echo "usage: $0 {start|stop|restart}"
esac

