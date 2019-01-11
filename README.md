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
