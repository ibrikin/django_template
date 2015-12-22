## Шаблон Джанго проекта с использованием докера

Для работы с шаблоном нужно установить `cookiecutter`:

    $ sudo pip install cookiecutter
    
    
Использование:

В папке где будет проект выполнить:

    $ cookiecutter http://virt88.aetp.nn/brikin.i/template_django.git
    
## Как работать с Docker

### Запуск нового проекта

1. Скопировать структуру проекта:

    $ cookiecutter http://virt88.aetp.nn/brikin.i/template_django.git
    
2. В файле `.env` задать имя проекта в `MODULE` (по умолчанию - project_name)

3. В папке `app/` добавить необходимые для проекта модули в файл `requirements.txt`

4. Построить локальный проект:

    $ docker-compose build # построение images
    
    $ docker-compose up -d # запуск контейнеров
    
    $ docker-compose logs # для просмотра лога
    
    
### Запуск существующего проекта

1. Скопировать структуру проекта

2. Поместить в папку `app/` проект, чтобы до файла `manage.py` был путь `app/manage.py`

3. В файле `.env` задать имя проекта в `MODULE` и поправить остальные переменные.

Для базы:

    DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2', 
        'NAME': os.environ['DB_NAME'],                      
        # The following settings are not used with sqlite3:
        'USER': os.environ['DB_USER'],
        'PASSWORD': os.environ['DB_PASS'],
        'HOST': os.environ['DB_SERVICE'],                     
        'PORT': os.environ['DB_PORT'],                     
        }
    }
    
Для секретного ключа:
    
    SECRET_KEY = os.environ['SECRET_KEY']

4. В папке `app/` добавить необходимые для проекта модули в файл `requirements.txt`

5. Построить локальный проект:

    $ docker-compose build # построение images
    
    $ docker-compose up -d # запуск контейнеров
    
    $ docker-compose logs # для просмотра лога
    
    
### Работа с Docker

    $ docker exec [имя контейнера] [команда внутри контейнера] 
   
    
### Авторизация клиентов по SSL сертификату

Создаем закрытый ключ и сертификат для себя. В папке `/nginx` запусить слудующую команду:

    $ openssl req -new -newkey rsa:1024 -nodes -keyout ca.key -x509 -days 500 -out ca.crt
    
Получаем два файла: `ca.key` и  `ca.crt`
    
Создаем сертификат для nginx:

    $ openssl genrsa -des3 -out server.key 1024
    $ openssl req -new -key server.key -out server.csr
    
Подписываем сертификат:

    $ openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
    
Чтобы nginx не спрашивал пароль после перезагрузки:

    $ openssl rsa -in server.key -out server.nopass.key
    
Добавить/раскомментировать в конфиге nginx:

    listen 	443 ssl;
    ssl_certificate      /opt/nginx/server.crt;
    ssl_certificate_key  /opt/nginx/server.nopass.key;
    ssl_client_certificate /opt/nginx/ca.crt;
    ssl_verify_client on;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    keepalive_timeout 70;
	fastcgi_param SSL_VERIFIED $ssl_client_verify;
	fastcgi_param SSL_CLIENT_SERIAL $ssl_client_serial;
	fastcgi_param SSL_CLIENT_CERT $ssl_client_cert;
	fastcgi_param SSL_DN $ssl_client_s_dn;
	
После перезапуска контейнера можно подключаться со своим ключем:

    $ curl -k ca.key --cert ca.crt --url "https://172.17.0.12"

Чтобы сгенерировать ключ для клиента, в папке nginx:

    $ mkdir db
    $ mkdir db/certs
    $ mkdir db/newcerts
    $ touch db/index.txt
    $ echo "01" > db/serial
    
    $ openssl req -new -newkey rsa:1024 -nodes -keyout client01.key -out client01.csr
    $ openssl ca -config ca.config -in client01.csr -out client01.crt -batch
    
Теперь можно подключиться с ключем клиента:

    $ curl -k client01.key --cert client01.crt --url "https://172.17.0.12"
    
Сгенерировать ключ для браузера:
    
    $ openssl pkcs12 -export -in client01.crt -inkey client01.key -certfile ca.crt -out client01.p12 -passout pass:q1w2e3
    
