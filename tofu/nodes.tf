data "aws_ami" "base" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^al2023-ami-2023.*-.*-x86_64"
}

resource "aws_instance" "manager" {
  count = var.managers

  ami                    = data.aws_ami.base.id
  instance_type          = var.manager_type
  key_name               = aws_key_pair.default.key_name
  subnet_id              = aws_subnet.public.id
  private_ip             = cidrhost(aws_subnet.public.cidr_block, 10 + count.index)
  vpc_security_group_ids = [aws_security_group.manager_node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-manager-${count.index + 1}"
  }

  lifecycle {
    ignore_changes = [
      ami,
      subnet_id,
      private_ip,
    ]
  }
}

data "aws_eip" "manager" {
  id = var.manager_eip_id
}

resource "aws_eip_association" "manager" {
  instance_id   = aws_instance.manager[0].id
  allocation_id = data.aws_eip.manager.id
}

resource "aws_instance" "worker" {
  count = var.workers

  ami                    = data.aws_ami.base.id
  instance_type          = var.worker_type
  key_name               = aws_key_pair.default.key_name
  subnet_id              = aws_subnet.private.id
  private_ip             = cidrhost(aws_subnet.private.cidr_block, 10 + count.index)
  vpc_security_group_ids = [aws_security_group.worker_node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  monitoring = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-worker-${count.index + 1}"
  }

  lifecycle {
    ignore_changes = [
      ami,
      subnet_id,
      private_ip,
    ]
  }
}

resource "variable_file" "hosts" {
  filename = "../hosts"
  content = templatefile("${path.module}/templates/hosts.tmpl",
    {
      manager = aws_instance.manager
      worker  = aws_instance.worker
    }
  )
}
