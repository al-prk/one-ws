#FROM ubuntu:14.04.2
FROM phusion/baseimage:0.9.0
MAINTAINER Alexandr Prokopenko

COPY packages/*.deb packages/

RUN sh -c 'dpkg -i ./packages/1c-enterprise82-common_8.2.*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise82-server_8.2.*_amd64.deb'
RUN sh -c 'dpkg -i ./packages/1c-enterprise82-ws_8.2.*_amd64.deb'

RUN echo "deb http://ru.archive.ubuntu.com/ubuntu/ precise main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --force-yes apache2=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1

ADD httpd.conf /etc/apache2/
ADD pub /pub



CMD ["/sbin/my_init"]
EXPOSE 80 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*