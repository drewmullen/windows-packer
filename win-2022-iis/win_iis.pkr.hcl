packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.3"
    }
  }
}

# https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "windows" {
  ami_name      = var.ami_name
  instance_type = "t3.medium"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl  = true
  winrm_insecure = true

  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  user_data_file = "winrm_bootstrap.txt"
}

build {
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    script = "install.ps1"
  }

  provisioner "powershell" {
    inline = [
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' reset --block",
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' sysprep --shutdown --block"
    ]
  }
}