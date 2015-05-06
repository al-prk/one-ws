FROM phusion/baseimage:0.9.0

MAINTAINER Alexandr Prokopenko <crsde.pk@gmail.com>

# Установка пакетов 1С

#COPY packages/*.deb packages/
#RUN sh -c 'dpkg -i ./packages/1c-enterprise82-common_8.2.*_amd64.deb'
#RUN sh -c 'dpkg -i ./packages/1c-enterprise82-server_8.2.*_amd64.deb'
#RUN sh -c 'dpkg -i ./packages/1c-enterprise82-ws_8.2.*_amd64.deb'

# Установка Apache 2.2

RUN echo "deb http://ru.archive.ubuntu.com/ubuntu/ precise main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes apache2=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1

# Установка Ruby

RUN apt-get install -y --force-yes ruby1.9.3 rubygems
RUN update-alternatives --set ruby /usr/bin/ruby1.9.1
RUN update-alternatives --set gem /usr/bin/gem1.9.1


RUN gem install guard --no-ri --no-rdoc
RUN gem install bundler --no-ri --no-rdoc
ADD config /config

ADD httpd.conf /etc/apache2/
ADD pub /pub

ENV descriptors_config /etc/apache2/descriptors.conf
# ADD descriptors.conf $descriptors_config

ENV descriptors /descriptors
VOLUME $descriptors

ENV public_dir /pub

RUN mkdir /etc/service/apache2
ADD apache.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

RUN mkdir /etc/service/config_reloader
ADD config_reloader.sh /etc/service/config_reloader/run
RUN chmod +x /etc/service/config_reloader/run


CMD ["/sbin/my_init"]
EXPOSE 80 443

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
