FROM ubuntu:18.04
RUN apt update
RUN apt install y apache2
COPY index.html /var/www/html/
CMD ["apache2ctl", D", "FOREGROUND"]
EXPOSE 80
