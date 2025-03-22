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

# Get server products for each nodepool with different CPU/memory combinations
data "ncloud_nks_server_products" "product" {
  for_each      = { for idx, pool in var.nks_nodepools : idx => pool }
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone          = var.zone

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }

  filter {
    name   = "cpu_count"
    values = [each.value.cpu_count]
  }

  filter {
    name   = "memory_size"
    values = [each.value.memory_size]
  }
}

# Create nodepool for each entry in the nks_nodepools variable
resource "ncloud_nks_node_pool" "node_pool" {
  for_each        = { for idx, pool in var.nks_nodepools : idx => pool }
  cluster_uuid    = ncloud_nks_cluster.cluster.uuid
  node_pool_name  = each.value.name
  node_count      = each.value.node_count
  software_code   = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code = data.ncloud_nks_server_products.product[each.key].products.0.value
  storage_size    = each.value.storage_size
  
  dynamic "autoscale" {
    for_each = each.value.autoscale != null ? [each.value.autoscale] : []
    content {
      enabled = autoscale.value.enabled
      min     = autoscale.value.min
      max     = autoscale.value.max
    }
  }
  
  dynamic "label" {
    for_each = each.value.labels != null ? each.value.labels : []
    content {
      key   = label.value.key
      value = label.value.value
    }
  }
}
#endregion
