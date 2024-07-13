resource "aws_instance" "k3s_master" {
  ami                    = "ami-0e472ba40eb589f49"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "test-andrew-k3s"
  }
}