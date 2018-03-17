#!/bin/bash

PIDFILE=/run/sshd-phabricator.pid

/usr/sbin/sshd

set +e
set +x

WAITTIME=0
while [ ! -f $PIDFILE ]; do
echo "Waiting for $PIDFILE to appear..."
    sleep 1
    WAITTIME=$[$WAITTIME+1]
    if [ $WAITTIME -gt 60 ]; then
        exit 1
    fi
done

PID=$(cat $PIDFILE)
while s=`ps -p $PID -o s=` && [[ "$s" && "$s" != 'Z' ]]; do
    sleep 1
done

exit 1