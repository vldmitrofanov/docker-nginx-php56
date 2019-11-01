# docker-nginx-php56

this container is using ubuntu:16.04 and php 5.6 together with php-fpm and nginx


to build enter into directory and run

`# docker build -t="docker-nginx-php56" .`

you can see if your image is in the list

`# docker image ls`

output will be something like that: 
```
REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
docker-nginx-php56               latest              827d5ed02bae        24 minutes ago      687MB
```


If you want to push new image to your own docker repository, you would need to tag it first
```
# docker tag 827d5ed02bae <your user>/docker-nginx-php56
```

login
```
# docker login
```

then
```
# docker push shirker2006/docker-nginx-php56
```


available image could be used this way:
```
# docker run --name <fancy-name> -d -p 8081:80 --restart always  -v /Users/spongebob/bikini-botom/httproot:/var/www/app/ shirker2006/docker-nginx-php56
```

to connect to your localhost MySQL db use `'host.docker.internal'` as IP address (at least works for mac)
