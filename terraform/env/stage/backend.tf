terraform {
  backend "s3" {
    bucket         = "ecof-terraform-state-secure"
    key            = "stage/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "ecof-terraform-locks"
    
    # Sécurité renforcée avec KMS
    kms_key_id = "alias/ecof-terraform-state"
    
    # Les credentials AWS seront fournis via:
    # - Variables d'environnement AWS_ACCESS_KEY_ID et AWS_SECRET_ACCESS_KEY
    # - Profil AWS configuré
    # - Rôle IAM (recommandé pour CI/CD)
  }
}