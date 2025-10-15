# providers.tf
provider "aws" {
  region  = var.aws_region  # The AWS region to deploy resources
  profile = var.aws_profile # Optional: which AWS CLI profile to use
}
