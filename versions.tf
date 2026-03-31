terraform {
  required_providers {
    aws = {
      version = ">= 3.33.0, <= 4.34.0"
      source  = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
