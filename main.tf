provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "build" {
  ami = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install git -y
              git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
              cd boxfuse-sample-java-war-hello
              ./mvnw package aws-maven -DartifactId=hello -Dversion=1.0 -Denvironment=prod -Daws.region=${var.region}
              aws s3 cp target/hello-1.0.war s3://${var.bucket_name}/hello-1.0.war
              EOF
}

resource "aws_instance" "app" {
  ami = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install tomcat tomcat-webapps -y
              aws s3 cp s3://${var.bucket_name}/hello-1.0.war /usr/share/tomcat/webapps/hello.war
              sudo systemctl enable tomcat
              sudo systemctl start tomcat
              EOF
}

variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "terraform-my-bucket"
}