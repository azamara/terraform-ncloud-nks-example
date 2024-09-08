module "common" {
  source = "./modules/common"

  login_key_name = var.login_key_name
}

module "network" {
  source = "./modules/network"

  zone              = var.zone
  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  natgw_subnet_cidr = var.natgw_subnet_cidr
  natgw_subnet_name = var.natgw_subnet_name
  natgw_name        = var.natgw_name
}

module "kubernetes" {
  source = "./modules/kubernetes"

  vpc_no                 = module.network.tf_vpc.id
  network_acl_no         = module.network.tf_vpc.default_network_acl_no
  login_key_name         = var.login_key_name
  zone                   = var.zone
  nks_subnet_cidr        = var.nks_subnet_cidr
  nks_subnet_name        = var.nks_subnet_name
  nks_lb_subnet_cidr     = var.nks_lb_subnet_cidr
  nks_lb_subnet_name     = var.nks_lb_subnet_name
  nks_pub_lb_subnet_cidr = var.nks_pub_lb_subnet_cidr
  nks_pub_lb_subnet_name = var.nks_pub_lb_subnet_name
  nks_version            = var.nks_version
  nks_service_name       = var.nks_service_name
  nks_server_image       = var.nks_server_image
}
