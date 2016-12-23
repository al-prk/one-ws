FROM ubuntu:latest

MAINTAINER Alexandr Prokopenko <crsde.pk@gmail.com>

ENV descriptors_config /etc/apache2/descriptors.conf
ENV descriptors /descriptors
ENV public_dir /pub

VOLUME $descriptors

# Установка пакетов 1С
COPY packages/*.deb /packages/
RUN sh -c 'dpkg -i /packages/1c-enterprise*_amd64.deb'

# Установка Apache, Ruby
RUN echo "deb http://ru.archive.ubuntu.com/ubuntu/ precise main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes apache2=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1 ruby ruby-dev build-essential libxslt-dev libxml2-dev libxml2 zlib1g-dev

ADD config /config
RUN gem install bundler --no-ri --no-rdoc \
    && BUNDLE_GEMFILE=/config/Gemfile bundle install

# Конфигурация веб-сервера
RUN mv config/httpd.conf /etc/apache2/ && mkdir /pub && echo "LoadModule _1cws_module \"$(ls /opt/1C/*/*/wsap22.so)\"" > /etc/apache2/one_c_module.conf

CMD /usr/bin/ruby /config/build.rb && /usr/sbin/apache2ctl -D FOREGROUND
EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && rm /packages/*.deb
