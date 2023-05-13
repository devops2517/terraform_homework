provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "VM" {
  ami           = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  root_block_device {
    volume_size = var.root_volume_size
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = var.data_volume_size
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "root_volume_size" {
  default = 8
}

variable "data_volume_size" {
  default = 20
}