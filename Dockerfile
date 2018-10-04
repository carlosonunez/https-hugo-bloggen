FROM alpine
ARG HUGO_VERSION
RUN \
  if ! test -n "$HUGO_VERSION"; \
  then \
    >&2 echo "ERROR: Please provide a Hugo version."; \
    exit 1; \
  fi
ENV HUGO_URL=https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
ADD $HUGO_URL /tmp/hugo.tar.gz
RUN tar -xvf /tmp/hugo.tar.gz -C /usr/bin/
EXPOSE 1313
WORKDIR /site
CMD [ "sh", "-c" ]
