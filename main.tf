locals {
  vpc_cidr = "10.0.0.0/16"

  public_cidr = ["10.0.0.0/24", "10.0.1.0/24"]

  private_cidr = ["10.0.2.0/24", "10.0.3.0/24"]

  availability_zones = ["us-east-1a", "us-east-1b"]

  public_RT_ass = 2
  
  private_RT_ass = 2
  
  private_RT = 2

  ct_eip = 2
  
  nat_gates = 2
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
}

resource "aws_subnet" "public" {
  count = length(local.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]

  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "public${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "private${count.index+1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = local.public_RT_ass

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = local.ct_eip

  vpc = true
}

resource "aws_nat_gateway" "nat" {
  count = local.nat_gates 

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  count = local.private_RT

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count = local.private_RT_ass

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}








