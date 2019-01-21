[![Build Status](https://travis-ci.org/carlosonunez/https-hugo-bloggen.svg?branch=master)](https://travis-ci.org/carlosonunez/https-hugo-bloggen)

Easily deploy your HTTPS-enabled, S3-backed Hugo blogs!

# How can I use this?

1. Ensure that your repository conforms to [Hugo's standards](https://gohugo.io/getting-started/directory-structure/).
2. Clone this repository.
3. Create an environment file: `make create_env`. Fill in the values shown in the
   newly-created `.env` file. You can also fetch this from S3c
4. Deploy your blog: `make deploy`.

# Using this with CI

If you're using this to continuously deploy your blog, do the following before
having your builder clone this repository:

- Remove any `docker-compose.yml` and `Makefile` files present at the root
  of your directory: `rm -f docker-compose.yml Makefile`

# Rendering your blog locally

## Without Docker

To render your blog locally, use this Make command: `make start_local_blog`.

## With Docker

1. Clone this repository: `git clone https://github.com/carlosonunez/https-hugo-bloggen`
2. Build the Docker image within: `docker build -t bloggen https-hugo-bloggen`
3. Run `make start_local_blog`, but export your working directory with the
   `HOST_PWD` environment variable so that nested containers know where to 
   find your contents:

   ```bash
   docker run -e HOST_PWD=$PWD \
    -v "$PWD/https-hugo-bloggen:/app" \
    -v "$PWD/posts:/app/posts" \
    -v "$PWD/layouts:/app/layouts" \
    -v "$PWD/static:/app/static" \
    -v "$PWD/config.toml.tmpl:/app/config.toml.tmpl" \
    -w /app \
    -p 8080:8080 \
    --net host \
    --name blog \
    bloggen start_local_blog
  ```

*NOTE*: You might find it easier to use Docker Compose for this. Also, consider
adding `https-hugo-bloggen` to your `.gitignore` if you intend on always
using the latest version.

*NOTE*: `--net=host` is required so that the port allocated by the nested
Hugo container is made accessible to your host. If you are using 8080 for
something else, choose another port.

*NOTE*: To see the directory structure created by Hugo, use this command:
`docker exec -it blog sh -c "ls /app/site"`

# Remote environment files

You can fetch remote environment dotfiles by using special environment variables
or an `.env_info` file in the toplevel of your repository. Supported backends
are documented below.

## S3

To fetch environment variables from a S3 bucket, define `DOTENV_S3_BUCKET` or
specify the bucket containing your dotfiles in `.env_info`. Note that you will
also need to specify an AWS `.credentials` file or define `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY` and `AWS_REGION` for this to work.

# Using a CDN

This blog generator can create a content delivery network for you for your
readers to enjoy consistently-fast access to your blog from anywhere in the world.
Supported providers are defined below.

**NOTE**: *This might cost you money!*

## CloudFront

To enable AWS CloudFront, set `ENABLE_CLOUDFRONT_CDN` in your `.env` to `true`.
