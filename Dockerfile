FROM alpine
MAINTAINER Carlos Nunez <dev@carlosnunez.me>

COPY . /app
RUN apk add --no-cache bash make git docker py-pip && \
  pip install docker-compose && \
  rm -rf .env .git

ENTRYPOINT [ "make" ]
