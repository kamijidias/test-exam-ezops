resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "MainRouteTable"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetB"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no = 100
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0 
    to_port     = 65535
  }

  ingress {
    rule_no = 101
    protocol    = "udp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 65535
  }

  ingress {
    rule_no = 102
    protocol    = "icmp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 255
  }
  egress {
    rule_no = 100
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "AllowAllACL"
  }
}

resource "aws_network_acl_association" "public" {
  subnet_id     = aws_subnet.public.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_network_acl_association" "main" {
  subnet_id     = aws_subnet.main.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_instance" "master" {
  ami                    = "ami-0e472ba40eb589f49"
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ec2_key_name

  user_data = "${file("../${path.root}/kubernetes/master-setup.sh")}"
  tags = {
    Name = "test-andrew-kubernetes-master"
  }
}

resource "aws_instance" "worker" {
  count                  = 2
  ami                    = "ami-0e472ba40eb589f49"
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ec2_key_name

  user_data = "${file("../${path.root}/kubernetes/worker-setup.sh")}"

  tags = {
    Name = "test-andrew-kubernetes-worker-${count.index + 1}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "test-andrew-key-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsshhYGvW+DUHdP4eT3QDecReL8+a0rHK4TbAnzk3Gv1LMX4rDs0kflKyRbUQVPcaq1tUfJ8QSupop/Gx6V+JVxvS3kOAJnNiLkfOtlxczbUMUf0e6I5MV6LtF/ZqGiNPp8hgDXTpkgIFx0uF1lg31q7o9HfO0ts70l6S9j8snNTBFVxiahAHFJyMKylNTh0y8RbPBwirBLh1WGhlqszGFNVjY4IECUiilyz/y4sVzhAYSp3AL4t4HbJ6580M6Gzbew0/NhLk0E4I5tbwoNOYI6hHnSV3VXZwmEIWi2Jstg+AD2YC2UJHcbOhj4mVwk2G7Lcuajnwyyj1sRiTE+6jpZGhGkn9u5xn7cFG82oF9O6pSNAfNEDnohgLEllPfFUlhPmQjmAc1ZBr/sxFl6apDYRJ7i9ZUEHUIQW7ZcGrZKzYi5tqUMnx/zi7/1DjsfKZ95Ee5qRJNUUKGaxfW5yIURfbxdVdrgJ2faFBVAX7ZKGyyHTu1OMaPEYtQpgTrdLz0cIF2Wpq0ryH/25zOctiXc32Hmpmi/NODTAjUGWc3WXL6wKqmp03yoy5Lb9xUX4d2mRuXhVJsozt1+YVT+zk/GgxOe6je5lyU493gNK0Bs7KbA/fs3wh57E7p7J0thkSp2ZrFLbSjzEEFEl8ctJbtt0YJR8I8MceZB+JU0O9WJw== user@DESKTOP-U7USJN6"
}