#name of container: docker-openemr
#versison of container: 0.1.1
FROM quantumobject/docker-baseimage
MAINTAINER Angel Rodriguez "angel@quantumobject.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && apt-get install -y -q apache2 \
                                            mysql-server \
                                            php5 \
                                            apache2-mpm-prefork \
                                            libapache2-mod-php5 \
                                            libdate-calc-perl \
                                            libdbd-mysql-perl \
                                            libhtml-parser-perl \
                                            libtiff-tools \
                                            libwww-mechanize-perl \
                                            libxml-parser-perl \
                                            libtiff-tools \
                                            php5-mysql \
                                            php5-cli \
                                            php5-gd \
                                            php5-xsl \
                                            php5-curl \
                                            php5-mcrypt \
                                            php-soap \
                                            imagemagick \
                                            php5-json \
                                      && apt-get clean \
                                      && rm -rf /tmp/* /var/tmp/* \
                                      && rm -rf /var/lib/apt/lists/*

#General variable definition....
##startup scripts
COPY php.ini /etc/php5/apache2/php.ini
COPY apache2.conf /etc/apache2/apache2.conf

#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't
#run it again ... use for conf for service ... when run the first time ...

RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Adding Deamons to containers

# to add mysqld deamon to runit
RUN mkdir /etc/service/mysqld
COPY mysqld.sh /etc/service/mysqld/run
RUN chmod +x /etc/service/mysqld/run

# to add apache2 deamon to runit
RUN mkdir /etc/service/apache2
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

#pre-config scritp for different service that need to be run when container image is create
#maybe include additional software that need to be installed ... with some service running ... like example mysqld

COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
&& /bin/bash -c /sbin/pre-conf \
&& rm /sbin/pre-conf

#down/shutdown script ... use to be run in container before stop or shutdown .to keep service..good status..and maybe
#backup or keep data integrity ..
##scritp that can be running from the outside using docker exec tool ...
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

#add files and script that need to be use for this container
#include conf file relate to service/daemon
#script to execute after install configuration done ....
COPY after_install.sh /sbin/after_install
RUN chmod +x /sbin/after_install

EXPOSE 443

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
