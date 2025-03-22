variable access_key {
  description = "Ncloud Access Key"
  type        = string
}

variable secret_key {
  description = "Ncloud Secret Key"
  type        = string
  sensitive   = true
}

variable site {
  description = "Ncloud site"
  type        = string
  default     = "pub"
}

variable region {
  description = "Ncloud region"
  type        = string
  default     = "KR"
}

variable zone {
  description = "Ncloud zone"
  type        = string
  default     = "KR-2"
}

variable login_key_name {
  description = "Ncloud login key"
  type        = string
  default     = "tf-key"
}

#region VPC
variable vpc_cidr {
  default = "10.0.0.0/16"
}
variable vpc_name {
  default = "tf-vpc"
}
#endregion

#region NAT Gateway
variable natgw_subnet_cidr {
  default = "10.0.100.192/26"
}

variable natgw_subnet_name {
  default = "tf-natgw-kr2-100-192"
}

variable natgw_name {
  default = "natgw"
}
#endregion

#region MARK: Kubernetes Service
variable nks_subnet_cidr {
  default = "10.0.1.0/24"
}

variable nks_subnet_name {
  default = "tf-private-kr2-1-0"
}

variable nks_lb_subnet_cidr {
  default = "10.0.100.0/25"
}

variable nks_lb_subnet_name {
  default = "tf-private-lb-kr2-100-0"
}

variable nks_pub_lb_subnet_cidr {
  default = "10.0.100.128/26"
}

variable nks_pub_lb_subnet_name {
  default = "tf-public-lb-kr2-100-128"
}

variable nks_version {
  default = "1.29.9"
}

variable nks_service_name {
  default = "tf-cluster"
}

variable nks_server_image {
  default = "ubuntu-22.04"
}

variable nks_nodepools {
  description = "List of nodepool configurations for NKS"
  type = list(object({
    name        = string
    node_count  = number
    cpu_count   = string
    memory_size = string
    storage_size = number
    autoscale   = optional(object({
      enabled = bool
      min     = optional(number, 0)
      max     = optional(number, 0)
    }))
    labels      = optional(list(object({
      key   = string
      value = string
    })), [])
  }))
  default = [
    {
      name        = "pool1"
      node_count  = 2
      cpu_count   = "4"
      memory_size = "8GB"
      storage_size = 200
    }
  ]
}
#endregion
