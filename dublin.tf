resource "aws_key_pair" "windler47-sobes-west" {
    key_name   = "windler47-sobes-west"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3e2ypIEZuryUCwPzHaI+L/gXPRVy7Vi1P3XpJyxYyDtkukFS7PBG0nFdzvBbOpnKZ54hURklO2N6z19PfY9vK5oWNfGyKNLAndcR/pBkrFNopbt5oGNBsH8Hi3GxURFQmRsr7LKN/YiOXfidv+icB/rwmwMinX+RqIYOjqc0s2Wrlp2akbOLrth+HCgLQAOFlld0RXXuKf9LawHo8MbMQGU/LENht5vjmDHeA5iOLW58rJV7vSfx7R8qCXXJ3nglxnWLYbAZWDEz+gQkNJ7dWyfKG3U/aoGymRQFgxWqf6WE8CCgB6G4GWIALboob882ob150DirBSBTcVXGlpEoE0TT2lcfNYuybJWHoJLC/V+pnW7TteIOooZUVJnB1Cgvr+IRpS2weQOEHMlaZKpU9oc/8icTHI+A1jqRFdcAF+Y3CkVg7qDHM4iHK3mDT3cPJwZkQHn7dry+/YCq69gbdBRoFgzqE0Q1pM+bFBKNj4HLniQoCGurDnKV00dE/M/0= windler47@sobes"
    
    provider = aws.eu-west-1
}

module "eu-west-1-net" {
    source = "./modules/network"
    vpc_network 	= "10.20.0.0/16"
    vpc_subnet	= "10.20.10.0/24"
    
    providers = {
      aws = aws.eu-west-1
    }
}

resource "aws_internet_gateway" "sobes_windler47_gateway_west" {
    vpc_id = module.eu-west-1-net.vpc_id
    provider = aws.eu-west-1
}

resource "aws_route" "internet_access_west" {
    route_table_id         = module.eu-west-1-net.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.sobes_windler47_gateway_west.id
    provider = aws.eu-west-1
}

module "eu-west-1-instance" {
    source 	= "./modules/host"
    subnet_id = module.eu-west-1-net.subnet_id
    security_groups = [module.eu-west-1-net.ssh_security_group_id, module.eu-west-1-net.icmp_security_group_id]
    key_name = aws_key_pair.windler47-sobes-west.key_name
    
    providers = {
      aws = aws.eu-west-1
    }
}

module "eu-west-1-vpn-client" {
    source = "./modules/vpn-client"
    name   = "ireland"
    subnet_id = module.eu-west-1-net.subnet_id
    security_groups = [module.eu-west-1-net.ssh_security_group_id, module.eu-west-1-net.icmp_security_group_id, module.eu-west-1-net.vpn_security_group_id]
    key_name = aws_key_pair.windler47-sobes-west.key_name

    providers = {
      aws = aws.eu-west-1
    }
}

resource "aws_route" "frankfurt_route" {
    route_table_id            = module.eu-west-1-net.main_route_table_id
    destination_cidr_block    = "10.10.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.sobes_windler47_peering.id

    provider = aws.eu-west-1
}

resource "aws_eip" "sobes_windler47_lb_west" {
    instance = module.eu-west-1-vpn-client.instance_id
    provider = aws.eu-west-1
}