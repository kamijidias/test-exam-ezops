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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDRd8bUHNJ6pgUDfspYSG5ynDTYu0tvoI1oBl6pftcillF2vPtnlNnuSB/Q6DDr1iTcBINy9oZV2YguzpD2YANhzyWDB0miwDPCP9XCsBzD9Q7u9tOCsa/12RZTFkhiVGenITtaCDuYGkMQx63UkaIz8jyG8zqvGRm6n6a+J8KZnnC3OT7haHPFX/Xtk1KR7qlENzCEaf8bapBA7ZqUMw0va7cPsfQnKlp0TYmfjvlrtY7tPNHLN22eAADk6niLiY/iNn+78oWqvwMN1ZprCC6Jv/L7RwgMsN9p0dNOKsxPdxf5EbpnI12HTHihpg0KQ9WznWtdx0v7fmzmdakSkGd kamijidev@gmail.com"
}
