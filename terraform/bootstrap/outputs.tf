output "terraform_state_bucket" {
  description = "Nom du bucket S3 pour le state Terraform"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN du bucket S3 pour le state Terraform"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_locks_table" {
  description = "Nom de la table DynamoDB pour les verrous Terraform"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "terraform_locks_table_arn" {
  description = "ARN de la table DynamoDB pour les verrous Terraform"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key_id" {
  description = "ID de la clé KMS pour le chiffrement du state"
  value       = aws_kms_key.terraform_state.key_id
}

output "kms_key_arn" {
  description = "ARN de la clé KMS pour le chiffrement du state"
  value       = aws_kms_key.terraform_state.arn
}

output "logs_bucket" {
  description = "Nom du bucket pour les logs d'accès"
  value       = aws_s3_bucket.terraform_logs.bucket
}