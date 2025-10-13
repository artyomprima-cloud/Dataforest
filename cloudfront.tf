/*module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  origin = [
    {
      domain_name = module.nginx_instance.public_dns
      origin_id   = "ec2-origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "ec2-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  enabled = true
}
*/
