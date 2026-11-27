# network
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
##########################################################################
# public subnet
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "public_subnet_1" {
  tags = {
    Name = "cloud-project-public-subnet-1"
  }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}
resource "aws_subnet" "public_subnet_2" {
  tags = {
    Name = "cloud-project-public-subnet-2"
  }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
}
# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-internet_gateway"
  }
}
#route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-public-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
#network security and access control
resource "aws_network_acl" "public_subnet_acl" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-public-nacl"
  }
  #load balncer
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  #app subnet
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  #nat gateway for app subnet
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  #nat gateway for data base
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  #nat gateway
  egress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
}
resource "aws_network_acl_association" "public_subnet_1_acl_association" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_network_acl_association" "public_subnet_2_acl_association" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

##########################################################################
#private application subnet
resource "aws_subnet" "private_app_subnet" {
  tags = {
    Name = "cloud-project-private-app-subnet"
  }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
}
#route table for private application subnet
resource "aws_route_table" "private_app_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-private-app-route-table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
resource "aws_route_table_association" "private_app_subnet_association" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_app_route_table.id
}
#network security and access control for private application subnet
resource "aws_network_acl" "private_app_subnet_acl" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-private-app-nacl"
  }
  #load balancer
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  #load balncer 2
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.4.0/24"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.4.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  #data base
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 3306
    to_port    = 3306
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 32768
    to_port    = 60999
  }
  #nat gateway
  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
}
resource "aws_network_acl_association" "private_app_subnet_acl_association" {
  network_acl_id = aws_network_acl.private_app_subnet_acl.id
  subnet_id      = aws_subnet.private_app_subnet.id
}

##########################################################################
#private database subnet
resource "aws_subnet" "private_db_subnet" {
  tags = {
    Name = "cloud-project-private-db-subnet"
  }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_db_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
}
#route table for private database subnet
resource "aws_route_table" "private_db_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-private-db-route-table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
resource "aws_route_table_association" "private_db_subnet_association" {
  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_db_route_table.id
}
#network security and access control for private database subnet
resource "aws_network_acl" "private_db_subnet_acl" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "cloud-project-private-db-nacl"
  }
  #app subnet
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 3306
    to_port    = 3306
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 32768
    to_port    = 65535
  }
  #nat gateway
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
}
resource "aws_network_acl_association" "private_db_subnet_acl_association" {
  network_acl_id = aws_network_acl.private_db_subnet_acl.id
  subnet_id      = aws_subnet.private_db_subnet.id
}
##########################################################################

#Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "cloud-project-nat-eip"
  }
}
#nat gateway for both private app nd database
resource "aws_nat_gateway" "nat_gateway" {
  tags = {
    Name = "cloud-project-nat-gateway"
  }
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.nat_eip.id
}