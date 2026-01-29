#!/bin/bash

# Script pour nettoyer et déployer la version simplifiée

set -euo pipefail

echo "🧹 Nettoyage du cache Terraform..."
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
rm -f *.tfplan

echo "🔧 Initialisation Terraform..."
terraform init

echo "✅ Validation de la configuration..."
terraform validate

echo "📋 Génération du plan..."
terraform plan

echo ""
echo "🚀 Configuration prête pour le déploiement !"
echo "Pour déployer, exécutez : terraform apply"