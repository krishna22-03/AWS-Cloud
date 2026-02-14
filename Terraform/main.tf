resource "aws_vpc" "dev_vpc" { 
    cidr_block = var.cidr_block_vpc
    tags = {
     Name = var.vpc_name
  }
}

resource "aws_subnet" "default_az1" {
  cidr_block = var.cidr_block_subnet
  vpc_id = "vpc-03a5eedfd8febea09"
  tags = {
    Name = var.subnet_name
  }
}