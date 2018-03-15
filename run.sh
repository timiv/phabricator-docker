#!/bin/bash
PHAB_MYSQL_HOST="${PHAB_MYSQL_HOST:-mariadb}"
PHAB_MYSQL_USER="${PHAB_MYSQL_USER:-root}"
PHAB_MYSQL_PASSWORD="${PHAB_MYSQL_PASSWORD}"
PHAB_DOMAIN="${DOMAIN:-127.0.0.1}"

# Wait for MYSQL to become ready
while ! mysqladmin ping -h"$PHAB_MYSQL_HOST" --silent ; do
    echo "Wating for MYSQL to become ready"
    sleep 1
done

if [ ! -f /opt/.bootstrapped ]; then

    function set_config() {
        su phab -c "/opt/phabricator/bin/config set $1 $2"
    }

    # Configure phabricator
    set_config mysql.pass "${PHAB_MYSQL_PASSWORD}"
    set_config mysql.user "${PHAB_MYSQL_USER}"
    set_config mysql.host "${PHAB_MYSQL_HOST}"
    set_config phabricator.base-uri 'http://$PHAB_DOMAIN/'
    set_config phd.user phab
    set_config environment.append-paths '["/usr/lib/git-core"]'
    set_config diffusion.ssh-user git
    set_config pygments.enabled true
    set_config policy.allow-public true
    set_config diffusion.allow-http-auth false
    set_config phabricator.show-prototypes true
    set_config differential.require-test-plan-field false

    sed -i -e "s|__HOST__|$PHAB_DOMAIN|" /etc/apache2/sites-available/phabricator.conf

    echo 1 > /opt/.bootstrapped
fi

# Upgrade the storage
/opt/phabricator/bin/storage upgrade --force


su phab -c '/opt/phabricator/bin/phd start'
/usr/sbin/apachectl -DFOREGROUND

