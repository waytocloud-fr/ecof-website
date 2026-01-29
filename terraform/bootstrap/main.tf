# Bootstrap infrastructure simplifié pour Terraform state management sécurisé
# Version sans default_tags et sans réplication pour éviter les erreurs

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
  
  # Pas de default_tags pour éviter les erreurs de tags invalides
}

# KMS Key pour chiffrement du state Terraform
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for ECOF Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "ecof-terraform-state-key"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/ecof-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# S3 Bucket pour le state Terraform avec sécurité renforcée
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ecof-terraform-state-secure"

  tags = {
    Name        = "ecof-terraform-state-secure"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

# Versioning pour le bucket state
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement du bucket state
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Bloquer l'accès public au bucket state
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Politique de bucket pour accès restreint
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# DynamoDB table pour le verrouillage du state
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "ecof-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "ecof-terraform-locks"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

# Bucket pour les logs d'accès (simplifié)
resource "aws_s3_bucket" "terraform_logs" {
  bucket = "ecof-terraform-logs-secure"

  tags = {
    Name        = "ecof-terraform-logs-secure"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_logs" {
  bucket = aws_s3_bucket.terraform_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_logs" {
  bucket = aws_s3_bucket.terraform_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Logging pour le bucket state (optionnel, peut être ajouté plus tard)
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.terraform_logs.id
  target_prefix = "terraform-state-access/"
}