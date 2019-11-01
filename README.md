# docker-nginx-php56

this container is using ubuntu:16.04 and php 5.6 together with php-fpm and nginx


to build enter into directory and run

docker build -t="docker-nginx-php56" .


available image could be used this way:

docker run --name <my-fancy-name> -d -p 8081:80 --restart always   -v /Users/spongebob/bikini-botom/httproot:/var/www/app/ shirker2006/docker-nginx-php56

to connect to your localhost MySQL db use 'host.docker.internal' as IP address (at least works for mac)
