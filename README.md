[![Codacy Badge](https://api.codacy.com/project/badge/Grade/bcf3a13678a24c8bae2160e1ff69d0d5)](https://www.codacy.com/app/OpenDevSecOps/terraform-aws-honeytoken?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=opendevsecops/terraform-aws-honeytoken&amp;utm_campaign=Badge_Grade)
[![Follow on Twitter](https://img.shields.io/twitter/follow/opendevsecops.svg?logo=twitter)](https://twitter.com/opendevsecops)

# AWS Honey Token Terraform Module

Terraform which create honey tokens and supporting infrastructure.

## Getting Started

Getting started is easy. Here is a complete example:

```terraform
module "honeytoken" {
  source = "opendevsecops/honeytoken/aws"

  user_name = "honey"

  trail_bucket_name = "${var.slack_notification_url}"

  slack_notification_url = "${var.slack_notification_url}"
}
```

The module is automatically published to the Terraform Module Registry. More information about the available inputs, outputs, dependencies and instructions how to use the module can be found at the official page [here](https://registry.terraform.io/modules/opendevsecops/honeytoken).
