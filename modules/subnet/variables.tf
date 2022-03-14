
variable subnet_cidr_block{
    description= "CIDR block for aws subnet"
}

variable availability-zones{
    description= "Availability zones for aws subnets"
}

variable env_prefix{
    description= "env zones to deploy"
}

variable vpc_id{}
variable default_route_table_id{}
