# variables/cloudfront.tf
variable "cloudfront_enabled" {
  description = "Whether to enable the CloudFront distribution"
  type        = bool
  default     = true
}

variable "origin_protocol_policy" {
  description = "Protocol policy for the origin"
  type        = string
  default     = "http-only"
}

variable "viewer_protocol_policy" {
  description = "Protocol policy for viewers"
  type        = string
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "HTTP methods allowed"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "HTTP methods cached"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

locals {
  origin_id = "ec2-origin"
}

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  origin = [
    {
      domain_name = module.nginx_instance.public_dns
      origin_id   = local.origin_id
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.origin_protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  default_cache_behavior = {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
  }

  enabled = true
  tags    = var.tags
}

output "domain_name_uri" {
  description = "Private IP address of the EC2 instance"
  value       = "${module.cloudfront.cloudfront_distribution_domain_name}/index.php"
}
