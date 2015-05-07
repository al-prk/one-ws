FROM phusion/baseimage:0.9.16

MAINTAINER Alexandr Prokopenko <crsde.pk@gmail.com>

# Установка пакетов 1С

COPY packages/*.deb packages/
RUN sh -c 'dpkg -i ./packages/1c-enterprise82-common_8.2.*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise82-server_8.2.*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise82-ws_8.2.*_amd64.deb'

# Установка Apache 2.2

RUN echo "deb http://ru.archive.ubuntu.com/ubuntu/ precise main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes apache2=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1

# Установка Ruby

RUN apt-get install -y --force-yes ruby ruby-dev build-essential libxslt-dev libxml2-dev libxml2 zlib1g-dev

RUN gem install guard --no-ri --no-rdoc
RUN gem install nokogiri --no-ri --no-rdoc
RUN gem install bundler --no-ri --no-rdoc
ADD config /config
RUN BUNDLE_GEMFILE=/config/Gemfile bundle install


ADD httpd.conf /etc/apache2/
ADD pub /pub

#RUN mkdir /etc/container_environment/

ENV descriptors_config /etc/apache2/descriptors.conf
#RUN echo /etc/apache2/descriptors.conf > /etc/container_environment/descriptors_config
# ADD descriptors.conf $descriptors_config

ENV descriptors /descriptors
#RUN echo /descriptors > /etc/container_environment/descriptors

VOLUME $descriptors

ENV public_dir /pub
#RUN echo /pub > /etc/container_environment/public_dir

RUN mkdir /etc/service/apache2
ADD apache.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

RUN mkdir /etc/service/config_reloader
ADD config_reloader.sh /etc/service/config_reloader/run
RUN chmod +x /etc/service/config_reloader/run

ADD my_init.d/ /etc/my_init.d/
RUN chmod +x /etc/my_init.d/load_config.sh

CMD ["/sbin/my_init"]
EXPOSE 80 443

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
