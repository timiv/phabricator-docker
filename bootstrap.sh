#!/bin/bash
PHAB_MYSQL_HOST="${PHAB_MYSQL_HOST:-mariadb}"
PHAB_MYSQL_USER="${PHAB_MYSQL_USER:-root}"
PHAB_MYSQL_PASSWORD="${PHAB_MYSQL_PASSWORD}"
PHAB_DOMAIN="${DOMAIN:-localhost}"

function set_config() {
    su phab -c "/opt/phabricator/bin/config set $1 $2"
}

echo "Bootstrapping..."

# Enable mod rewrite


# Create users
adduser --no-create-home --disabled-password --gecos "" phab sudo
adduser --no-create-home --disabled-password --gecos "" git

# Add users to sudoers
echo "git ALL=(phd) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/hg, /usr/bin/svnserve" >> /etc/sudoers
echo "www-data ALL=(phd) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/lib/git-core/git-http-backend, /usr/bin/hg" >> /etc/sudoers

# Create folders
mkdir -p /opt && chown phab:phab /opt
mkdir -p /data/repo && chown phab:phab /data/repo


# Configure apache
sed -i -e "s|__HOST__|$PHAB_DOMAIN|" /etc/apache2/sites-available/phabricator.conf
a2enmod rewrite
a2dissite 000-default
a2ensite phabricator


# Install phabricator
cd /opt
su phab -c "git clone https://github.com/phacility/libphutil.git && cd libphutil && git pull --rebase"
su phab -c "git clone https://github.com/phacility/arcanist.git && cd arcanist && git pull --rebase"
su phab -c "git clone https://github.com/phacility/phabricator.git && cd phabricator && git pull --rebase"

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


