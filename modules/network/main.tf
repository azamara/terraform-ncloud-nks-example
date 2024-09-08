terraform {
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.19"
    }
  }
}

# Guide: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/blob/main/docs/resources/vpc.md
# Example: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/tree/main/examples/vpc/scenario01
resource "ncloud_vpc" "tf_vpc" {
  name            = var.vpc_name
  ipv4_cidr_block = var.vpc_cidr
}

output "tf_vpc" {
  value = ncloud_vpc.tf_vpc
}

#region MARK: NAT Gateway
# Guide: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/blob/main/docs/resources/nat_gateway.md
# Example: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/tree/main/examples/nat_gateway
resource "ncloud_subnet" "tf_natgw_subnet" {
  vpc_no         = ncloud_vpc.tf_vpc.id
  network_acl_no = ncloud_vpc.tf_vpc.default_network_acl_no
  zone           = var.zone
  subnet         = var.natgw_subnet_cidr
  name           = var.natgw_subnet_name
  subnet_type    = "PUBLIC"
  usage_type     = "NATGW"
}

resource "ncloud_nat_gateway" "nat_gateway" {
  vpc_no    = ncloud_vpc.tf_vpc.id
  subnet_no = ncloud_subnet.tf_natgw_subnet.id
  zone      = var.zone
  name      = var.natgw_name
}

data "ncloud_route_table" "route_table" {
  vpc_no                = ncloud_vpc.tf_vpc.id
  supported_subnet_type = "PRIVATE"
  filter {
    name   = "is_default"
    values = ["true"]
  }
}

resource "ncloud_route" "route" {
  route_table_no         = data.ncloud_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.nat_gateway.name
  target_no              = ncloud_nat_gateway.nat_gateway.id
}
#endregion
