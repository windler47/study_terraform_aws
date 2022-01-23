terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_vpc_peering_connection" "sobes_windler47_peering" {
  vpc_id   	= module.eu-central-1-net.vpc_id
  peer_vpc_id   = module.eu-west-1-net.vpc_id
  peer_region   = "eu-west-1"

  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "sobes_windler47_peering_accepter" {
  provider                  = aws.eu-west-1
  vpc_peering_connection_id = aws_vpc_peering_connection.sobes_windler47_peering.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}
