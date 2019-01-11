[![Build Status](https://travis-ci.org/carlosonunez/https-hugo-bloggen.svg?branch=master)](https://travis-ci.org/carlosonunez/https-hugo-bloggen)

Easily deploy your HTTPS-enabled, S3-backed Hugo blogs!

# How can I use this?

1. Ensure that your repository conforms to [Hugo's standards](https://gohugo.io/getting-started/directory-structure/).
2. Clone this repository.
3. Create an environment file: `make create_env`. Fill in the values shown in the
   newly-created `.env` file. You can also fetch this from S3c
4. Deploy your blog: `make deploy`.

# Required environment variables (outside of .env)

# Environment variables that you can optionally set

- *`DOTENV_S3_BUCKET`*: Define this to fetch your environment file from S3.
  You will also need to define `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
  and `AWS_REGION`.
