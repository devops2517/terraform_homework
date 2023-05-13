provider "aws" {
  region = "us-west-2"
}

module "instance" {
  source = "./instance"
  count = 2
}

resource "aws_instance" "instance" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  tags = {
    Name = "boxfuse-instance-${count.index + 1}"
  }

provisioner "remote-exec" {
     inline = [
       "sudo yum update -y",
       "sudo yum install -y git java-1.8.0-openjdk",
     ]
   }
 }
