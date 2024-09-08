terraform {
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.19"
    }
  }
}

#region MARK: SVC Subnets
# Guide: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/blob/main/docs/resources/subnet.md
# Example: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/tree/main/examples/vpc/scenario01
resource "ncloud_subnet" "tf_private_subnet_1" {
  vpc_no         = var.vpc_no
  zone           = var.zone
  network_acl_no = var.network_acl_no
  subnet         = var.nks_subnet_cidr
  name           = var.nks_subnet_name
  subnet_type    = "PRIVATE"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "tf_private_lb_subnet" {
  vpc_no         = var.vpc_no
  zone           = var.zone
  network_acl_no = var.network_acl_no
  subnet         = var.nks_lb_subnet_cidr
  name           = var.nks_lb_subnet_name
  subnet_type    = "PRIVATE"
  usage_type     = "LOADB"
}

resource "ncloud_subnet" "tf_public_lb_subnet" {
  vpc_no         = var.vpc_no
  zone           = var.zone
  network_acl_no = var.network_acl_no
  subnet         = var.nks_pub_lb_subnet_cidr
  name           = var.nks_pub_lb_subnet_name
  subnet_type    = "PUBLIC"
  usage_type     = "LOADB"
}
#endregion

#region MARK: Kubernetes Service
# Guide: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/blob/main/docs/resources/nks_cluster.md
# Example: https://github.com/NaverCloudPlatform/terraform-provider-ncloud/tree/main/examples/nks
data "ncloud_nks_versions" "version" {
  hypervisor_code = "KVM"
  filter {
    name   = "value"
    values = [var.nks_version]
    regex  = true
  }
}

resource "ncloud_nks_cluster" "cluster" {
  hypervisor_code      = "KVM"
  cluster_type         = "SVR.VNKS.STAND.C002.M008.G003"
  k8s_version          = data.ncloud_nks_versions.version.versions.0.value
  login_key_name       = var.login_key_name
  name                 = var.nks_service_name
  lb_private_subnet_no = ncloud_subnet.tf_private_lb_subnet.id
  lb_public_subnet_no  = ncloud_subnet.tf_public_lb_subnet.id
  kube_network_plugin  = "cilium"
  subnet_no_list       = [ncloud_subnet.tf_private_subnet_1.id]
  vpc_no               = var.vpc_no
  zone                 = var.zone
  public_network       = false
}

data "ncloud_nks_server_images" "image" {
  hypervisor_code = "KVM"
  filter {
    name   = "label"
    values = [var.nks_server_image]
    regex  = true
  }
}

data "ncloud_nks_server_products" "product" {
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone          = var.zone

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["4GB"]
  }
}

resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid     = ncloud_nks_cluster.cluster.uuid
  node_pool_name   = "pool1"
  node_count       = 1
  software_code    = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code = data.ncloud_nks_server_products.product.products.0.value
  storage_size     = 200
  autoscale {
    enabled = false
    min     = 0
    max     = 0
  }
  label {
    key   = "foo"
    value = "bar"
  }
}
#endregion
