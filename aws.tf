# Create AWS transit at Region 1 - China region
module "region1_aws_transit" {
  count = var.create.region1.aws_transit ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.1"

  cloud   = "aws"
  account = var.transit_data.region1.aws_transit.account
  region  = var.transit_data.region1.aws_transit.region
  name    = var.transit_data.region1.aws_transit.name
  cidr    = var.transit_data.region1.aws_transit.cidr
  ha_gw   = var.ha_gw

  providers = {
    aviatrix = aviatrix.region1
  }
}

# Peer region 1 AWS to region 1 Alibaba Cloud
resource "aviatrix_transit_gateway_peering" "region1_aws_to_ali" {
  count = var.create.region1.aws_transit ? 1 : 0

  transit_gateway_name1 = module.region1_aws_transit[0].transit_gateway.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.region1_ali_transit.gw_name

  enable_peering_over_private_network         = false
  enable_insane_mode_encryption_over_internet = false

  provider = aviatrix.region1
}

# Create AWS transit at Region 2 - Global region
module "region2_aws_transit" {
  count = var.create.region2.aws_transit ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.1"

  cloud   = "aws"
  account = var.transit_data.region2.aws_transit.account
  region  = var.transit_data.region2.aws_transit.region
  name    = var.transit_data.region2.aws_transit.name
  cidr    = var.transit_data.region2.aws_transit.cidr
  ha_gw   = var.ha_gw

  providers = {
    aviatrix = aviatrix.region2
  }
}

# Peer region 2 AWS to region 2 Alibaba Cloud
resource "aviatrix_transit_gateway_peering" "region2_aws_to_ali" {
  count = var.create.region2.aws_transit ? 1 : 0

  transit_gateway_name1 = module.region2_aws_transit[0].transit_gateway.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.region2_ali_transit.gw_name

  enable_peering_over_private_network         = false
  enable_insane_mode_encryption_over_internet = false

  provider = aviatrix.region2
}

# Create AWS spoke at Region 1 - China region
module "region1_aws_spoke1" {
  count = var.create.region1.aws_spoke1 ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.0"

  cloud      = "aws"
  account    = var.spoke_data.region1.aws_spoke1.account
  region     = var.spoke_data.region1.aws_spoke1.region
  name       = var.spoke_data.region1.aws_spoke1.name
  cidr       = var.spoke_data.region1.aws_spoke1.cidr
  ha_gw      = var.ha_gw
  transit_gw = module.region1_aws_transit[0].transit_gateway.gw_name

  providers = {
    aviatrix = aviatrix.region1
  }
}

# Create AWS spoke at Region 2 - Global region
module "region2_aws_spoke1" {
  count = var.create.region2.aws_spoke1 ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.0"

  cloud      = "aws"
  account    = var.spoke_data.region2.aws_spoke1.account
  region     = var.spoke_data.region2.aws_spoke1.region
  name       = var.spoke_data.region2.aws_spoke1.name
  cidr       = var.spoke_data.region2.aws_spoke1.cidr
  ha_gw      = var.ha_gw
  transit_gw = module.region2_aws_transit[0].transit_gateway.gw_name

  providers = {
    aviatrix = aviatrix.region2
  }
}

# Create SSM Instance Profile in region 1
module "region1_aws_ssm_profile" {
  count = var.create.region1.aws_spoke1 && var.create.region1.aws_spoke1_instance ? 1 : 0

  source                    = "bayupw/ssm-instance-profile/aws"
  version                   = "1.1.0"
  partition                 = "china"
  ssm_instance_role_name    = "bwibowo-ssm-role"
  ssm_instance_profile_name = "bwibowo-ssm-profile"

  providers = {
    aws = aws.region1
  }
}

# Create SSM Instance Profile in region 2
module "region2_aws_ssm_profile" {
  count = var.create.region2.aws_spoke1 && var.create.region2.aws_spoke1_instance ? 1 : 0

  source                    = "bayupw/ssm-instance-profile/aws"
  version                   = "1.1.0"
  ssm_instance_role_name    = "bwibowo-ssm-role"
  ssm_instance_profile_name = "bwibowo-ssm-profile"

  providers = {
    aws = aws.region2
  }
}

# Create SSM Instance Profile in region 1
module "region1_ssm_vpce" {
  count = var.create.region1.aws_spoke1 && var.create.region1.aws_spoke1_instance ? 1 : 0

  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.region1_aws_spoke1[0].vpc.vpc_id
  vpc_subnet_ids = module.region1_aws_spoke1[0].vpc.private_subnets[*].subnet_id

  providers = {
    aws = aws.region1
  }

  depends_on = [module.region1_aws_spoke1]
}

# Create SSM Instance Profile in region 2
module "region2_ssm_vpce" {
  count = var.create.region2.aws_spoke1 && var.create.region2.aws_spoke1_instance ? 1 : 0

  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.1"

  vpc_id         = module.region2_aws_spoke1[0].vpc.vpc_id
  vpc_subnet_ids = module.region2_aws_spoke1[0].vpc.private_subnets[*].subnet_id

  providers = {
    aws = aws.region2
  }

  depends_on = [module.region2_aws_spoke1]
}

# Create EC2 instance in region 1
module "region1_ec2" {
  count = var.create.region1.aws_spoke1 && var.create.region1.aws_spoke1_instance ? 1 : 0

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.region1_aws_spoke1[0].vpc.vpc_id
  subnet_id            = module.region1_aws_spoke1[0].vpc.private_subnets[0].subnet_id
  iam_instance_profile = module.region1_aws_ssm_profile[0].aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "bwibowo-ec2-china-01"
  random_password      = false
  instance_password    = "Aviatrix123#"

  providers = {
    aws = aws.region1
  }

  depends_on = [module.region1_aws_spoke1, module.region1_ssm_vpce]
}

# Create EC2 instance in region 2
module "region2_ec2" {
  count = var.create.region2.aws_spoke1 && var.create.region2.aws_spoke1_instance ? 1 : 0

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id               = module.region2_aws_spoke1[0].vpc.vpc_id
  subnet_id            = module.region2_aws_spoke1[0].vpc.private_subnets[0].subnet_id
  iam_instance_profile = module.region2_aws_ssm_profile[0].aws_iam_instance_profile
  instance_type        = "t3.micro"
  instance_hostname    = "bwibowo-ec2-global-01"
  random_password      = false
  instance_password    = "Aviatrix123#"

  providers = {
    aws = aws.region2
  }

  depends_on = [module.region2_aws_spoke1, module.region2_ssm_vpce]
}