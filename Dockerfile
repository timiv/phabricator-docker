FROM debian:jessie-slim

# Install the dependencies
RUN apt-get update && apt-get -y install \
    git subversion openssh-server openssh-client \
    mysql-client apache2 \
    php5 php5-mysqlnd php5-gd php5-dev \
    php5-curl php5-apcu php5-cli php5-json \
    python-pygments sendmail imagemagick sudo supervisor \
    && apt-get clean

# Create users
RUN adduser --no-create-home --disabled-password --gecos "" phab
RUN adduser --no-create-home --disabled-password --gecos "" git
RUN adduser phab sudo

# Create the base folder
RUN mkdir -p /opt && chmod 755 /opt

# Install phabricator
WORKDIR /opt
RUN git clone https://github.com/phacility/libphutil.git && chown -R phab.phab libphutil
RUN git clone https://github.com/phacility/arcanist.git && chown -R phab.phab arcanist
RUN git clone https://github.com/phacility/phabricator.git && chown -R phab.phab phabricator

# Copy the apache2 configuration
COPY apache2-phabricator.conf /etc/apache2/sites-available/phabricator.conf
COPY supervisord.conf /opt/

# Copy the run script
COPY scripts /opt/scripts
RUN /opt/scripts/bootstrap.sh

# Expose hosts
EXPOSE 80 443 22

CMD ["/opt/scripts/init.sh"]

