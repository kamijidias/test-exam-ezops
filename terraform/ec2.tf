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
  count                  = 1
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
  key_name   = "test-andrew-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuDNkLuKIH3pdFCg+9KpyG+oOVBRnsa7vTDkm4ESFAQSarEPaz0GRhHtcG8jjRFoFJVMqK3C/ocM8g0ICp17XghmLfcTIlFq3s9U1PTAAvfnBqqI+kLdgtoibAnTX0fgD1Cvok/UVkgfNyGxrq0UFk1GRjqceeRDKwjQXjbzMqxavk/zDAFofhcNf357e0m9V1EV7DGpZkhOEGFTA+02++x0evg0IvKPqqYmZp3vLrnd1HnwD7CQxLHzd1mXpEvPnHEuO45AnucytBXA97+LUCbY7xhXausWak78l3Q+RZ6NnOYyymSjTmPtsjgCgLa736UfVxM6vwiK9yczaH6edd90t6wQ6t6QBh/MYzgkD/DVTJ5yTcbS/09TMLpqbnexkoZjs3My4WX9WhOe6jfzNg9EVphSAueYmaS1o4iGJLFObTcr/tDyyhvpcQLwqTP7pq9cEZ6MjSG3YEPKrAE49Rt0WwCQdRGogqymEBoBX4R0vOcPKg/lhVqlJ8Jvl0gIM7vezsHdMn5bslWmm6AWxMS2H6iXC6fAeXbzg8ud9wdzIN8dzJKXWDsL5JSGFJ4m+WZaxh5BGf4qGMkJm6lIVv7T72p7BtrQLoZkP398CISE0Wb0rq9bY1SjhJSz6thMZGiOZ8e7Bbk3UzfTRtPB6hDv1ioJ8KFWwPAXdY2G6LJw== kamijidev@gmail.com"
}