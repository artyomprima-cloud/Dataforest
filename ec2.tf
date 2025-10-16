variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "Ubuntu 22.04 LTS"
  type        = string
  default     = "ami-0a116fa7c861dd5f9"
}

variable "php_private_ip" {
  type        = string
  description = "Static private IP for PHP instance"
  default     = "10.0.1.100"
}

module "nginx_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "${var.environment}-nginx"
  instance_type               = var.instance_type
  ami                         = var.ami
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  associate_public_ip_address = true
  security_group_name         = "${var.environment}-nginx-sg"

  user_data = templatefile("${path.module}/docker.sh.tpl", {
    private_ip = module.php_instance.private_ip
  })

  metadata_options  = { instance_metadata_tags = "enabled" }
  root_block_device = { size = 12 }

  security_group_ingress_rules = {
    http = {
      description    = "Allow only through cloudfront"
      from_port      = 80
      to_port        = 80
      protocol       = "tcp"
      prefix_list_id = "pl-a3a144ca"
    }
  }

  tags = var.tags
}

module "php_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                 = "${var.environment}-php"
  instance_type        = var.instance_type
  ami                  = var.ami
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id            = tolist(module.vpc.private_subnets)[0]
  private_ip           = var.php_private_ip
  security_group_name  = "${var.environment}-php-sg"
  user_data            = file("${path.module}/docker.sh.tpl")
  metadata_options     = { instance_metadata_tags = "enabled" }
  root_block_device    = { size = 12 }
  security_group_ingress_rules = {
    nginx = {
      description                  = "Allows port on nginx"
      from_port                    = 9000
      to_port                      = 9000
      protocol                     = "tcp"
      referenced_security_group_id = module.nginx_instance.security_group_id
    }
  }

  tags = var.tags
}

module "mysql" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                 = "${var.environment}-mysql"
  instance_type        = var.instance_type
  ami                  = var.ami
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id            = tolist(module.vpc.private_subnets)[0]
  security_group_name  = "${var.environment}-mysql-sg"
  user_data            = file("${path.module}/mysql.sh.tpl")
  security_group_ingress_rules = {
    mysql = {
      description                  = "Open MySQL port to PHP"
      from_port                    = 3306
      to_port                      = 3306
      protocol                     = "tcp"
      referenced_security_group_id = module.php_instance.security_group_id
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
