terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider principal (région Paris)
provider "aws" {
  region = "eu-west-3"
  
  default_tags {
    tags = {
      Project     = "ECOF Website"
      Environment = "stage"
      ManagedBy   = "Terraform"
    }
  }
}

# Provider pour us-east-1 (requis pour ACM avec CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "ECOF Website"
      Environment = "stage"
      ManagedBy   = "Terraform"
    }
  }
}