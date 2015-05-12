FROM phusion/baseimage:0.9.16

MAINTAINER Alexandr Prokopenko <crsde.pk@gmail.com>


ENV descriptors_config /etc/apache2/descriptors.conf
ENV descriptors /descriptors
ENV public_dir /pub

# Volume для файлов .vrd на основе которых будет производиться конфигурация

VOLUME $descriptors

# Установка пакетов 1С

COPY packages/*.deb packages/
RUN sh -c 'dpkg -i ./packages/1c-enterprise*-common_*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise*-server_*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise*-ws_*_amd64.deb'

# Установка Apache 2.2

RUN echo "deb http://ru.archive.ubuntu.com/ubuntu/ precise main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes apache2=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1

# Установка Ruby

RUN apt-get install -y --force-yes ruby ruby-dev build-essential libxslt-dev libxml2-dev libxml2 zlib1g-dev

RUN gem install bundler --no-ri --no-rdoc
ADD config /config
RUN BUNDLE_GEMFILE=/config/Gemfile bundle install

# Конфигурация веб-сервера

ADD httpd.conf /etc/apache2/
RUN echo "LoadModule _1cws_module \"$(ls /opt/1C/*/*/wsap22.so)\"" > /etc/apache2/one_c_module.conf
RUN mkdir /pub

ADD my_init.d/ /etc/my_init.d/
RUN chmod +x /etc/my_init.d/load_config.sh

# Сервис веб-сервера

RUN mkdir /etc/service/apache2
ADD service/apache.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# Сервис редеплоя дескрипторов

RUN mkdir /etc/service/config_reloader
ADD service/config_reloader.sh /etc/service/config_reloader/run
RUN chmod +x /etc/service/config_reloader/run

CMD ["/sbin/my_init"]
EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
