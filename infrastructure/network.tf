# Create VPC:
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "CP Application VPC"
  }
}


# Get Availability Zones:
data "aws_availability_zones" "available_zones" {
  state = "available"
}


# Create Public Subnets:
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "CP Public Subnet-${count.index + 1}"
  }
}


# Create Private Subnets:
resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index +2)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.default.id
  tags = {
    Name = "CP Private Subnet-${count.index + 1}"
  }  
}


# Create Internet Gateway:
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "CP Internet Gateway"
  }    
}


# Create a Route-Table to ensure Internet Acess:
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}


# Create Elastic IP:
resource "aws_eip" "gateway" {
  count      = 2            # warum 2??
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}


# Create NAT-Gateway
resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
  tags = {
    Name = "CP NAT Gateway"
  }        
}


# Create Private Route-Table:
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
  tags = {
    Name = "CP Private Route Table"
  }   
}


# Create Route Table Association:
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}



