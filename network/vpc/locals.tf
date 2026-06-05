locals {
  project_name = "ssfb-aspora"
  environment  = "dr"
  tags = {
    Environment = local.environment
    Project     = local.project_name
    Terraform   = true
    Owner       = "cloud4c-build"
  }
}