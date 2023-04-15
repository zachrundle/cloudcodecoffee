terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cybershady"

    workspaces {
      name = "cloudcodecoffee"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.51.0"
    }
  }
}
