variable "rg_name" {
  description = "Alibaba Cloud Resource group identifier"
  type        = string
  default     = null
}

variable "region1_aviatrix_controller_ip" {
  description = "First region Aviatrix Controller IP"
  type        = string
}

variable "region1_aviatrix_username" {
  description = "First region Aviatrix username"
  type        = string
}

variable "region1_aviatrix_password" {
  description = "First region Aviatrix password"
  type        = string
}

variable "region2_aviatrix_controller_ip" {
  description = "Second region Aviatrix Controller IP"
  type        = string
}

variable "region2_aviatrix_username" {
  description = "Second region Aviatrix username"
  type        = string
}

variable "region2_aviatrix_password" {
  description = "Second region Aviatrix password"
  type        = string
}

variable "alicloud_access_key" {
  description = "Alibaba Access Key"
  type        = string
}

variable "alicloud_secret_key" {
  description = "Alibaba Secret Key"
  type        = string
}

variable "region1_aliyun" {
  description = "Alibaba Cloud region 1 - China region"
  type        = string
}

variable "region2_aliyun" {
  description = "Alibaba Cloud region 2 - Global region"
  type        = string
}

variable "region1_aws" {
  description = "AWS region 1 - China region"
  type        = string
  default     = null
}

variable "region2_aws" {
  description = "AWS region 2 - Global region"
  type        = string
  default     = null
}

variable "region1_aws_profile" {
  description = "AWS region 1 - China region"
  type        = string
  default     = null
}

variable "region2_aws_profile" {
  description = "AWS region 2 - Global region"
  type        = string
  default     = null
}

variable "xregion_bandwidth_type" {
  description = "Cross-region bandwidth type"
  type        = string
  default     = "DataTransfer"
}

variable "xregion_bandwidth" {
  description = "Cross-region bandwidth"
  type        = number
  default     = 1
}

variable "pre_shared_key" {
  description = "Site2Cloud Pre Shared Key"
  type        = string
  default     = "Aviatrix123#"
}

variable "tunnel_supernet" {
  description = "/24 Supernet for tunnel IP addresses"
  type        = string
  default     = "169.254.0.0/24"
}

variable "ha_gw" {
  description = "Enable HA Gateway"
  type        = bool
  default     = false
}

variable "cen_data" {
  description = "Maps of Alibaba CEN and Transit Router data"
  type        = map(any)
}

variable "transit_data" {
  description = "Maps of transit data (VPC and gateways)"
  type        = map(any)
}

variable "spoke_data" {
  description = "Maps of spoke data (VPC and gateways)"
  type        = map(any)
}

variable "create" {
  description = "Maps of transit/spoke toggle"
  type        = map(any)
}

locals {
  tunnel_cidr_blocks = cidrsubnets(var.tunnel_supernet, 6, 6, 6, 6)
}