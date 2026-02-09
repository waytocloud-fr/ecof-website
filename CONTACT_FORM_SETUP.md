# Guide de déploiement du formulaire de contact ECOF

## 📋 Vue d'ensemble

Le formulaire de contact utilise :
- **Frontend** : Page Astro avec formulaire HTML/JavaScript
- **Backend** : AWS Lambda + API Gateway
- **Email** : AWS SES (Simple Email Service)
- **Infrastructure** : Terraform

---

## 🚀 Étapes de déploiement

### 1. Configurer AWS SES

#### 1.1 Vérifier l'adresse email

AWS SES nécessite de vérifier les adresses email avant de pouvoir envoyer des emails.

```bash
# Via AWS CLI
aws ses verify-email-identity --email-address contact@ecofirminy.fr --region eu-west-1

# Ou via la console AWS :
# 1. Aller dans AWS SES
# 2. Cliquer sur "Email Addresses" dans le menu
# 3. Cliquer sur "Verify a New Email Address"
# 4. Entrer : contact@ecofirminy.fr
# 5. Vérifier l'email reçu et cliquer sur le lien
```

#### 1.2 Sortir du Sandbox (IMPORTANT)

Par défaut, AWS SES est en mode "Sandbox" :
- ❌ Vous ne pouvez envoyer qu'à des adresses vérifiées
- ❌ Limite de 200 emails/jour

Pour envoyer à n'importe qui :

```
1. Aller dans AWS SES Console
2. Cliquer sur "Account Dashboard"
3. Cliquer sur "Request production access"
4. Remplir le formulaire :
   - Use case : "Transactional emails"
   - Website URL : https://votre-site.fr
   - Description : "Contact form for sports club website"
   - Compliance : Confirmer que vous respectez les règles
5. Soumettre la demande (réponse sous 24h généralement)
```

### 2. Déployer l'infrastructure avec Terraform

#### 2.1 Créer le fichier de configuration

Créer `terraform/env/prod/contact-form.tf` :

```hcl
module "contact_form" {
  source = "../../modules/contact-form"

  project_name = "ecof"
  environment  = "prod"

  tags = {
    Project     = "ECOF"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

output "contact_api_endpoint" {
  description = "URL de l'API pour le formulaire de contact"
  value       = module.contact_form.api_endpoint
}
```

#### 2.2 Déployer

```bash
cd terraform/env/prod

# Initialiser Terraform
terraform init

# Vérifier le plan
terraform plan

# Déployer
terraform apply

# Noter l'URL de l'API affichée dans les outputs
# Exemple : https://abc123.execute-api.eu-west-1.amazonaws.com/prod/contact
```

### 3. Mettre à jour la page de contact

Dans `src/pages/contact.astro`, remplacer l'URL de l'API :

```javascript
// Ligne ~180
const response = await fetch('https://YOUR_API_GATEWAY_URL/contact', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(data),
});
```

Par l'URL obtenue dans les outputs Terraform :

```javascript
const response = await fetch('https://abc123.execute-api.eu-west-1.amazonaws.com/prod/contact', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(data),
});
```

### 4. Ajouter le lien dans la navigation

#### Dans le Footer (`src/components/Footer.astro`) :

```astro
<!-- Déjà présent, vérifier le lien -->
<a href="/contact" class="text-gray-400 hover:text-white transition-colors">Contact</a>
```

#### Dans la navigation Desktop (`src/components/Navigation/DesktopNav.astro`) :

```astro
<a href="/contact" class="text-gray-700 hover:text-red-600 transition-colors font-medium">
  Contact
</a>
```

#### Dans la navigation Mobile (`src/components/Navigation/MobileNav.astro`) :

```astro
<a href="/contact" class="flex items-center space-x-3 text-gray-700 hover:text-red-600 transition-colors p-4 rounded-lg hover:bg-red-50 touch-manipulation text-lg">
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
  </svg>
  <span class="font-medium">Contact</span>
</a>
```

### 5. Builder et déployer le site

```bash
# Builder le site
npm run build

# Déployer sur S3 (adapter selon votre configuration)
aws s3 sync dist/ s3://votre-bucket-ecof/ --delete

# Invalider le cache CloudFront
aws cloudfront create-invalidation --distribution-id VOTRE_DISTRIBUTION_ID --paths "/*"
```

---

## 🧪 Tester le formulaire

### Test local (avant déploiement)

1. Modifier temporairement l'URL dans `contact.astro` pour pointer vers votre API
2. Lancer le serveur de dev : `npm run dev`
3. Aller sur `http://localhost:4321/contact`
4. Remplir et envoyer le formulaire
5. Vérifier la réception de l'email

### Test en production

1. Aller sur `https://votre-site.fr/contact`
2. Remplir le formulaire
3. Vérifier :
   - Message de succès affiché
   - Email reçu sur contact@ecofirminy.fr
   - Logs dans CloudWatch (AWS Console)

---

## 🔍 Debugging

### Vérifier les logs Lambda

```bash
# Via AWS CLI
aws logs tail /aws/lambda/ecof-contact-form --follow --region eu-west-1

# Ou via la console AWS :
# 1. Aller dans Lambda
# 2. Cliquer sur la fonction "ecof-contact-form"
# 3. Onglet "Monitor" > "View logs in CloudWatch"
```

### Erreurs courantes

#### 1. "Email address not verified"
```
Solution : Vérifier l'adresse email dans AWS SES (voir étape 1.1)
```

#### 2. "CORS error"
```
Solution : Vérifier que l'API Gateway a bien les headers CORS configurés
Le module Terraform les configure automatiquement
```

#### 3. "403 Forbidden"
```
Solution : Vérifier les permissions IAM de la fonction Lambda
La politique SES doit être attachée au rôle
```

#### 4. "Sandbox mode"
```
Solution : Demander la sortie du Sandbox (voir étape 1.2)
En attendant, vous pouvez tester en vérifiant l'email du destinataire
```

---

## 💰 Coûts AWS

### Estimation mensuelle (pour un petit club)

- **Lambda** : ~100 requêtes/mois = $0.00 (gratuit)
- **API Gateway** : ~100 requêtes/mois = $0.00 (gratuit)
- **SES** : ~100 emails/mois = $0.01
- **CloudWatch Logs** : ~0.5 GB/mois = $0.03

**Total estimé : ~$0.04/mois** (quasi gratuit !)

### Limites du tier gratuit AWS

- Lambda : 1M requêtes/mois gratuit
- API Gateway : 1M requêtes/mois gratuit (12 premiers mois)
- SES : 62,000 emails/mois gratuit (si envoyé depuis EC2, sinon $0.10/1000 emails)

---

## 🔒 Sécurité

### Protection anti-spam

Pour ajouter une protection anti-spam, vous pouvez :

#### Option 1 : Rate limiting (simple)

Ajouter dans la Lambda :

```javascript
// Limiter à 5 messages par IP par heure
const redis = require('redis'); // Ou DynamoDB
// Implémenter la logique de rate limiting
```

#### Option 2 : Google reCAPTCHA (recommandé)

1. Créer une clé reCAPTCHA v3 sur https://www.google.com/recaptcha/admin
2. Ajouter dans `contact.astro` :

```html
<script src="https://www.google.com/recaptcha/api.js?render=VOTRE_CLE_SITE"></script>

<script>
  form?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    // Obtenir le token reCAPTCHA
    const token = await grecaptcha.execute('VOTRE_CLE_SITE', {action: 'submit'});
    
    // Ajouter le token aux données
    data.recaptchaToken = token;
    
    // Envoyer...
  });
</script>
```

3. Vérifier le token dans la Lambda :

```javascript
const axios = require('axios');

// Vérifier reCAPTCHA
const recaptchaResponse = await axios.post(
  'https://www.google.com/recaptcha/api/siteverify',
  null,
  {
    params: {
      secret: process.env.RECAPTCHA_SECRET_KEY,
      response: data.recaptchaToken,
    },
  }
);

if (!recaptchaResponse.data.success || recaptchaResponse.data.score < 0.5) {
  return {
    statusCode: 400,
    body: JSON.stringify({ error: 'Échec de la vérification anti-spam' }),
  };
}
```

### Restreindre CORS en production

Dans `terraform/modules/contact-form/main.tf`, ligne ~140 :

```hcl
# Remplacer
"method.response.header.Access-Control-Allow-Origin"  = "'*'"

# Par
"method.response.header.Access-Control-Allow-Origin"  = "'https://votre-domaine.fr'"
```

---

## 📧 Personnalisation de l'email

### Modifier le template

Éditer `lambda/contact-form.js`, section HTML (ligne ~80) :

```javascript
Data: `
  <!DOCTYPE html>
  <html>
  <head>
    <style>
      /* Personnaliser les styles */
      .header { background-color: #E31E24; } /* Rouge du maillot */
    </style>
  </head>
  <body>
    <!-- Personnaliser le contenu -->
  </body>
  </html>
`,
```

### Ajouter une copie à l'expéditeur

Dans `lambda/contact-form.js`, ajouter après l'envoi principal :

```javascript
// Envoyer une copie à l'expéditeur
const confirmationParams = {
  Source: 'contact@ecofirminy.fr',
  Destination: {
    ToAddresses: [data.email],
  },
  Message: {
    Subject: {
      Data: 'Confirmation de votre message - ECOF',
      Charset: 'UTF-8',
    },
    Body: {
      Html: {
        Data: `
          <p>Bonjour ${data.name},</p>
          <p>Nous avons bien reçu votre message et nous vous répondrons dans les plus brefs délais.</p>
          <p>Cordialement,<br>L'équipe ECOF</p>
        `,
        Charset: 'UTF-8',
      },
    },
  },
};

await ses.sendEmail(confirmationParams).promise();
```

---

## ✅ Checklist de déploiement

- [ ] AWS SES configuré
  - [ ] Email contact@ecofirminy.fr vérifié
  - [ ] Demande de sortie du Sandbox effectuée
- [ ] Infrastructure déployée
  - [ ] Terraform apply réussi
  - [ ] URL de l'API notée
- [ ] Page de contact mise à jour
  - [ ] URL de l'API remplacée
  - [ ] Liens de navigation ajoutés
- [ ] Site déployé
  - [ ] Build réussi
  - [ ] Déployé sur S3
  - [ ] Cache CloudFront invalidé
- [ ] Tests effectués
  - [ ] Formulaire fonctionne
  - [ ] Email reçu
  - [ ] Messages d'erreur corrects
- [ ] Sécurité
  - [ ] CORS restreint (optionnel)
  - [ ] Anti-spam configuré (optionnel)

---

## 📞 Support

En cas de problème :

1. Vérifier les logs CloudWatch
2. Tester l'API directement avec curl :

```bash
curl -X POST https://votre-api.execute-api.eu-west-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "test@example.com",
    "subject": "information",
    "message": "Test message"
  }'
```

3. Vérifier le statut AWS SES :
   - Console AWS > SES > Account Dashboard
   - Vérifier les quotas et le statut du compte

---

**Version** : 1.0  
**Date** : Février 2026  
**Prêt pour déploiement** : ✅
