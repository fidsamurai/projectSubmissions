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

resource "aws_vpc" "devops" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "devops" {
  vpc_id            = aws_vpc.devops.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "devops" {
    vpc_id = aws_vpc.devops.id

    tags = {
      Name = "devops"
    }
}

resource "aws_default_route_table" "devops" {
    default_route_table_id = aws_vpc.devops.default_route_table_id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.devops.id
    }

    tags = {
      Name = "devopsRT"
    }
}

resource "aws_security_group" "SSH" {
  name = "SSH Fid Home"
  vpc_id=aws_vpc.devops.id

  ingress {
    description = "SSH Fid"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "jenkins Fid"
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Project2"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "devops"
  }
}

resource "aws_instance" "pgpDemo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.micro"
  subnet_id = aws_subnet.devops.id
  associate_public_ip_address = true
  key_name = "devops"
  vpc_security_group_ids = [aws_security_group.SSH.id]

  user_data = <<EOD
#!/bin/bash
sudo apt update && sudo apt install openjdk-11-jdk -y
sudo apt install python3 python3-pip -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee -a /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl enable --now jenkins

EOD

  tags = {
    Name = "pgpDevops"
    Env = "pgpDevops"
  }
}
