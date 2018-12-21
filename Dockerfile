FROM alpine
ARG HUGO_VERSION
ENV HUGO_URL=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
ADD $HUGO_URL /tmp/hugo.tar.gz
RUN tar -xvf /tmp/hugo.tar.gz -C /usr/bin/
ENTRYPOINT [ "hugo" ]
