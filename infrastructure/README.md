Welcome to the `infrastructure` folder! This is where you can add support
for any cloud vendor that you'd like to use!

## Using Terraform

This project uses [Terraform Open-Source](https://hashicorp.com/terraform) to
deploy infrastructure. Click the link to learn more about this tool. This
`README` assumes that the reader has prior knowledge.

## Directory Structure

First, create a directory structure like this:

```
infrastructure/
└── $cloud_provider
    ├── backend.tfvars.tmpl
    ├── terraform.tfvars.tmpl
    ├── provider.tf
    ├── variables.tf
    ├── other_terraform_code.tf
```

### Files

This blog makes use of a few [`gomplate`](https://github.com/hairyhenderson/gomplate)
templates for defining infrastructure metadata.

You can see examples of each in the `aws` directory.

* `backend.tfvars.tmpl`: Configuration variables for your Terraform `backend`.
* `terraform.tfvars.tmpl`: Values for Terraform variables defined in `variables.tf`
* `variables.tf`: Variables to use for your Terraform stack.
* `provider.tf`: Configuration data for your Terraform `provider`, such as access keys and access profiles.

## Testing

We currently do not support unit tests for Terraform infrastructure, though this
might be incorporated in a future release. For now, you can run
`make validate` to validate your Terraform syntax.
