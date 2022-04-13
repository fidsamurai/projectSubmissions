data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
  id = var.vpc_id
}

resource "aws_security_group" "SSH" {
  name = "SSH Fid Home"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH Fid"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops"
  }
}

resource "aws_instance" "pgpDemo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.micro"
  key_name = "devops"
  vpc_security_group_ids = aws_security_group.SSH.id

  user_data = <<EOD
#!/bin/bash
sudo apt update && sudo apt install openjdk-11-jdk -y
sudo apt install python3 python3-pip
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee -a /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

EOD

  tags = {
    Name = "pgpDevops"
    Env = "pgpDevops"
  }
}
