#!/bin/bash

# Script de déploiement manuel pour ECOF Website
# Usage: ./deploy.sh

set -e

echo "🚀 Déploiement ECOF Website"
echo "=========================="

# Variables (à adapter selon tes ressources AWS)
S3_BUCKET="ecof-website-stage-6e85ed80"
CLOUDFRONT_DISTRIBUTION_ID="d1zcuce5tj6u3s"
AWS_REGION="eu-west-3"

# Vérifier que AWS CLI est configuré
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI n'est pas configuré ou les credentials sont invalides"
    echo "   Exécuter: aws configure"
    exit 1
fi

echo "✅ AWS CLI configuré"

# Build du site
echo "📦 Build du site Astro..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du build"
    exit 1
fi

echo "✅ Build terminé"

# Déploiement vers S3
echo "☁️  Déploiement vers S3..."
aws s3 sync dist/ s3://$S3_BUCKET \
    --region $AWS_REGION \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "*.html"

# HTML avec cache plus court
aws s3 sync dist/ s3://$S3_BUCKET \
    --region $AWS_REGION \
    --cache-control "public, max-age=3600" \
    --include "*.html"

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du déploiement S3"
    exit 1
fi

echo "✅ Déploiement S3 terminé"

# Invalidation CloudFront
echo "🔄 Invalidation du cache CloudFront..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -ne 0 ]; then
    echo "⚠️  Erreur lors de l'invalidation CloudFront (non critique)"
else
    echo "✅ Invalidation CloudFront créée: $INVALIDATION_ID"
fi

echo ""
echo "🎉 Déploiement terminé avec succès !"
echo "🌐 Site disponible sur: https://d1zcuce5tj6u3s.cloudfront.net"
echo ""