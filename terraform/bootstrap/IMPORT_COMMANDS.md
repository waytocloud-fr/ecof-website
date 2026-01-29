# Commandes d'Import Terraform - Ressources Existantes

## 🚀 Solution automatique (Recommandée)

```bash
cd terraform/bootstrap
./quick-fix.sh
```

## 🔍 Lister les ressources existantes

```bash
./list-existing.sh
```

## 📋 Import manuel étape par étape

### 1. Obtenir l'ID de la clé KMS
```bash
KMS_KEY_ID=$(aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3 --query 'KeyMetadata.KeyId' --output text)
echo "KMS Key ID: $KMS_KEY_ID"
```

### 2. Importer les ressources KMS
```bash
# Importer la clé KMS
terraform import aws_kms_key.terraform_state $KMS_KEY_ID

# Importer l'alias KMS
terraform import aws_kms_alias.terraform_state alias/ecof-terraform-state
```

### 3. Importer la table DynamoDB
```bash
terraform import aws_dynamodb_table.terraform_locks ecof-terraform-locks
```

### 4. Importer les buckets S3 (si ils existent)
```bash
# Vérifier d'abord s'ils existent
aws s3 ls s3://ecof-terraform-state-secure
aws s3 ls s3://ecof-terraform-logs-secure

# Importer s'ils existent
terraform import aws_s3_bucket.terraform_state ecof-terraform-state-secure
terraform import aws_s3_bucket.terraform_logs ecof-terraform-logs-secure
```

### 5. Vérifier et appliquer
```bash
# Refresh du state
terraform refresh

# Voir le plan
terraform plan

# Appliquer les changements restants
terraform apply
```

## 🧹 Nettoyage complet (Alternative)

Si vous préférez supprimer et recréer :

```bash
# Supprimer l'alias KMS
aws kms delete-alias --alias-name alias/ecof-terraform-state --region eu-west-3

# Programmer la suppression de la clé KMS (7 jours minimum)
aws kms schedule-key-deletion --key-id $KMS_KEY_ID --pending-window-in-days 7 --region eu-west-3

# Supprimer la table DynamoDB
aws dynamodb delete-table --table-name ecof-terraform-locks --region eu-west-3

# Supprimer les buckets S3 (attention aux données !)
aws s3 rb s3://ecof-terraform-state-secure --force
aws s3 rb s3://ecof-terraform-logs-secure --force

# Puis relancer le déploiement
terraform apply
```

⚠️ **Attention** : Cette approche supprime toutes les données existantes !

## 🔍 Vérification des ressources

### Lister toutes les ressources ECOF
```bash
# Tables DynamoDB
aws dynamodb list-tables --region eu-west-3 | grep ecof

# Buckets S3
aws s3 ls | grep ecof

# Clés KMS
aws kms list-aliases --region eu-west-3 | grep ecof

# Détails de la clé KMS
aws kms describe-key --key-id alias/ecof-terraform-state --region eu-west-3
```

### Vérifier le state Terraform
```bash
# Lister les ressources dans le state
terraform state list

# Voir les détails d'une ressource
terraform state show aws_kms_key.terraform_state
terraform state show aws_dynamodb_table.terraform_locks
```

## 🎯 Ordre d'import recommandé

1. **KMS Key** (dépendance pour DynamoDB et S3)
2. **KMS Alias** (référence la clé)
3. **DynamoDB Table** (utilise la clé KMS)
4. **S3 Buckets** (peuvent utiliser la clé KMS)
5. **Autres ressources S3** (versioning, encryption, etc.)

## 🚨 Erreurs courantes

### "Resource already exists"
```bash
# La ressource existe dans AWS mais pas dans Terraform
# Solution: Import avec terraform import
```

### "Resource not found"
```bash
# La ressource n'existe pas dans AWS mais Terraform pense qu'elle existe
# Solution: Supprimer du state avec terraform state rm
```

### "Invalid resource ID"
```bash
# L'ID utilisé pour l'import est incorrect
# Solution: Vérifier l'ID avec les commandes AWS CLI
```

## ✅ Validation finale

Après tous les imports :

```bash
# Le plan ne devrait montrer que des modifications mineures
terraform plan

# Appliquer pour finaliser
terraform apply

# Vérifier que tout fonctionne
terraform output
```

Le backend Terraform sécurisé devrait maintenant être opérationnel !