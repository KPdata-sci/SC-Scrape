resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "main_vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "Main Internet Gateway" })

}


resource "aws_subnet" "public" {
  for_each                = toset(var.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name : "Public Subnet: ${each.value}" })
}

resource "aws_subnet" "private" {
  for_each                = toset(var.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name : "Private Subnet: ${each.value}" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "Public Route Table" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(var.tags, { Name = "Private Route Table" })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "NAT Elastic IP" })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["eu-west-2a"].id

  tags = merge(var.tags, { Name : "Main Nat Gateway" })
}


resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "nal" {
  vpc_id =   aws_vpc.main.id

  ingress{
    cidr_block = "10.0.0.0/24"
    rule_no = 200
    action = "allow"
    protocol = "tcp"
    to_port = 443
    from_port =  443
  }

  egress{
    cidr_block = "10.0.0.0/24"
    rule_no = 100
    action = "allow"
    protocol = "tcp"
    to_port = 80
    from_port = 80 

  }

  tags = merge(var.tags ,{Name : "NACL"})
}


output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}



