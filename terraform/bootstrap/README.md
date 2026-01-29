# Bootstrap Infrastructure Terraform

Ce dossier contient l'infrastructure de bootstrap nécessaire pour créer un backend Terraform sécurisé avec state management dans S3 et verrouillage DynamoDB.

## Sécurité implémentée

✅ **Chiffrement** : State chiffré avec KMS  
✅ **Versioning** : Historique des versions du state  
✅ **Verrouillage** : DynamoDB pour éviter les modifications concurrentes  
✅ **Accès restreint** : Politiques IAM avec principe du moindre privilège  
✅ **Logs d'audit** : Logging des accès S3  
✅ **Disaster Recovery** : Réplication cross-region  
✅ **Transport sécurisé** : HTTPS obligatoire  

## Prérequis

1. AWS CLI configuré avec des credentials administrateur
2. Terraform >= 1.0 installé

## Déploiement initial

```bash
# 1. Se placer dans le dossier bootstrap
cd terraform/bootstrap

# 2. Initialiser Terraform (local state pour le bootstrap)
terraform init

# 3. Planifier le déploiement
terraform plan

# 4. Appliquer la configuration
terraform apply

# 5. Noter les outputs pour configurer le backend
terraform output
```

## Configuration des credentials

### Option 1: Variables d'environnement (recommandé pour développement)
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-3"
```

### Option 2: Profil AWS (recommandé pour usage local)
```bash
aws configure --profile ecof
# Puis utiliser: export AWS_PROFILE=ecof
```

### Option 3: Rôle IAM (recommandé pour CI/CD)
Configurer un rôle IAM avec les permissions nécessaires et l'assumer dans le pipeline.

## Après le bootstrap

Une fois le bootstrap déployé, vous pouvez utiliser le backend sécurisé dans vos autres configurations Terraform :

```hcl
terraform {
  backend "s3" {
    bucket         = "ecof-terraform-state"
    key            = "env/stage/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "ecof-terraform-locks"
  }
}
```

## Permissions IAM minimales requises

Pour utiliser ce backend, les utilisateurs/rôles ont besoin des permissions suivantes :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::ecof-terraform-state",
        "arn:aws:s3:::ecof-terraform-state/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:eu-west-3:*:table/ecof-terraform-locks"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "arn:aws:kms:eu-west-3:*:key/*"
    }
  ]
}
```

## Disaster Recovery

En cas de problème avec la région principale (eu-west-3), le state est répliqué dans eu-west-1. Pour basculer :

1. Modifier la configuration backend pour pointer vers le bucket de réplication
2. Réinitialiser Terraform avec le nouveau backend
3. Vérifier l'intégrité du state

## Maintenance

- Les clés KMS sont configurées avec rotation automatique
- Les buckets S3 ont le versioning activé
- La table DynamoDB a la récupération point-in-time activée
- Les logs d'accès sont conservés dans un bucket séparé