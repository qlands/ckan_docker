FROM ubuntu:20.04

MAINTAINER QLands Technology Consultants
RUN sed -i 's/archive./us.archive./g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe && add-apt-repository multiverse
RUN DEBIAN_FRONTEND=noninteractive TZ=UTC apt-get -y install tzdata
RUN apt-get install -y python3-dev postgresql libpq-dev python3-pip python3-venv git-core solr-jetty redis-server

WORKDIR /opt
RUN mkdir gunicorn
RUN mkdir log
RUN python3 -m venv ckan
WORKDIR /opt/ckan

RUN . ./bin/activate && pip install --upgrade pip && pip install gunicorn && pip install gevent && pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.9.5#egg=ckan[requirements]'

RUN mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
RUN ln -s /opt/ckan/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml

WORKDIR /opt/ckan
RUN mkdir config
RUN mkdir storage
RUN mkdir plugins
WORKDIR /opt

RUN apt-get install -y zip unzip nano curl

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY ./docker_files/docker-entrypoint.sh /
COPY ./docker_files/postgresql.zip /
COPY ./docker_files/solr.zip /
COPY ./docker_files/create_role.sql /
COPY ./docker_files/create_database.sh /
COPY ./docker_files/create_sysadmin.sh /
COPY ./docker_files/wsgi.py /
COPY ./docker_files/start_ckan.sh /
COPY ./docker_files/stop_ckan.sh /
RUN locale-gen en_US.UTF-8
RUN export LC_COLLATE=en_US.UTF-8
EXPOSE 5000
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /create_database.sh
RUN chmod +x /create_sysadmin.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
