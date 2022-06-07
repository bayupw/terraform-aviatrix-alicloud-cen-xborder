# Region1 = China Region
region1_aviatrix_controller_ip = "1.2.3.4"
region1_aviatrix_username      = "admin"
region1_aviatrix_password      = "Aviatrix123#"

# Region2 = Global / Non-China Region
region2_aviatrix_controller_ip = "4.3.2.1"
region2_aviatrix_username      = "admin"
region2_aviatrix_password      = "Aviatrix123#"
cen_instance_name = "cen-instance"

# Alibaba Cloud Configurations
alicloud_access_key = "A1B2C3D4E5"
alicloud_secret_key = "5e4d3c2b1a0j9i8g7g5f"
region1_aliyun      = "cn-beijing"
region2_aliyun      = "ap-southeast-1"

# Alibaba CEN and Transit Router data
xregion_bandwidth_type = "DataTransfer"
xregion_bandwidth      = 1
cen_data = {
  cen = {
    instance_name = "bwibowo-cen"
  }
  region1 = {
    tr_name         = "bwibowo-bjg-tr"
    master_name     = "bwibowo-region1-master"
    slave_name      = "bwibowo-region1-slave"
    attachment_name = "region1-tr-attachment"
    rtb_name        = "region1-tr-rtb"
  }
  region2 = {
    tr_name         = "bwibowo-sgp-tr"
    master_name     = "bwibowo-region2-master"
    slave_name      = "bwibowo-region2-slave"
    attachment_name = "region2-tr-attachment"
    rtb_name        = "region2-tr-rtb"
  }
}

# AWS Configurations
region1_aws         = "cn-north-1"
region2_aws         = "ap-southeast-1"
region1_aws_profile = "aws-china-account"
region2_aws_profile = "aws-account"

# Gateway parameter options
pre_shared_key  = "Aviatrix123#"   # Site2Cloud pre-shared key
tunnel_supernet = "169.254.0.0/24" # /24 Supernet for tunnel IP addresses
ha_gw           = true

# Transit VPC and gateways data
transit_data = {
  region1 = {
    ali_transit = {
      cloud   = 8192
      account = "aliyun-account"
      region  = "acs-cn-beijing (Beijing)"
      name    = "bwibowo-ali-bjg-tr"
      cidr    = "10.1.0.0/23"
      gw_size = "ecs.g5ne.large"
      asn     = "65001"
    }
    aws_transit = {
      cloud   = 1024
      account = "aws-china-account"
      region  = "cn-north-1"
      name    = "bwibowo-aws-bjg-tr"
      cidr    = "10.11.0.0/23"
      gw_size = "t3.micro"
      asn     = "65011"
    }
  }
  region2 = {
    ali_transit = {
      cloud   = 8192
      account = "aliyun-account"
      region  = "acs-ap-southeast-1 (Singapore)"
      name    = "bwibowo-ali-sgp-tr"
      cidr    = "10.2.0.0/23"
      gw_size = "ecs.g5ne.large"
      asn     = "65002"
    }
    aws_transit = {
      cloud   = 1024
      account = "aws-account"
      region  = "ap-southeast-1"
      name    = "bwibowo-aws-sgp-tr"
      cidr    = "10.21.0.0/23"
      gw_size = "t3.micro"
      asn     = "65021"
    }
  }
}

# Spoke VPC and gateways data
spoke_data = {
  region1 = {
    ali_spoke1 = {
      cloud   = 8192
      account = "aliyun-account"
      region  = "acs-cn-beijing (Beijing)"
      name    = "bwibowo-ali-bjg-sp1"
      cidr    = "10.1.2.0/24"
      gw_size = "ecs.g5ne.large"
    }
    aws_spoke1 = {
      cloud   = 1024
      account = "aws-china-account"
      region  = "cn-north-1"
      name    = "bwibowo-aws-bjg-sp1"
      cidr    = "10.11.2.0/24"
      gw_size = "t3.micro"
    }
  }
  region2 = {
    ali_spoke1 = {
      cloud   = 8192
      account = "aliyun-account"
      region  = "acs-ap-southeast-1 (Singapore)"
      name    = "bwibowo-ali-sgp-sp1"
      cidr    = "10.2.2.0/24"
      gw_size = "ecs.g5ne.large"
    }
    aws_spoke1 = {
      cloud   = 1
      account = "aws-account"
      region  = "ap-southeast-1"
      name    = "bwibowo-aws-sgp-sp1"
      cidr    = "10.21.2.0/24"
      gw_size = "t3.micro"
    }
  }
}

# Bool to create AWS transit, spoke and ec2 instances
create = {
  region1 = {
    aws_transit         = true
    aws_spoke1          = true
    aws_spoke1_instance = true
  }
  region2 = {
    aws_transit         = true
    aws_spoke1          = true
    aws_spoke1_instance = true
  }
}