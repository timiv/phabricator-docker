#!/bin/bash


# Wait for MYSQL to become ready
while ! mysqladmin ping -h"$PHAB_MYSQL_HOST" --silent ; do
    echo "Wating for MYSQL to become ready"
    sleep 1
done

# Upgrade the storage
/opt/phabricator/bin/storage upgrade --force


su phab -c '/opt/phabricator/bin/phd start'
/usr/sbin/apachectl -DFOREGROUND

