FROM ubuntu

MAINTAINER rcloud

RUN apt-get update -qq && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends gettext redis-server rsync curl libxml2-dev python-dev vim && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -U rcloud
RUN chown rcloud "`Rscript -e 'cat(.libPaths()[1])'`"
RUN mkdir /data && chown rcloud /data

USER rcloud:rcloud

RUN cd /data && git clone https://github.com/att/rcloud.git
RUN cd /data/rcloud && git checkout 2.1.2 && MAKEFLAGS=-j8 sh scripts/bootstrapR.sh
RUN cd /data/rcloud && sh scripts/build.sh --no-js
RUN for i in tmp run; do if [ ! -e /data/rcloud/$i ]; then mkdir /data/rcloud/$i && chmod 0777 /data/rcloud/$i; fi; done
COPY rcloud.conf /data/rcloud/conf/rcloud.confccccccc
COPY run-rcloud.sh /data/rcloud/scripts/run-rcloud.sh
RUN ["chmod", "u+x", "/data/rcloud/scripts/run-rcloud.sh"]

RUN R --vanilla --slave -e 'install.packages(c("ulog","rcloud.solr"),,c("http://rforge.net","http://cloud.r-project.org"))'

RUN mkdir -p /data/rcloud/data/rcs
EXPOSE 8080

CMD ["/data/rcloud/scripts/run-rcloud.sh"]

