terraform {
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.19"
    }
  }
}

resource "ncloud_login_key" "loginkey" {
  key_name = var.login_key_name
}

output "login_key_name" {
  value = ncloud_login_key.loginkey.key_name
}
