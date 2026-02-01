#!/bin/bash

# Script pour forcer la mise à jour d'une image avec cache busting
# Usage: ./update-image-cache.sh [nom-image]

set -e

IMAGE_NAME=${1:-"GroupRide.png"}
IMAGE_PATH="public/images/$IMAGE_NAME"

echo "🖼️  Mise à jour de l'image avec cache busting"
echo "============================================="

# Vérifier que l'image existe
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Image non trouvée: $IMAGE_PATH"
    exit 1
fi

echo "📁 Image trouvée: $IMAGE_PATH"

# Build du site
echo "📦 Build du site..."
npm run build

# Vérifier que l'image a été copiée
DIST_IMAGE="dist/images/$IMAGE_NAME"
if [ ! -f "$DIST_IMAGE" ]; then
    echo "❌ Image non trouvée dans dist: $DIST_IMAGE"
    exit 1
fi

echo "✅ Image buildée: $DIST_IMAGE"

# Déploiement
echo "☁️  Déploiement vers S3..."
S3_BUCKET="ecof-website-stage-6e85ed80"

# Upload de l'image spécifique avec cache court
aws s3 cp "$DIST_IMAGE" "s3://$S3_BUCKET/images/$IMAGE_NAME" \
    --cache-control "public, max-age=300" \
    --metadata-directive REPLACE

echo "✅ Image uploadée vers S3"

# Invalidation CloudFront spécifique
echo "🔄 Invalidation CloudFront..."
DISTRIBUTION_ID="EA2FNVF5R7H6G"

INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/images/$IMAGE_NAME" \
    --query 'Invalidation.Id' \
    --output text)

echo "✅ Invalidation créée: $INVALIDATION_ID"
echo "⏱️  Attendre 5-15 minutes pour la propagation"
echo "🌐 Site: https://d1zcuce5tj6u3s.cloudfront.net"

# Optionnel: Attendre que l'invalidation soit terminée
read -p "Voulez-vous attendre la fin de l'invalidation ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⏳ Attente de la fin de l'invalidation..."
    aws cloudfront wait invalidation-completed \
        --distribution-id $DISTRIBUTION_ID \
        --id $INVALIDATION_ID
    echo "✅ Invalidation terminée !"
fi

echo "🎉 Mise à jour de l'image terminée !"