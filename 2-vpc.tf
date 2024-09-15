resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-main"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

# Subnets

resource "aws_subnet" "private_zone_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = var.zone_1

  tags = {
    "Name"                                             = "${var.env}-private-${var.zone_1}"
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = var.zone_2

  tags = {
    "Name"                                             = "${var.env}-private-${var.zone_2}"
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = var.zone_1
  map_public_ip_on_launch = true
  tags = {
    "Name"                                             = "${var.env}-public-${var.zone_1}"
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = var.zone_2
  map_public_ip_on_launch = true
  tags = {
    "Name"                                             = "${var.env}-public-${var.zone_2}"
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

# NAT

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone_1.id
  tags = {
    Name = "${var.env}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Routes

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.env}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "private_zone_1" {
  subnet_id      = aws_subnet.private_zone_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone_2" {
  subnet_id      = aws_subnet.private_zone_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_zone_1" {
  subnet_id      = aws_subnet.public_zone_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone_2" {
  subnet_id      = aws_subnet.public_zone_2.id
  route_table_id = aws_route_table.public.id
}
