# Terraform backend configuration and AWS provider setup for Jenkins lab environment.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Use latest version if possible
    }
  }

  backend "s3" {
    bucket  = "jenkins-lab-bucket-435830281557-us-east-1-an" # your S3 bucket
    key     = "jenkins/terraform.tfstate"                    # path inside the bucket
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}