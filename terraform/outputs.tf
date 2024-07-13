output "k3s_master_public_ip" {
  value = aws_instance.k3s_master.public_ip
}