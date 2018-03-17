#!/bin/bash


echo "Bootstrapping..."

# Create users
adduser --no-create-home --disabled-password --gecos "" phab
adduser --no-create-home --disabled-password --gecos "" git
adduser phab sudo

# Create folders
mkdir -p /data/repo && chown phab:phab /data/repo
mkdir -p /opt && chmod 755 /opt

# Install phabricator
git clone https://github.com/phacility/libphutil.git && chown -R phab.phab libphutil
git clone https://github.com/phacility/arcanist.git && chown -R phab.phab arcanist
git clone https://github.com/phacility/phabricator.git && chown -R phab.phab phabricator


# Add users to sudoers
echo "git ALL=(phab) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/hg, /usr/bin/svnserve" >> /etc/sudoers
echo "www-data ALL=(phab) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/lib/git-core/git-http-backend, /usr/bin/hg" >> /etc/sudoers



# Configure apache
a2enmod rewrite
a2dissite 000-default
a2ensite phabricator

# Configure php
sed -e 's|^[; ]*always_populate_raw_post_data.*$|always_populate_raw_post_data = -1|' \
    -e 's|^[; ]*post_max_size.*$|post_max_size = 32M|' \
    -e 's|^[; ]*date.timezone.*$|date.timezone = Europe/Berlin|' \
    -i /etc/php5/apache2/php.ini


# Configure ssh access
cp /opt/phabricator/resources/sshd/sshd_config.phabricator.example /etc/ssh/sshd_config
sed -e 's|^AuthorizedKeysCommand .*$|AuthorizedKeysCommand /opt/sshd/phabricator-ssh-hook.sh|' \
    -e 's|vcs-user|git|' \
    -e 's|^Port.*$|Port 22|' \
    -i /etc/ssh/sshd_config

mkdir -p /opt/sshd
cp /opt/phabricator/resources/sshd/phabricator-ssh-hook.sh /opt/sshd
chmod 755 /opt/sshd/phabricator-ssh-hook.sh
sed -e 's|^VCSUSER=.*$|VCSUSER="git"|' \
    -e 's|^ROOT=.*$|ROOT="/opt/phabricator"|' \
    -i /opt/sshd/phabricator-ssh-hook.sh

mkdir -p /var/run/sshd




