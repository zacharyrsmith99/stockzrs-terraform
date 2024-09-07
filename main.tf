module "networking" {
  source                    = "./modules/networking"
  ingress_nginx_lb_hostname = module.eks.ingress_nginx_lb_hostname
  ingress_nginx_lb_hosted_zone_id = var.ingress_nginx_lb_hosted_zone_id

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
}
