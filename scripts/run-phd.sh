#!/bin/bash

su phab -c '/opt/phabricator/bin/phd restart --force'

set +e
set +x

while [ 0 -eq 0 ]; do
    TEMP=$(ps aux)
    if [ "$(echo $TEMP | awk '/phd-daemon/{print $2}')" == "" ]; then
        echo "Detected daemons stopped running!"
        break
    else
        sleep 1000
    fi
done

exit 1