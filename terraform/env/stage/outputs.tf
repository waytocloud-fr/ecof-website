output "s3_bucket_name" {
  description = "Nom du bucket S3 pour le site web"
  value       = module.ecof_site.s3_bucket_name
}

output "s3_website_endpoint" {
  description = "Endpoint du site web S3"
  value       = module.ecof_site.s3_website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront"
  value       = module.ecof_site.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Nom de domaine CloudFront"
  value       = module.ecof_site.cloudfront_domain_name
}

output "website_url" {
  description = "URL du site web"
  value       = module.ecof_site.website_url
}