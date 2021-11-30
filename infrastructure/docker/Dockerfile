FROM klakegg/hugo:0.89.4-alpine AS base
COPY . /site
WORKDIR /site
ENTRYPOINT [ "hugo", "server", "--port", "8080" ]
EXPOSE 8080
