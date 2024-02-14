FROM ubuntu:23.04

LABEL author=alexg

RUN apt update \
    && apt install git -y \
    && apt install apache2 -y \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/josejuansanchez/2048.git /app \
    && mv /app/* /var/www/html \
        && rm -rf /app

CMD ["/usr/sbin/apache2ctl" , "-D", "FOREGROUND"]