# Sécurité Terraform - ECOF Website

Ce document décrit les mesures de sécurité implémentées dans l'infrastructure Terraform selon les exigences spécifiées.

## Problèmes corrigés

### 1. Configuration des providers
**Problème** : Le module `site-static` n'avait pas de configuration `required_providers` pour le provider `aws.us_east_1`

**Solution** : Ajout de `configuration_aliases = [aws.us_east_1]` dans le bloc `required_providers` du module

### 2. Gestion des credentials
**Problème** : Credentials AWS hardcodés dans le code source

**Solution** : Suppression des credentials hardcodés et utilisation des méthodes sécurisées :
- Variables d'environnement (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Profil AWS configuré (`~/.aws/credentials`)
- Rôle IAM (recommandé pour CI/CD)

### 3. Backend Terraform sécurisé
**Problème** : Backend S3 sans chiffrement ni verrouillage DynamoDB

**Solution** : Implémentation complète d'un backend sécurisé avec :
- Chiffrement KMS du state
- Verrouillage DynamoDB
- Versioning S3
- Réplication cross-region
- Logs d'audit

## Architecture de sécurité

### State Management sécurisé

```
┌─────────────────────────────────────────────────────────────┐
│                    Bootstrap Infrastructure                  │
├─────────────────────────────────────────────────────────────┤
│ S3 Bucket (ecof-terraform-state-secure)                    │
│ ├── Chiffrement KMS                                        │
│ ├── Versioning activé                                      │
│ ├── Accès public bloqué                                    │
│ ├── Politique HTTPS obligatoire                            │
│ └── Réplication cross-region                               │
│                                                             │
│ DynamoDB Table (ecof-terraform-locks)                      │
│ ├── Chiffrement KMS                                        │
│ ├── Point-in-time recovery                                 │
│ └── Pay-per-request billing                                │
│                                                             │
│ KMS Keys                                                    │
│ ├── Rotation automatique                                   │
│ ├── Clé principale (eu-west-3)                            │
│ └── Clé réplication (eu-west-1)                           │
└─────────────────────────────────────────────────────────────┘
```

### Principes de sécurité appliqués

1. **Defense in Depth** : Plusieurs couches de sécurité
2. **Least Privilege** : Permissions minimales requises
3. **Encryption Everywhere** : Chiffrement au repos et en transit
4. **Audit Trail** : Logs complets des accès
5. **Disaster Recovery** : Réplication et backup automatiques

## Utilisation sécurisée

### 1. Déploiement initial (Bootstrap)

```bash
# Utiliser le script sécurisé
./terraform/deploy.sh bootstrap
```

### 2. Déploiement d'environnement

```bash
# Déployer l'environnement stage
./terraform/deploy.sh deploy stage
```

### 3. Déploiement complet

```bash
# Bootstrap + environnement en une commande
./terraform/deploy.sh full stage
```

## Configuration des credentials

### Développement local
```bash
# Option 1: Variables d'environnement
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="eu-west-3"

# Option 2: Profil AWS
aws configure --profile ecof
export AWS_PROFILE=ecof
```

### CI/CD (GitHub Actions)
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
    aws-region: eu-west-3
```

## Permissions IAM minimales

### Pour les développeurs
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::ecof-terraform-state-secure",
        "arn:aws:s3:::ecof-terraform-state-secure/*"
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

## Monitoring et alertes

### CloudWatch Alarms recommandées
- Accès non autorisé au bucket state
- Échecs de verrouillage DynamoDB
- Tentatives d'accès sans chiffrement
- Modifications du state en dehors des heures ouvrables

### CloudTrail Events à surveiller
- `s3:GetObject` sur le bucket state
- `s3:PutObject` sur le bucket state
- `dynamodb:PutItem` sur la table locks
- `kms:Decrypt` sur les clés KMS

## Disaster Recovery

### Procédure de récupération

1. **Vérifier la réplication**
   ```bash
   aws s3 ls s3://ecof-terraform-state-replica --region eu-west-1
   ```

2. **Basculer vers la réplique**
   ```hcl
   terraform {
     backend "s3" {
       bucket = "ecof-terraform-state-replica"
       region = "eu-west-1"
       # ... autres paramètres
     }
   }
   ```

3. **Réinitialiser Terraform**
   ```bash
   terraform init -reconfigure
   ```

### Tests de récupération
- Test mensuel de la procédure de basculement
- Validation de l'intégrité des données répliquées
- Test de restauration depuis les versions précédentes

## Conformité et audit

### Standards respectés
- AWS Well-Architected Framework
- CIS AWS Foundations Benchmark
- NIST Cybersecurity Framework

### Audits automatisés
- AWS Config Rules pour la conformité
- AWS Security Hub pour les findings
- AWS Inspector pour les vulnérabilités

## Maintenance

### Tâches régulières
- [ ] Rotation des clés KMS (automatique)
- [ ] Nettoyage des anciennes versions du state
- [ ] Vérification des logs d'accès
- [ ] Test des procédures de disaster recovery
- [ ] Mise à jour des permissions IAM

### Alertes à configurer
- Accès suspect au bucket state
- Échecs de chiffrement/déchiffrement
- Tentatives d'accès depuis des IP non autorisées
- Modifications du state en dehors des fenêtres de maintenance