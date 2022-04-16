FROM  ubuntu:focal AS init

RUN apt update && apt install nginx -y

FROM init AS final

RUN mkdir /var/www/html
COPY index.html /var/www/html/
COPY site /etc/nginx/sites-enabled/

ENTRYPOINT nginx -g 'daemon off;'
EXPOSE 80
