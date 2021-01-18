FROM nginx:stable-alpine
LABEL maintainer="Bryan Horna <bryanjhv@gmail.com>"

WORKDIR /app
VOLUME ["/etc/nginx/dhparam"]

CMD ["forego", "start", "-r"]
ENTRYPOINT ["/app/docker-entrypoint.sh"]

ENV DOCKER_GEN_VERSION 0.7.4
ENV DOCKER_HOST unix:///tmp/docker.sock

RUN set -x\
 # install deps
 && apk add -q --no-cache bash openssl\
 # install forego
 && wget -q https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz\
 && tar xf forego-stable-linux-amd64.tgz -C /usr/local/bin\
 && rm forego-stable-linux-amd64.tgz\
 # install docker-gen
 && wget -q https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz\
 && tar xf docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz -C /usr/local/bin\
 && rm docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz\
 # copy upstream files
 && wget -q https://github.com/jwilder/nginx-proxy/archive/master.tar.gz\
 && tar xf master.tar.gz\
 && cd nginx-proxy-master\
 && mv network_internal.conf /etc/nginx\
 && mv dhparam.pem.default docker-entrypoint.sh generate-dhparam.sh nginx.tmpl Procfile /app\
 && cd ..\
 && rm -r master.tar.gz nginx-proxy-master\
 # patch entry files for nginx
 && sed -i "\$c nginx: nginx -g 'daemon off;'" /app/Procfile\
 # remove old entrypoints
 && rm -r /docker-entrypoint*
