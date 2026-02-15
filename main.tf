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