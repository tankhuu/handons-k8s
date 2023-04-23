terraform {
  required_providers {
    aws = {
      soursource = "hashicorp/aws"
      version    = "4.64.0"
    }
  }

  backend "s3" {
    bucket  = "tankhuu-terraform"
    key     = "k8s/terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
}
