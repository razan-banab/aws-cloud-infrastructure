#AMI data source
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
  owners = ["099720109477"]
}
#Application EC2 instance
resource "aws_instance" "app_EC2" {
  tags = {
    Name = "cloud-project-app-server"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }
  private_ip                  = "10.0.2.10"
  instance_type               = "t4g.small"
  ami                         = data.aws_ami.ubuntu.id
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  subnet_id                   = aws_subnet.private_app_subnet.id
  vpc_security_group_ids      = [aws_security_group.APP_SG.id]
  associate_public_ip_address = false
}

#Database EC2 instance
resource "aws_instance" "DB_EC2" {
  tags = {
    Name = "cloud-project-database-server"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }
  private_ip                  = "10.0.3.10"
  instance_type               = "t4g.small"
  ami                         = data.aws_ami.ubuntu.id
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  subnet_id                   = aws_subnet.private_db_subnet.id
  vpc_security_group_ids      = [aws_security_group.DB_SG.id]
  associate_public_ip_address = false
}
