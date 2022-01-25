# hugo-blog-gen

Easily create and deploy `carlosnunez.me` properties using a common format.

## Why this instead of Netlify, `hugo deploy`, etc?

I wanted to create something that:

- Doesn't rely on its state being stored on a third-party service that I don't
  control,
- Supports defaults that I would want across all of my assets, like
  support for Google Analytics, default pagination, and more,
- Allows me to control deployment semantics.

## How does Carlos use this?

> ⚠️  **NOTE** You're more than welcome to use this project to deploy
> your own blog, but your mileage may vary!

1. Ensure that your repository conforms to [Hugo's standards](https://gohugo.io/getting-started/directory-structure/).
2. Clone this repository into the blog's toplevel.
3. Copy `.env.example` from blog-gen to `.env` in your repo. Change anything that says "change me".
4. Test it locally: `./hugo-blog-gen/scripts/deploy.sh --test`
4. Deploy it: `./hugo-blog-gen/scripts/deploy.sh`

## Infrastructure Platforms

`hugo-blog-gen` uses Terraform to deploy blogs into any platform (AWS, Azure,
Kubernetes, etc.)

Here's how to create a new platform:

1. Create a new folder inside of `infrastructure` named after your provider,
   like `provider`.
2. Write a script called `authenticate.sh` that exposes environment variables
   used for authenticating Terraform to your platform's requisite Terraform
   provider.
3. Write a script called `copy.sh` that copies the contents of the blog into
   your provider's storage platform. The path will be passed in as a single
   argument.
4. Write a Docker Compose routine inside of `docker-compose.yml` for your new
   provider. Look at `terraform-aws` for an example.
5. Write a [gomplate](https://github.com/hairyhenderson/gomplate) template
   called `terraform.tfvars.tmpl` inside of your platform folder.

### Infrastructure Platform Hacks

- **Don't want to use Terraform?** Create a script called `deploy.sh` at the
  top-level of your platform provider.
- **Want to handle rendering Hugo assets yourself?** Write
  `.defer_hugo_rendering` to your provider's directory to disable rendering the
  Hugo blog within the deploy script. Use this if your provider is going to
  render or serve the blog itself (like the `docker` platform provider)

## How does this differ from `v1`?

`v1` of `hugo-bloggen` assumed that environment variables were decoupled
from blogs and stored in remote backend and used Docker in Docker to
render and deploy blogs. It was also implicitly locked to AWS despite being
designed to support more platforms.

`v2` and above assumes that your blog is bringing its own environment and uses
a single layer of Docker to do everything. This means that encrypting/protecting
environment variables is now the blog's responsibility.

## Defining Custom Configuration

- Use `sitemap.toml` to define a menu for your site.
- Use `properties.toml` to define additional configuration properties.
  This could be useful for custom themes or plugins.
