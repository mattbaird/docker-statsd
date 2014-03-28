#mb
FROM ubuntu:quantal

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ quantal universe' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common python-software-properties git python-cairo libgcrypt11 python-virtualenv supervisor 
RUN apt-get install -y build-essential python-dev sudo vim net-tools libcairo2 libcairo2-dev memcached pkg-config python-cairo
RUN apt-get install -y python-dev python-pip sqlite3 curl python-whisper
RUN apt-add-repository -y ppa:chris-lea/node.js
RUN apt-get -y update
RUN apt-get install -y nodejs

RUN pip install --upgrade pip

ADD initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD dependencies.txt /opt/graphite/
RUN pip install -r /opt/graphite/dependencies.txt

ADD storage-schemas.conf /opt/graphite/conf/
ADD carbon.conf /opt/graphite/conf/

RUN mkdir -p /opt/graphite/storage/log/webapp

ADD local_settings.py /opt/graphite/webapp/graphite/

RUN git clone git://github.com/etsy/statsd.git /opt/statsd

RUN npm install /opt/statsd

ADD config.js /opt/statsd/

RUN mkdir -p /opt/graphite/storage/whisper
RUN chown -R www-data.www-data /opt/graphite/storage/whisper
RUN chmod 0664 /opt/graphite/storage/storage/whisper/graphite.db

RUN python /opt/graphite/webapp/graphite/manage.py syncdb

ADD supervisord.conf /etc/supervisor/conf.d/

ADD test-client /opt/

CMD ["/usr/bin/supervisord"]
