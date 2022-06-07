# Alibaba Cloud China region
provider "alicloud" {
  alias      = "region1"
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region     = var.region1_aliyun
}

# Alibaba Cloud Global region
provider "alicloud" {
  alias      = "region2"
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region     = var.region2_aliyun
}

# AWS China region
provider "aws" {
  alias   = "region1"
  region  = var.region1_aws
  profile = var.region1_aws_profile
}

# AWS Global region
provider "aws" {
  alias   = "region2"
  region  = var.region2_aws
  profile = var.region2_aws_profile
}

# Aviatrix controller China
provider "aviatrix" {
  alias         = "region1"
  controller_ip = var.region1_aviatrix_controller_ip
  username      = var.region1_aviatrix_username
  password      = var.region1_aviatrix_password
}

# Aviatrix controller Global
provider "aviatrix" {
  alias         = "region2"
  controller_ip = var.region2_aviatrix_controller_ip
  username      = var.region2_aviatrix_username
  password      = var.region2_aviatrix_password
}