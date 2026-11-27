#security group for Application load balancer
resource "aws_security_group" "ALB_SG_v2" {
  tags = {
    Name = "cloud-project-alb-sg"
  }
  name        = "ALB-SG-v2"
  description = "Allow inbound HTTPS and HTTP to the public application load balancer"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "ALB_from_Internet" {
  security_group_id = aws_security_group.ALB_SG_v2.id
  description       = "Allow inbound HTTPS traffic from the internet to the Application Load Balancer"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"

}
resource "aws_vpc_security_group_ingress_rule" "ALB_from_Internet_HTTP" {
  security_group_id = aws_security_group.ALB_SG_v2.id
  description       = "Allow inbound HTTP traffic from the internet to the Application Load Balancer"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"

}
resource "aws_vpc_security_group_egress_rule" "ALB_to_APP" {
  security_group_id            = aws_security_group.ALB_SG_v2.id
  referenced_security_group_id = aws_security_group.APP_SG.id
  description                  = "Allow outbound HTTP traffic to application instances"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

#security group for Application instance
resource "aws_security_group" "APP_SG" {
  tags = {
    Name = "cloud-project-app-sg"
  }
  name        = "APP-SG"
  description = "Allow application instances to communicate with the database over MySQL"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "APP_from_ALB" {
  security_group_id            = aws_security_group.APP_SG.id
  referenced_security_group_id = aws_security_group.ALB_SG_v2.id
  description                  = "Allow inbound HTTP traffic from the ALB"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}
resource "aws_vpc_security_group_egress_rule" "APP_to_DB" {
  security_group_id            = aws_security_group.APP_SG.id
  referenced_security_group_id = aws_security_group.DB_SG.id
  description                  = "Allow outbound MySQL traffic to the database"

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306
}
resource "aws_vpc_security_group_egress_rule" "internet_to_app" {
  security_group_id = aws_security_group.APP_SG.id
  description       = "Allow outbound HTTPS traffic to external services"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

#security group for Database instance
resource "aws_security_group" "DB_SG" {
  tags = {
    Name = "cloud-project-db-sg"
  }
  name        = "DB-SG"
  description = "Allow inbound database connections from application instances"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "DB_from_APP" {
  security_group_id            = aws_security_group.DB_SG.id
  referenced_security_group_id = aws_security_group.APP_SG.id
  description                  = "Allow inbound MySQL connections from the application servers"

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306
}
resource "aws_vpc_security_group_egress_rule" "internet_to_db" {
  security_group_id = aws_security_group.DB_SG.id
  description       = "Allow outbound HTTPS traffic for database updates"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}