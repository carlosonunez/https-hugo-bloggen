FROM alpine
RUN apk update && apk add --no-cache hugo git && mkdir /site
EXPOSE 1313
WORKDIR /site
CMD [ "sh", "-c" ]
