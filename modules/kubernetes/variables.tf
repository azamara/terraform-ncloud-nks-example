variable login_key_name {}
variable zone {}

variable vpc_no {}
variable network_acl_no {}
variable nks_subnet_cidr {}
variable nks_subnet_name {}
variable nks_lb_subnet_cidr {}
variable nks_lb_subnet_name {}
variable nks_pub_lb_subnet_cidr {}
variable nks_pub_lb_subnet_name {}

variable nks_version {}
variable nks_service_name {}
variable nks_server_image {}

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
