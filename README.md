# Terraform Domain Redirect
Terraform module for redirecting requests from one domain to another.

This is a purely serverless solution that runs on:

* AWS API Gateway
* AWS Lambda

## Requirements
This module requires that:

* The source domain (the domain to redirect) already exists
* An ACM certificate exists for the bare domain (e.g. example.com) and the subdomain wildcard (e.g. *.example.com)


## Usage
```hcl
module "james-ridgeway-co-uk-redirect" {
  source = "github.com/jamesridgway/terraform-domain-redirect"

  source_domain = "james-ridgeway.co.uk"
  destination_address = "https://www.jamesridgway.co.uk"

  providers = {
    aws.use1 = "aws.use1"
  }
}
```