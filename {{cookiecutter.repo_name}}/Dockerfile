FROM nginx:latest

RUN apt-get update
RUN apt-get install -y build-essential git
RUN apt-get install -y python python-dev python-setuptools libpq-dev
RUN apt-get install -y supervisor
RUN (easy_install pip &&\
  pip install uwsgi)


ADD ./app/requirements.txt /opt/app/
RUN pip install -r /opt/app/requirements.txt
RUN rm -rf /var/lib/apt/lists/*

ADD ./app /opt/app/
ADD ./nginx /opt/nginx/
ADD ./uwsgi /opt/uwsgi/
ADD ./supervisord /opt/supervisord/

ADD ./run.sh /opt/run/
# ADD ./test.py /opt/run/
RUN chmod +x /opt/run/run.sh

RUN (echo "daemon off;" >> /etc/nginx/nginx.conf &&\
  mkdir /etc/nginx/sites-enabled &&\
  rm /etc/nginx/conf.d/default.conf &&\
  ln -s /opt/nginx/django_nginx.conf /etc/nginx/conf.d/ &&\
  ln -s /opt/supervisord/supervisord.conf /etc/supervisor/conf.d/)

# COPY ./nginx/django_nginx.conf /etc/nginx/nginx.conf
# RUN cp /opt/django/nginx/django_nginx.conf /etc/nginx/nginx.conf
# RUN ln -s /opt/django/supervisord/supervisord.conf /etc/supervisor/conf.d/

VOLUME ["/opt/app"]
EXPOSE 80 8000
CMD ["/opt/run/run.sh"]