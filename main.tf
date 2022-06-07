# ---------------------------------------------------------------------------------------------------------------------
# Aviatrix VPC and Transit Gateways
# ---------------------------------------------------------------------------------------------------------------------

# Create Alibaba Transit VPC at Region 1
resource "aviatrix_vpc" "region1_ali_transit" {
  cloud_type           = var.transit_data.region1.ali_transit.cloud
  account_name         = var.transit_data.region1.ali_transit.account
  region               = var.transit_data.region1.ali_transit.region
  name                 = var.transit_data.region1.ali_transit.name
  cidr                 = var.transit_data.region1.ali_transit.cidr
  aviatrix_transit_vpc = true

  provider = aviatrix.region1
}

# Create Alibaba Transit VPC at Region 2
resource "aviatrix_vpc" "region2_ali_transit" {
  cloud_type           = var.transit_data.region2.ali_transit.cloud
  account_name         = var.transit_data.region2.ali_transit.account
  region               = var.transit_data.region2.ali_transit.region
  name                 = var.transit_data.region2.ali_transit.name
  cidr                 = var.transit_data.region2.ali_transit.cidr
  aviatrix_transit_vpc = true

  provider = aviatrix.region2
}

# Create Aviatrix Alibaba Cloud Transit Network Gateway at Region 1
resource "aviatrix_transit_gateway" "region1_ali_transit" {
  cloud_type      = var.transit_data.region1.ali_transit.cloud
  account_name    = var.transit_data.region1.ali_transit.account
  gw_name         = var.transit_data.region1.ali_transit.name
  vpc_id          = aviatrix_vpc.region1_ali_transit.vpc_id
  vpc_reg         = aviatrix_vpc.region1_ali_transit.region
  gw_size         = var.transit_data.region1.ali_transit.gw_size
  subnet          = aviatrix_vpc.region1_ali_transit.public_subnets[0].cidr
  ha_gw_size      = var.ha_gw ? var.transit_data.region1.ali_transit.gw_size : null
  ha_subnet       = var.ha_gw ? aviatrix_vpc.region1_ali_transit.public_subnets[1].cidr : null
  local_as_number = var.transit_data.region1.ali_transit.asn

  provider = aviatrix.region1
}

# Create Aviatrix Alibaba Cloud Transit Network Gateway at Region 2
resource "aviatrix_transit_gateway" "region2_ali_transit" {
  cloud_type      = var.transit_data.region2.ali_transit.cloud
  account_name    = var.transit_data.region2.ali_transit.account
  gw_name         = var.transit_data.region2.ali_transit.name
  vpc_id          = aviatrix_vpc.region2_ali_transit.vpc_id
  vpc_reg         = aviatrix_vpc.region2_ali_transit.region
  gw_size         = var.transit_data.region2.ali_transit.gw_size
  subnet          = aviatrix_vpc.region2_ali_transit.public_subnets[0].cidr
  ha_gw_size      = var.ha_gw ? var.transit_data.region2.ali_transit.gw_size : null
  ha_subnet       = var.ha_gw ? aviatrix_vpc.region2_ali_transit.public_subnets[1].cidr : null
  local_as_number = var.transit_data.region2.ali_transit.asn

  provider = aviatrix.region2
}


# ---------------------------------------------------------------------------------------------------------------------
# Alibaba Cloud CEN and Transit Routers
# ---------------------------------------------------------------------------------------------------------------------

# Create an Alibaba Cloud CEN Instance (Global constructs)
resource "alicloud_cen_instance" "this" {
  cen_instance_name = var.cen_data.cen.instance_name
  provider          = alicloud.region1
}

# Retrieve Region 1 Master and Slave Zones
data "alicloud_cen_transit_router_available_resources" "region1" {
  provider   = alicloud.region1
  depends_on = [alicloud_cen_instance.this]
}

# Retrieve Region 2 Master and Slave Zones
data "alicloud_cen_transit_router_available_resources" "region2" {
  provider   = alicloud.region2
  depends_on = [alicloud_cen_instance.this]
}

# Create vSwitch for Transit Router in Master Zone Region 1
resource "alicloud_vswitch" "region1_master" {
  vswitch_name = var.cen_data.region1.master_name
  vpc_id       = aviatrix_vpc.region1_ali_transit.vpc_id
  cidr_block   = cidrsubnet(aviatrix_vpc.region1_ali_transit.cidr, 5, 4)
  zone_id      = data.alicloud_cen_transit_router_available_resources.region1.resources[0].master_zones[0]

  provider = alicloud.region1
}

# Create vSwitch for Transit Router in Slave Zone Region 1
resource "alicloud_vswitch" "region1_slave" {
  vswitch_name = var.cen_data.region1.slave_name
  vpc_id       = aviatrix_vpc.region1_ali_transit.vpc_id
  cidr_block   = cidrsubnet(aviatrix_vpc.region1_ali_transit.cidr, 5, 5)
  zone_id      = data.alicloud_cen_transit_router_available_resources.region1.resources[0].slave_zones[1]

  provider = alicloud.region1
}

# Create vSwitch for Transit Router in Master Zone Region 2
resource "alicloud_vswitch" "region2_master" {
  vswitch_name = var.cen_data.region2.master_name
  vpc_id       = aviatrix_vpc.region2_ali_transit.vpc_id
  cidr_block   = cidrsubnet(aviatrix_vpc.region2_ali_transit.cidr, 5, 4)
  zone_id      = data.alicloud_cen_transit_router_available_resources.region2.resources[0].master_zones[0]

  provider = alicloud.region2
}

# Create vSwitch for Transit Router in Slave Zone Region 2
resource "alicloud_vswitch" "region2_slave" {
  vswitch_name = var.cen_data.region2.slave_name
  vpc_id       = aviatrix_vpc.region2_ali_transit.vpc_id
  cidr_block   = cidrsubnet(aviatrix_vpc.region2_ali_transit.cidr, 5, 5)
  zone_id      = data.alicloud_cen_transit_router_available_resources.region2.resources[0].slave_zones[1]

  provider = alicloud.region2
}

# Create CEN Transit Router in Region 1
resource "alicloud_cen_transit_router" "region1_tr" {
  cen_id              = alicloud_cen_instance.this.id
  transit_router_name = var.cen_data.region1.tr_name

  provider   = alicloud.region1
  depends_on = [alicloud_cen_instance.this]
}

# Create CEN Transit Router in Region 2 - wait for Transit Router Region 1 to be created to avoid blocking error
resource "alicloud_cen_transit_router" "region2_tr" {
  cen_id              = alicloud_cen_instance.this.id
  transit_router_name = var.cen_data.region2.tr_name

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router.region1_tr]
}

# Create VPC Attachment to Transit Router in Region 1
resource "alicloud_cen_transit_router_vpc_attachment" "region1" {
  cen_id                          = alicloud_cen_instance.this.id
  transit_router_id               = alicloud_cen_transit_router.region1_tr.transit_router_id
  vpc_id                          = aviatrix_vpc.region1_ali_transit.vpc_id
  transit_router_attachment_name  = var.cen_data.region1.attachment_name
  route_table_association_enabled = false
  route_table_propagation_enabled = false

  zone_mappings {
    vswitch_id = alicloud_vswitch.region1_master.id
    zone_id    = data.alicloud_cen_transit_router_available_resources.region1.resources[0].master_zones[0]
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.region1_slave.id
    zone_id    = data.alicloud_cen_transit_router_available_resources.region1.resources[0].slave_zones[1]
  }

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router.region1_tr]
}

# Create VPC Attachment to Transit Router in Region 2
resource "alicloud_cen_transit_router_vpc_attachment" "region2" {
  cen_id                          = alicloud_cen_instance.this.id
  transit_router_id               = alicloud_cen_transit_router.region2_tr.transit_router_id
  vpc_id                          = aviatrix_vpc.region2_ali_transit.vpc_id
  transit_router_attachment_name  = var.cen_data.region2.attachment_name
  route_table_association_enabled = false
  route_table_propagation_enabled = false

  zone_mappings {
    vswitch_id = alicloud_vswitch.region2_master.id
    zone_id    = data.alicloud_cen_transit_router_available_resources.region2.resources[0].master_zones[0]
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.region2_slave.id
    zone_id    = data.alicloud_cen_transit_router_available_resources.region2.resources[0].slave_zones[1]
  }

  provider = alicloud.region2
}

# Create Transit Router Route Table in Region 1
resource "alicloud_cen_transit_router_route_table" "region1_rtb" {
  transit_router_id               = alicloud_cen_transit_router.region1_tr.transit_router_id
  transit_router_route_table_name = var.cen_data.region1.rtb_name
  provider                        = alicloud.region1
}

# Create Transit Router Route Table in Region 2
resource "alicloud_cen_transit_router_route_table" "region2_rtb" {
  transit_router_id               = alicloud_cen_transit_router.region2_tr.transit_router_id
  transit_router_route_table_name = var.cen_data.region2.rtb_name
  provider                        = alicloud.region2
}

# Create Intra-Region Route Table Association in Region 1
resource "alicloud_cen_transit_router_route_table_association" "region1_rtb_association" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region1_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.region1.transit_router_attachment_id

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region1, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Intra-Region Route Table Association in Region 1
resource "alicloud_cen_transit_router_route_table_association" "region2_rtb_association" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region2_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.region2.transit_router_attachment_id

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region2, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Intra-Region Route Table Propagation in Region 1
resource "alicloud_cen_transit_router_route_table_propagation" "region1_rtb_propagation" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region1_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.region1.transit_router_attachment_id

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region1, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Intra-Region Route Table Propagation in Region 2
resource "alicloud_cen_transit_router_route_table_propagation" "region2_rtb_propagation" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region2_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.region2.transit_router_attachment_id

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region2, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Cross-Region Connections
resource "alicloud_cen_transit_router_peer_attachment" "region1_to_region2" {
  cen_id                         = alicloud_cen_instance.this.id
  transit_router_id              = alicloud_cen_transit_router.region1_tr.transit_router_id
  peer_transit_router_region_id  = var.region2_aliyun
  peer_transit_router_id         = alicloud_cen_transit_router.region2_tr.transit_router_id
  bandwidth_type                 = var.xregion_bandwidth_type
  bandwidth                      = var.xregion_bandwidth
  transit_router_attachment_name = "${var.region1_aliyun}-to-${var.region2_aliyun}"

  auto_publish_route_enabled      = true
  route_table_association_enabled = false
  route_table_propagation_enabled = false

  timeouts {
    create = "5m"
    delete = "5m"
    update = "5m"
  }

  provider   = alicloud.region1
  depends_on = [alicloud_cen_instance.this]
}

# Create Cross-Region Route Table Association in Region 1
resource "alicloud_cen_transit_router_route_table_association" "region1_xregion_rtb_association" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region1_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.region1_to_region2.transit_router_attachment_id

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region1, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Cross-Region Route Table Association in Region 2
resource "alicloud_cen_transit_router_route_table_association" "region2_xregion_rtb_association" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region2_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.region1_to_region2.transit_router_attachment_id

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region2, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Cross-Region Route Table Propagation in Region 1
resource "alicloud_cen_transit_router_route_table_propagation" "region1_xregion_rtb_propagation" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region1_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.region1_to_region2.transit_router_attachment_id

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region1, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Cross-Region Route Table Propagation in Region 2
resource "alicloud_cen_transit_router_route_table_propagation" "region2_xregion_rtb_propagation" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.region2_rtb.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.region1_to_region2.transit_router_attachment_id

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region2, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Retrieve Transit VPC Route Table in Region 1
data "alicloud_route_tables" "region1_transit_rtb" {
  vpc_id = aviatrix_vpc.region1_ali_transit.vpc_id

  provider   = alicloud.region1
  depends_on = [aviatrix_vpc.region1_ali_transit]
}

# Retrieve Transit VPC Route Table in Region 2
data "alicloud_route_tables" "region2_transit_rtb" {
  vpc_id = aviatrix_vpc.region2_ali_transit.vpc_id

  provider   = alicloud.region2
  depends_on = [aviatrix_vpc.region2_ali_transit]
}

# Create Route from Transit VPC Region 1 to Transit VPC Region 2
resource "alicloud_route_entry" "region1_to_region2" {
  route_table_id        = data.alicloud_route_tables.region1_transit_rtb.tables[0].route_table_id
  destination_cidrblock = var.transit_data.region2.ali_transit.cidr
  nexthop_type          = "Attachment" # Transit Router
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.region1.transit_router_attachment_id

  provider   = alicloud.region1
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region1, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}

# Create Route from Transit VPC Region 2 to Transit VPC Region 1
resource "alicloud_route_entry" "region2_to_region1" {
  route_table_id        = data.alicloud_route_tables.region2_transit_rtb.tables[0].route_table_id
  destination_cidrblock = var.transit_data.region1.ali_transit.cidr
  nexthop_type          = "Attachment" # Transit Router
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.region2.transit_router_attachment_id

  provider   = alicloud.region2
  depends_on = [alicloud_cen_transit_router_vpc_attachment.region2, alicloud_cen_transit_router_peer_attachment.region1_to_region2]
}


# ---------------------------------------------------------------------------------------------------------------------
# Aviatrix Site2Cloud Configuration
# ---------------------------------------------------------------------------------------------------------------------

# Create S2C from Region 1 to Region 2
resource "aviatrix_transit_external_device_conn" "region1_to_region2" {
  vpc_id            = aviatrix_vpc.region1_ali_transit.vpc_id
  connection_name   = "${var.region1_aliyun}-to-${var.region2_aliyun}"
  gw_name           = aviatrix_transit_gateway.region1_ali_transit.gw_name
  connection_type   = "bgp"
  pre_shared_key    = var.pre_shared_key
  direct_connect    = true
  remote_gateway_ip = aviatrix_transit_gateway.region2_ali_transit.private_ip
  bgp_local_as_num  = aviatrix_transit_gateway.region1_ali_transit.local_as_number
  bgp_remote_as_num = aviatrix_transit_gateway.region2_ali_transit.local_as_number

  ha_enabled               = var.ha_gw ? true : false
  backup_pre_shared_key    = var.ha_gw ? var.pre_shared_key : null
  backup_direct_connect    = var.ha_gw ? true : false
  backup_remote_gateway_ip = var.ha_gw ? aviatrix_transit_gateway.region2_ali_transit.ha_private_ip : null
  backup_bgp_remote_as_num = var.ha_gw ? aviatrix_transit_gateway.region2_ali_transit.local_as_number : null

  local_tunnel_cidr         = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[0], 1)}/30,${cidrhost(local.tunnel_cidr_blocks[1], 1)}/30" : "${cidrhost(local.tunnel_cidr_blocks[0], 1)}/30"
  remote_tunnel_cidr        = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[0], 2)}/30,${cidrhost(local.tunnel_cidr_blocks[1], 2)}/30" : "${cidrhost(local.tunnel_cidr_blocks[0], 2)}/30"
  backup_local_tunnel_cidr  = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[2], 1)}/30,${cidrhost(local.tunnel_cidr_blocks[3], 1)}/30" : null
  backup_remote_tunnel_cidr = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[2], 2)}/30,${cidrhost(local.tunnel_cidr_blocks[3], 2)}/30" : null

  provider = aviatrix.region1

  depends_on = [
    aviatrix_transit_gateway.region1_ali_transit,
    aviatrix_transit_gateway.region2_ali_transit,
    alicloud_cen_transit_router_peer_attachment.region1_to_region2
  ]
}

# Create S2C from Region 2 to Region 1
resource "aviatrix_transit_external_device_conn" "region2_to_region1" {
  vpc_id            = aviatrix_vpc.region2_ali_transit.vpc_id
  connection_name   = "${var.region2_aliyun}-to-${var.region1_aliyun}"
  gw_name           = aviatrix_transit_gateway.region2_ali_transit.gw_name
  connection_type   = "bgp"
  pre_shared_key    = var.pre_shared_key
  direct_connect    = true
  remote_gateway_ip = aviatrix_transit_gateway.region1_ali_transit.private_ip
  bgp_local_as_num  = aviatrix_transit_gateway.region2_ali_transit.local_as_number
  bgp_remote_as_num = aviatrix_transit_gateway.region1_ali_transit.local_as_number

  ha_enabled               = var.ha_gw ? true : false
  backup_pre_shared_key    = var.ha_gw ? var.pre_shared_key : null
  backup_direct_connect    = var.ha_gw ? true : false
  backup_remote_gateway_ip = var.ha_gw ? aviatrix_transit_gateway.region1_ali_transit.ha_private_ip : null
  backup_bgp_remote_as_num = var.ha_gw ? aviatrix_transit_gateway.region1_ali_transit.local_as_number : null

  local_tunnel_cidr         = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[0], 2)}/30,${cidrhost(local.tunnel_cidr_blocks[2], 2)}/30" : "${cidrhost(local.tunnel_cidr_blocks[0], 2)}/30"
  remote_tunnel_cidr        = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[0], 1)}/30,${cidrhost(local.tunnel_cidr_blocks[2], 1)}/30" : "${cidrhost(local.tunnel_cidr_blocks[0], 1)}/30"
  backup_local_tunnel_cidr  = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[1], 2)}/30,${cidrhost(local.tunnel_cidr_blocks[3], 2)}/30" : null
  backup_remote_tunnel_cidr = var.ha_gw ? "${cidrhost(local.tunnel_cidr_blocks[1], 1)}/30,${cidrhost(local.tunnel_cidr_blocks[3], 1)}/30" : null

  provider = aviatrix.region2

  depends_on = [
    aviatrix_transit_gateway.region1_ali_transit,
    aviatrix_transit_gateway.region2_ali_transit,
    alicloud_cen_transit_router_peer_attachment.region1_to_region2
  ]
}