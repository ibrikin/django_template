#!/bin/bash

set -e

MODULE=${MODULE:-website}

sed -i "s#module=website.wsgi:application#module=${MODULE}.wsgi:application#g" /opt/uwsgi/uwsgi.ini

if [ ! -f "/opt/app/manage.py" ]
then
  echo "creating basic django project (module: ${MODULE})"
  django-admin.py startproject ${MODULE} /opt/app/
fi

exec /usr/bin/supervisord