FROM debian:jessie-slim

# Install the dependencies
RUN apt-get update && apt-get -y install \
    git subversion openssh-server openssh-client \
    mysql-client apache2 \
    php5 php5-mysql php5-gd php5-dev \
    php5-curl php5-apcu php5-cli php5-json \
    python-pygments sendmail imagemagick sudo \
    && apt-get clean

# Copy the apache2 configuration
COPY apache2-phabricator.conf /etc/apache2/sites-available/phabricator.conf

# Copy the run script
COPY run.sh /opt
COPY bootstrap.sh /opt

RUN /opt/bootstrap.sh

# Expose hosts
EXPOSE 80 443 2222

CMD ["/opt/run.sh"]

