resource "aws_security_group" "k3s_sg" {
  name        = "test-andrew-k3s-sg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}