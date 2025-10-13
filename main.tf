terraform {
  backend "s3" {
    bucket       = "apryma-playground-tf-state-bucket"
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
