provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account]


  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account}:role/svc_terraform"
    session_name = "Terraform"
  }

  default_tags {
    tags = {
      created_by = "terraform"
      name       = terraform.workspace
    }
  }
}
