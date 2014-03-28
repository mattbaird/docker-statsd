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

###
# Due to an issue with older versions of django, we need to install a specific
# version of the django-tagging package (0.3.1) or later.
# It also sounds like >=django-1.5 may fix this as well.
# REF(1): https://github.com/gdbtek/setup-graphite/pull/4
###
#RUN pip uninstall django-tagging
RUN pip uninstall -y django-tagging
RUN pip install django-tagging==0.3.1

ADD storage-schemas.conf /opt/graphite/conf/
ADD carbon.conf /opt/graphite/conf/

RUN mkdir -p /opt/graphite/storage/log/webapp

ADD local_settings.py /opt/graphite/webapp/graphite/

RUN git clone git://github.com/etsy/statsd.git /opt/statsd

RUN npm install /opt/statsd

ADD config.js /opt/statsd/

RUN mkdir -p /opt/graphite/storage/whisper
RUN chown -R www-data.www-data /opt/graphite/storage/whisper

###
# @TODO This line is commented out because it errors when being run since
# graphite.db did not yet exist
###
#RUN [ -f /opt/graphite/storage/storage/whisper/graphite.db ] && chmod 0664 /opt/graphite/storage/storage/whisper/graphite.db

RUN python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

ADD supervisord.conf /etc/supervisor/conf.d/

ADD test-client /opt/

CMD ["/usr/bin/supervisord"]
