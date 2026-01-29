#!/bin/bash

# Script pour vérifier les ressources AWS ECOF
echo "🔍 Vérification des ressources AWS ECOF"
echo "======================================"

# Variables
S3_BUCKET="ecof-website-stage-6e85ed80"
CLOUDFRONT_DISTRIBUTION_ID="EA2FNVF5R7H6G"

# Vérifier l'authentification AWS
echo "1. Vérification de l'authentification AWS..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
    echo "✅ Authentifié en tant que: $USER_ARN"
    echo "   Compte AWS: $ACCOUNT_ID"
else
    echo "❌ Erreur d'authentification AWS"
    exit 1
fi

echo ""

# Vérifier le bucket S3
echo "2. Vérification du bucket S3..."
if aws s3 ls s3://$S3_BUCKET > /dev/null 2>&1; then
    echo "✅ Bucket S3 accessible: $S3_BUCKET"
    
    # Vérifier la configuration du bucket
    WEBSITE_CONFIG=$(aws s3api get-bucket-website --bucket $S3_BUCKET 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "   📄 Configuration website activée"
    else
        echo "   ⚠️  Configuration website non trouvée"
    fi
    
    # Compter les objets
    OBJECT_COUNT=$(aws s3 ls s3://$S3_BUCKET --recursive | wc -l)
    echo "   📁 Nombre d'objets: $OBJECT_COUNT"
else
    echo "❌ Bucket S3 non accessible: $S3_BUCKET"
    echo "   Vérifiez le nom du bucket et les permissions"
fi

echo ""

# Vérifier la distribution CloudFront
echo "3. Vérification de la distribution CloudFront..."
if aws cloudfront get-distribution --id $CLOUDFRONT_DISTRIBUTION_ID > /dev/null 2>&1; then
    echo "✅ Distribution CloudFront accessible: $CLOUDFRONT_DISTRIBUTION_ID"
    
    # Obtenir le domaine
    DOMAIN_NAME=$(aws cloudfront get-distribution --id $CLOUDFRONT_DISTRIBUTION_ID --query 'Distribution.DomainName' --output text)
    STATUS=$(aws cloudfront get-distribution --id $CLOUDFRONT_DISTRIBUTION_ID --query 'Distribution.Status' --output text)
    
    echo "   🌐 Domaine: https://$DOMAIN_NAME"
    echo "   📊 Statut: $STATUS"
    
    # Vérifier les invalidations récentes
    INVALIDATIONS=$(aws cloudfront list-invalidations --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --query 'InvalidationList.Items[0].Status' --output text 2>/dev/null)
    if [ "$INVALIDATIONS" != "None" ] && [ "$INVALIDATIONS" != "" ]; then
        echo "   🔄 Dernière invalidation: $INVALIDATIONS"
    fi
else
    echo "❌ Distribution CloudFront non accessible: $CLOUDFRONT_DISTRIBUTION_ID"
    echo "   Vérifiez l'ID de distribution et les permissions"
fi

echo ""

# Vérifier les permissions IAM (si possible)
echo "4. Vérification des permissions..."
echo "   Permissions S3:"
if aws s3api get-bucket-policy --bucket $S3_BUCKET > /dev/null 2>&1; then
    echo "   ✅ Politique de bucket accessible"
else
    echo "   ⚠️  Politique de bucket non accessible (normal si pas de politique)"
fi

echo "   Permissions CloudFront:"
if aws cloudfront list-distributions > /dev/null 2>&1; then
    echo "   ✅ Permissions CloudFront OK"
else
    echo "   ❌ Permissions CloudFront insuffisantes"
fi

echo ""
echo "🎉 Vérification terminée !"
echo ""
echo "📋 Résumé pour GitHub Actions:"
echo "   S3_BUCKET: $S3_BUCKET"
echo "   CLOUDFRONT_DISTRIBUTION_ID: $CLOUDFRONT_DISTRIBUTION_ID"
echo "   AWS_REGION: eu-west-3"
echo ""
echo "🔗 URL du site: https://$DOMAIN_NAME"