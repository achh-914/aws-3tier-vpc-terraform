# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gateway-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "main-nat-gateway"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associations for Private App Subnets
resource "aws_route_table_association" "app_assoc_1" {
  subnet_id      = aws_subnet.app_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "app_assoc_2" {
  subnet_id      = aws_subnet.app_2.id
  route_table_id = aws_route_table.private_rt.id
}
