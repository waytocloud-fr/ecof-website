# ECOF Website

Site web officiel de l'École de Cyclisme de l'Ouest Forez (ECOF), construit avec Astro.

## 🚀 Architecture

- **Frontend** : Astro + Tailwind CSS
- **Hébergement** : AWS S3 + CloudFront
- **CI/CD** : GitHub Actions avec OIDC

## 📋 Prérequis

- Node.js 18+
- Compte AWS avec S3 et CloudFront configurés

## 🛠️ Installation

```bash
# Cloner le repository
git clone https://github.com/waytocloud-fr/ecof-website.git
cd ecof-website

# Installer les dépendances
npm install

# Lancer le serveur de développement
npm run dev
```

## 🎨 Développement

```bash
# Serveur de développement
npm run dev

# Build de production
npm run build

# Prévisualisation du build
npm run preview
```

## 🚀 Déploiement

### Déploiement automatique (GitHub Actions)

Le déploiement se fait automatiquement via GitHub Actions lors des push sur la branche `main`.

**Secrets GitHub requis :**
- `AWS_ROLE_ARN` : ARN du rôle IAM OIDC
- `S3_BUCKET` : Nom du bucket S3
- `CLOUDFRONT_DISTRIBUTION_ID` : ID de la distribution CloudFront

> **Note** : Le projet utilise OIDC pour l'authentification AWS, plus sécurisé que les clés d'accès traditionnelles.

### Déploiement manuel

```bash
# Build et déploiement vers AWS
./deploy.sh
```

## 🏗️ Structure du projet

```
ecof-website/
├── src/
│   ├── components/          # Composants Astro
│   ├── content/            # Contenu du site
│   │   ├── actualites/     # Articles
│   │   ├── evenements/     # Événements
│   │   ├── resultats/      # Résultats
│   │   └── sorties/        # Sorties
│   ├── layouts/            # Layouts Astro
│   ├── pages/              # Pages du site
│   └── styles/             # Styles CSS
├── public/
│   └── images/             # Images du site
├── terraform/              # Infrastructure AWS
└── scripts/                # Scripts utilitaires
```

## 🔧 Configuration

### Configuration AWS

L'infrastructure AWS est gérée via Terraform. Voir le dossier `terraform/` pour les détails.

## 📚 Documentation

- [Guide de déploiement](DEPLOYMENT.md)
- [Couleurs ECOF](COULEURS_ECOF.md)

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour obtenir de l'aide :
- Ouvrez une issue sur GitHub
- Consultez la documentation dans le dossier `docs/`
- Contactez l'équipe de développement

## 🏆 ECOF

École de Cyclisme de l'Ouest Forez - Promouvoir le cyclisme sous toutes ses formes dans la région de l'Ouest Forez.
