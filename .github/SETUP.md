# Configuration GitHub Actions - ECOF Website

Ce document explique comment configurer les secrets et permissions nécessaires pour le déploiement automatisé sécurisé.

## Secrets GitHub requis

### 1. AWS_ROLE_ARN
Rôle IAM pour GitHub Actions avec permissions minimales.

**Création du rôle IAM :**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/ecof-website:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

**Permissions du rôle :**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::ecof-*",
        "arn:aws:s3:::ecof-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "acm:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": "*"
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
      "Resource": "*"
    }
  ]
}
```

## Configuration des environnements GitHub

### 1. Créer l'environnement "stage"
1. Aller dans Settings > Environments
2. Créer un nouvel environnement "stage"
3. Configurer les règles de protection :
   - Require reviewers (optionnel)
   - Wait timer (optionnel)
   - Deployment branches: main only

### 2. Ajouter les secrets
Dans Settings > Secrets and variables > Actions :

- `AWS_ROLE_ARN`: `arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole`

## Configuration OIDC AWS

### 1. Créer le provider OIDC
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. Script de création automatique
```bash
#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO="YOUR_ORG/ecof-website"

# Créer le rôle IAM
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://github-actions-trust-policy.json

# Attacher les politiques
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/GitHubActionsPolicy

echo "Rôle créé: arn:aws:iam::$ACCOUNT_ID:role/GitHubActionsRole"
```

## Workflow de déploiement

### 1. Déclencheurs
- **Push sur main** : Déploiement automatique
- **Pull Request** : Plan Terraform uniquement

### 2. Étapes de sécurité
1. **Security Scan** : Analyse des vulnérabilités avec Trivy
2. **Terraform Plan** : Validation et planification
3. **Build & Test** : Construction et tests
4. **Deploy Infrastructure** : Déploiement Terraform
5. **Deploy Website** : Déploiement du site
6. **Security Check** : Vérifications post-déploiement

### 3. Artefacts
- Plans Terraform (5 jours)
- Build artifacts (5 jours)
- Outputs Terraform (1 jour)

## Sécurité du pipeline

### 1. Principes appliqués
- **Least Privilege** : Permissions minimales
- **Separation of Duties** : Étapes séparées
- **Audit Trail** : Logs complets
- **Fail Fast** : Arrêt en cas d'erreur

### 2. Contrôles de sécurité
- Scan de vulnérabilités obligatoire
- Validation Terraform
- Tests automatisés
- Vérifications post-déploiement

### 3. Gestion des secrets
- Pas de secrets dans le code
- Utilisation d'OIDC pour AWS
- Rotation automatique des tokens
- Chiffrement des artefacts

## Monitoring et alertes

### 1. Métriques à surveiller
- Succès/échec des déploiements
- Durée des pipelines
- Utilisation des ressources AWS
- Coûts de déploiement

### 2. Alertes recommandées
- Échec de déploiement
- Scan de sécurité échoué
- Coûts AWS anormaux
- Accès non autorisé

## Troubleshooting

### Erreurs communes

**1. "No valid credential sources found"**
```
Solution: Vérifier la configuration OIDC et le rôle IAM
```

**2. "Access Denied" sur S3**
```
Solution: Vérifier les permissions du rôle IAM
```

**3. "State lock timeout"**
```
Solution: Vérifier la table DynamoDB et les permissions
```

### Logs utiles
- GitHub Actions logs
- AWS CloudTrail
- Terraform state logs
- CloudWatch logs

## Maintenance

### Tâches régulières
- [ ] Rotation des clés d'accès
- [ ] Mise à jour des permissions IAM
- [ ] Nettoyage des artefacts anciens
- [ ] Vérification des coûts AWS
- [ ] Test des procédures de rollback

### Mises à jour
- Terraform version
- GitHub Actions versions
- Node.js version
- Dépendances npm