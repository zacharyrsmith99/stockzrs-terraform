module "networking" {
  source                          = "./modules/networking"
  ingress_nginx_lb_hostname       = module.eks.ingress_nginx_lb_hostname
  ingress_nginx_lb_hosted_zone_id = var.ingress_nginx_lb_hosted_zone_id
  openvpn_eni_id                  = module.openvpn.openvpn_eni_id
}

module "eks" {
  source                   = "./modules/eks"
  stockzrs_secrets_configs = module.services.stockzrs_secrets_configs
  stockzrs_subnets         = module.networking.stockzrs_subnets
  stockzrs_vpcs            = module.networking.stockzrs_vpcs
}

module "services" {
  source                   = "./modules/services"
  twelvedata_api_key       = var.twelvedata_api_key
  coinbase_api_key         = var.coinbase_api_key
  coinbase_api_private_key = var.coinbase_api_private_key
  stockzrs_frontend_port   = var.stockzrs_frontend_port
  stockzrs_relay_port      = var.stockzrs_relay_port
  kafka_bootstrap_server   = module.eks.kafka_bootstrap_server
}

module "openvpn" {
  source                 = "./modules/openvpn"
  stockzrs_vpcs          = module.networking.stockzrs_vpcs
  stockzrs_subnets       = module.networking.stockzrs_subnets
  aws_region             = var.aws_region
  ssh_connect_cidr_block = var.ssh_connect_cidr_block
}

module "rds" {
  source           = "./modules/rds"
  stockzrs_subnets = module.networking.stockzrs_subnets
  stockzrs_vpcs    = module.networking.stockzrs_vpcs
}
