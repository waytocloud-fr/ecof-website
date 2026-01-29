output "s3_bucket_name" {
  description = "Nom du bucket S3"
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_website_endpoint" {
  description = "Endpoint du site web S3"
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Nom de domaine CloudFront"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "certificate_arn" {
  description = "ARN du certificat SSL"
  value       = aws_acm_certificate.cert.arn
}