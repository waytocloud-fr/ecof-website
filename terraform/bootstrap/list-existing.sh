#!/bin/bash

# Script pour lister toutes les ressources AWS existantes liées au projet ECOF

set -euo pipefail

echo "🔍 Recherche des ressources AWS existantes pour ECOF..."
echo "=================================================="

# Fonction pour vérifier si une commande a réussi
check_resource() {
    local resource_type="$1"
    local command="$2"
    local resource_name="$3"
    
    echo -n "📋 $resource_type ($resource_name): "
    if eval "$command" >/dev/null 2>&1; then
        echo "✅ EXISTE"
        return 0
    else
        echo "❌ N'EXISTE PAS"
        return 1
    fi
}

echo ""
echo "🔑 Clés KMS:"
echo "------------"

# Vérifier l'alias KMS
if check_resource "Alias KMS" "aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3" "alias/ecof-terraform-state"; then
    KMS_KEY_ID=$(aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.KeyId' --output text)
    echo "   └── ID de la clé: $KMS_KEY_ID"
    echo "   └── ARN: $(aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.Arn' --output text)"
fi

echo ""
echo "🗄️  Tables DynamoDB:"
echo "-------------------"

check_resource "Table DynamoDB" "aws dynamodb describe-table --table-name ecof-terraform-locks --region eu-west-3" "ecof-terraform-locks"

echo ""
echo "🪣 Buckets S3:"
echo "-------------"

check_resource "Bucket S3 State" "aws s3 ls s3://ecof-terraform-state-secure" "ecof-terraform-state-secure"
check_resource "Bucket S3 Logs" "aws s3 ls s3://ecof-terraform-logs-secure" "ecof-terraform-logs-secure"

echo ""
echo "📊 Résumé des imports nécessaires:"
echo "================================="

echo ""
echo "Commandes d'import Terraform à exécuter:"

# Vérifier chaque ressource et donner la commande d'import
if aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 >/dev/null 2>&1; then
    KMS_KEY_ID=$(aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.KeyId' --output text)
    echo "terraform import aws_kms_key.terraform_state $KMS_KEY_ID"
    echo "terraform import aws_kms_alias.terraform_state alias/ecof-terraform-state"
fi

if aws dynamodb describe-table --table-name ecof-terraform-locks --region eu-west-3 >/dev/null 2>&1; then
    echo "terraform import aws_dynamodb_table.terraform_locks ecof-terraform-locks"
fi

if aws s3 ls s3://ecof-terraform-state-secure >/dev/null 2>&1; then
    echo "terraform import aws_s3_bucket.terraform_state ecof-terraform-state-secure"
fi

if aws s3 ls s3://ecof-terraform-logs-secure >/dev/null 2>&1; then
    echo "terraform import aws_s3_bucket.terraform_logs ecof-terraform-logs-secure"
fi

echo ""
echo "💡 Ou utilisez le script automatique:"
echo "./quick-fix.sh"

echo ""
echo "🔍 Détails des ressources existantes:"
echo "===================================="

# Détails de la clé KMS
if aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 >/dev/null 2>&1; then
    echo ""
    echo "🔑 Détails de la clé KMS:"
    aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.{KeyId:KeyId,Arn:Arn,Description:Description,KeyUsage:KeyUsage,KeyState:KeyState}' --output table
fi

# Détails de la table DynamoDB
if aws dynamodb describe-table --table-name ecof-terraform-locks --region eu-west-3 >/dev/null 2>&1; then
    echo ""
    echo "🗄️  Détails de la table DynamoDB:"
    aws dynamodb describe-table --table-name ecof-terraform-locks --region eu-west-3 --query 'Table.{TableName:TableName,TableStatus:TableStatus,BillingMode:BillingModeSummary.BillingMode,ItemCount:ItemCount}' --output table
fi

# Détails des buckets S3
echo ""
echo "🪣 Buckets S3 ECOF existants:"
aws s3 ls | grep ecof || echo "Aucun bucket ECOF trouvé"