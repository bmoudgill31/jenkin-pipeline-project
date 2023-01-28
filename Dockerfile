FROM  nginx:latest
MAINTAINER raoshahzaibtariq@gmail.com
RUN apt-get update && apt-get install -y nginx \
 zip\
 unzip
ADD https://www.free-css.com/assets/files/free-css-templates/download/page287/doni-charity.zip /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN unzip doni-charity.zip
RUN cp -r html/* /usr/share/nginx/html
RUN rm -rf html doni-charity.zip
#CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EXPOSE 80
