module "ecof_site" {
  source = "../../modules/site-static-simple"
  
  project_name = "ecof-website"
  environment  = "stage"
}