terraform {
  backend "s3" {
    bucket       = [YOUR-S3-TF-BUCKET]
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
