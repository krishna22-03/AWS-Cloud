resource "aws_vpc" "dev_vpc" { 
    cidr_block = var.cidr_block_vpc
    tags = {
     Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.cidr_block_subnet
    availability_zone = "us-east-1a"

    tags = {
        Name = var.subnet_name
    }
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.dev_vpc.id 
    tags = {
        Name = var.igw_name
    }
}

resource "aws_route_table" "TF_RT"{
    vpc_id = aws_vpc.dev_vpc.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }

    tags = {
        Name = var.TF_route_table_name
    }
}

resource "aws_security_group" "TF_sg" {
    vpc_id = aws_vpc.dev_vpc.id 
    name = var.TF_sg_name
    description = "Allow SSH access"

    ingress {
        description = "ssh from anywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "ssh_sg"
    }
}

resource "aws_key_pair" "TF_key" {
    key_name = "TF-key"
    public_key = file("id_rsa.pub")
}

data "aws_ami" "debian" {
  most_recent = true

  owners = ["136693071363"] # Debian official

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "debian_ec2" {
  ami           = data.aws_ami.debian.id
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.TF_sg.id]
  key_name               = aws_key_pair.TF_key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "debian-ansible-target"
  }
}

