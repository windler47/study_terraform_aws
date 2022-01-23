resource "aws_key_pair" "windler47-sobes-central" {
  key_name   = "windler47-sobes-central"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3e2ypIEZuryUCwPzHaI+L/gXPRVy7Vi1P3XpJyxYyDtkukFS7PBG0nFdzvBbOpnKZ54hURklO2N6z19PfY9vK5oWNfGyKNLAndcR/pBkrFNopbt5oGNBsH8Hi3GxURFQmRsr7LKN/YiOXfidv+icB/rwmwMinX+RqIYOjqc0s2Wrlp2akbOLrth+HCgLQAOFlld0RXXuKf9LawHo8MbMQGU/LENht5vjmDHeA5iOLW58rJV7vSfx7R8qCXXJ3nglxnWLYbAZWDEz+gQkNJ7dWyfKG3U/aoGymRQFgxWqf6WE8CCgB6G4GWIALboob882ob150DirBSBTcVXGlpEoE0TT2lcfNYuybJWHoJLC/V+pnW7TteIOooZUVJnB1Cgvr+IRpS2weQOEHMlaZKpU9oc/8icTHI+A1jqRFdcAF+Y3CkVg7qDHM4iHK3mDT3cPJwZkQHn7dry+/YCq69gbdBRoFgzqE0Q1pM+bFBKNj4HLniQoCGurDnKV00dE/M/0= windler47@sobes"
}

module "eu-central-1-net" {
    source 	= "./modules/network"
    vpc_network 	= "10.10.0.0/16"
    vpc_subnet	= "10.10.10.0/24"
}

resource "aws_internet_gateway" "sobes_windler47_gateway" {
    vpc_id = module.eu-central-1-net.vpc_id
}

resource "aws_route" "internet_access" {
    route_table_id         = module.eu-central-1-net.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.sobes_windler47_gateway.id
}

resource "aws_route" "ireland_route" {
  route_table_id            = module.eu-central-1-net.main_route_table_id
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.sobes_windler47_peering.id
}

module "eu-central-1-instance" {
    source 	= "./modules/host"
    subnet_id = module.eu-central-1-net.subnet_id
    security_groups = [module.eu-central-1-net.ssh_security_group_id, module.eu-central-1-net.icmp_security_group_id]
    key_name = aws_key_pair.windler47-sobes-central.key_name
}

module "eu-central-1-vpn-server" {
    source 	= "./modules/vpn-server"
    name  	= "frankfurt"
    subnet_id = module.eu-central-1-net.subnet_id
    security_groups = [module.eu-central-1-net.ssh_security_group_id, module.eu-central-1-net.icmp_security_group_id, module.eu-central-1-net.vpn_security_group_id]
    key_name = aws_key_pair.windler47-sobes-central.key_name
}

resource "aws_eip" "sobes_windler47_lb" {
    instance = module.eu-central-1-vpn-server.instance_id
}
