#!/bin/bash

# Solution rapide pour importer toutes les ressources existantes

set -euo pipefail

echo "🔍 Import des ressources AWS existantes..."

# Fonction pour obtenir l'ID de la clé KMS à partir de l'alias
get_kms_key_id() {
    aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.KeyId' --output text
}

echo "📋 Recherche de la clé KMS..."
KMS_KEY_ID=$(get_kms_key_id)
echo "Clé KMS trouvée: $KMS_KEY_ID"

echo "📥 Import de la clé KMS..."
terraform import aws_kms_key.terraform_state "$KMS_KEY_ID" || {
    echo "⚠️  Clé KMS déjà importée ou échec d'import"
}

echo "📥 Import de l'alias KMS..."
terraform import aws_kms_alias.terraform_state alias/ecof-terraform-state || {
    echo "⚠️  Alias KMS déjà importé ou échec d'import"
}

echo "📥 Import de la table DynamoDB..."
terraform import aws_dynamodb_table.terraform_locks ecof-terraform-locks || {
    echo "⚠️  Table DynamoDB déjà importée ou échec d'import"
}

echo "📥 Vérification des buckets S3..."

# Vérifier et importer le bucket state s'il existe
if aws s3 ls s3://ecof-terraform-state-secure >/dev/null 2>&1; then
    echo "📥 Import du bucket S3 state..."
    terraform import aws_s3_bucket.terraform_state ecof-terraform-state-secure || {
        echo "⚠️  Bucket S3 state déjà importé ou échec d'import"
    }
else
    echo "ℹ️  Bucket S3 state n'existe pas encore"
fi

# Vérifier et importer le bucket logs s'il existe
if aws s3 ls s3://ecof-terraform-logs-secure >/dev/null 2>&1; then
    echo "📥 Import du bucket S3 logs..."
    terraform import aws_s3_bucket.terraform_logs ecof-terraform-logs-secure || {
        echo "⚠️  Bucket S3 logs déjà importé ou échec d'import"
    }
else
    echo "ℹ️  Bucket S3 logs n'existe pas encore"
fi

echo "✅ Import terminé !"

echo "🔄 Refresh du state Terraform..."
terraform refresh

echo "📋 Nouveau plan après import..."
terraform plan

echo ""
echo "🚀 Prêt pour le déploiement !"
echo "Exécutez 'terraform apply' pour continuer"