resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = var.name
  public_key = tls_private_key.default.public_key_openssh
}

resource "local_file" "default" {
  content  = tls_private_key.default.private_key_pem
  filename = "../id_rsa"
}
