module "nginx_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "nginx"

  instance_type               = "t3.micro"
  ami                         = "ami-0a116fa7c861dd5f9"
  key_name                    = aws_key_pair.default.key_name
  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  associate_public_ip_address = true
  security_group_name         = "nginx"
  user_data = templatefile("${path.module}/docker.sh.tpl", {
    private_ip = module.php_instance.private_ip
  })
  metadata_options = { instance_metadata_tags = "enabled" }
  root_block_device = {
    size = 12
  }

  security_group_ingress_rules = {
    ssh = {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    http = {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "php_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "php"

  instance_type               = "t3.micro"
  ami                         = "ami-0a116fa7c861dd5f9"
  key_name                    = aws_key_pair.default.key_name
  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  associate_public_ip_address = true
  security_group_name         = "php"
  user_data                   = file("docker.sh")
  metadata_options            = { instance_metadata_tags = "enabled" }
  root_block_device = {
    size = 12
  }
  security_group_ingress_rules = {
    ssh = {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    nginx = {
      description                  = "Allows port on nginx"
      from_port                    = 9000
      to_port                      = 9000
      protocol                     = "tcp"
      referenced_security_group_id = module.nginx_instance.security_group_id
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

/*module "mysql" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "mysql"

  instance_type               = "t3.micro"
  ami                         = "ami-000d9d5f270bfcd0e"
  key_name                    = aws_key_pair.default.key_name
  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  associate_public_ip_address = true
  security_group_name         = "php"
  security_group_ingress_rules = {
    ssh = {
      description = "Allow SSH"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}*/

resource "tls_private_key" "RSA" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = "demo"
  public_key = tls_private_key.RSA.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.RSA.private_key_pem
  filename        = "${path.module}/demo.pem"
  file_permission = "0400"
}
