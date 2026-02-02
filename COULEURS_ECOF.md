# Guide des couleurs ECOF

## 🎨 Palette de couleurs officielle

Les couleurs ont été extraites du maillot officiel de l'ECOF et intégrées dans Tailwind CSS.

### Couleurs disponibles

```css
/* Rouge ECOF (couleur principale du maillot) */
bg-ecof-red         /* #E31E24 */
bg-ecof-red-light   /* #FF4449 */
bg-ecof-red-dark    /* #C41E1A */

/* Jaune/Or ECOF (bandes du maillot) */
bg-ecof-yellow      /* #FFD700 */
bg-ecof-yellow-light /* #FFE44D */
bg-ecof-yellow-dark  /* #E6C200 */

/* Noir ECOF */
bg-ecof-black       /* #1A1A1A */
bg-ecof-black-light /* #2D2D2D */

/* Blanc ECOF */
bg-ecof-white       /* #FFFFFF */
```

## 🎯 Utilisation recommandée

### Rouge ECOF (`ecof-red`)
- Boutons principaux (CTA)
- Navigation active
- Titres importants
- Liens principaux
- Icônes principales

### Jaune ECOF (`ecof-yellow`)
- Boutons secondaires
- Badges et labels
- Accents et highlights
- États hover alternatifs
- Séparateurs visuels

### Exemples d'utilisation

```astro
<!-- Bouton principal rouge -->
<button class="bg-ecof-red hover:bg-ecof-red-dark text-white px-6 py-3 rounded-lg">
  Nous rejoindre
</button>

<!-- Bouton secondaire jaune -->
<button class="bg-ecof-yellow hover:bg-ecof-yellow-dark text-ecof-black px-6 py-3 rounded-lg">
  En savoir plus
</button>

<!-- Lien avec hover jaune -->
<a href="/" class="text-gray-700 hover:text-ecof-yellow transition-colors">
  Accueil
</a>

<!-- Badge rouge -->
<span class="bg-ecof-red text-white px-3 py-1 rounded-full text-sm">
  Compétition
</span>

<!-- Badge jaune -->
<span class="bg-ecof-yellow text-ecof-black px-3 py-1 rounded-full text-sm">
  École de vélo
</span>
```

## ✅ Améliorations appliquées

### Footer
- ✅ Logo ECOF en rouge officiel (`bg-ecof-red`)
- ✅ Liens avec hover jaune (`hover:text-ecof-yellow`)
- ✅ Réseaux sociaux avec hover jaune
- ✅ Responsivité mobile/tablette/desktop optimisée

### Responsivité du Footer

#### 📱 Mobile (< 768px)
- Une colonne verticale
- Centrage du contenu
- Espacement tactile optimisé

#### 📱 Tablette (768px - 1024px)
- Deux colonnes
- Disposition équilibrée

#### 🖥️ Desktop (> 1024px)
- Quatre colonnes complètes
- Largeur maximale contrôlée

## 🚀 Prochaines étapes

Pour une cohérence complète, vous pouvez appliquer ces couleurs à :

1. **Navigation** : Remplacer les hovers rouges par du jaune
2. **Boutons** : Créer des variantes jaunes pour les actions secondaires
3. **Badges** : Alterner rouge/jaune selon le type de contenu
4. **Gradients** : Créer des dégradés rouge → jaune pour les héros

## 📱 Test de responsivité

Le footer est maintenant parfaitement adapté à tous les appareils :
- ✅ Mobile : Layout vertical, centrage optimal
- ✅ Tablette : Layout 2 colonnes équilibré
- ✅ Desktop : Layout 4 colonnes complet
- ✅ Zones tactiles optimisées
- ✅ Couleurs ECOF intégrées