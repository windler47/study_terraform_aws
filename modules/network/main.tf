variable "vpc_network" {}
variable "vpc_subnet" {}

resource "aws_vpc" "sobes_windler47" {
  cidr_block = "${var.vpc_network}"
}

resource "aws_subnet" "sobes_windler47_subnet" {
  vpc_id            = aws_vpc.sobes_windler47.id
  cidr_block        = "${var.vpc_subnet}"

  tags = {
    Name = "sobes_windler47_subnet"
  }
}

resource "aws_security_group" "ssh" {
  name = "ssh"
  vpc_id      = aws_vpc.sobes_windler47.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpn" {
  name = "vpn"
  vpc_id      = aws_vpc.sobes_windler47.id
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "icmp" {
  name = "icmp"
  vpc_id      = aws_vpc.sobes_windler47.id
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ssh_security_group_id" {
    value = aws_security_group.ssh.id
}

output "icmp_security_group_id" {
    value = aws_security_group.icmp.id
}


output "vpn_security_group_id" {
    value = aws_security_group.vpn.id
}

output "vpc_id" {
    value = aws_vpc.sobes_windler47.id
}

output "subnet_id" {
    value = aws_subnet.sobes_windler47_subnet.id
}

output "main_route_table_id" {
    value = aws_vpc.sobes_windler47.main_route_table_id
}
