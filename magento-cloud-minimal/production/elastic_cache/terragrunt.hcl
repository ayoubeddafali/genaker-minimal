locals {
  aws_region = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
}

terraform {
  source = "git::git@github.com:cloudposse/terraform-aws-elasticache-redis.git?ref=0.51.1"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../magento_vpc", "../redis_security", "../aws-data"]
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

dependency "redis_security" {
  config_path = "../redis_security"
}

dependency "aws-data" {
  config_path = "../aws-data"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.0.0?tab=inputs
###########################################################
inputs = {

  name = "Magento-Redis-1"

  # Flag to enable/disable creation of a native redis cluster. 
  # automatic_failover_enabled must be set to true. Only 1 cluster_mode block is allowed
  cluster_mode_enabled = false
  
  # Automatic failover (Not available for T1/T2 instances)	
  automatic_failover_enabled = false

  subnet_ids = dependency.magento_vpc.outputs.public_subnets
  vpc_id = dependency.magento_vpc.outputs.vpc_id

  availability_zones = dependency.aws-data.outputs.available_aws_availability_zones_names
  namespace = "Magento"
  stage = "cloud"

  subnets = dependency.magento_vpc.outputs.public_subnets
  #cluster_size = 1
  #family = "redis6.x"
  #engine_version = "6.x"
  instance_type = "cache.t3.medium"
  
  # Apply changes immediately	
  apply_immediately = true
  
  # Whether to enable encryption in transit. If this is enabled, use the following guide to access redis
  transit_encryption_enabled = false
  create_security_group = false
  # security_groups = [dependency.redis_security.outputs.security_group_id]
  associated_security_group_ids = [dependency.redis_security.outputs.security_group_id]
}
