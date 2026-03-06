---
UX/UI APPLICATION MOBILE CHRIS COUTURE
1. Contexte Produit
---
# Application mobile officielle de Chris Couture.
# Objectif du MVP : vitrine digitale haut de gamme.

❌ Pas de paiement en ligne

❌ Pas de commande dans le MVP

✅ Exposition des collections

✅ Présentation des créations réalisées

✅ Mise en valeur de l’image de marque

✅ Connexion aux réseaux sociaux

✅ Back-office admin Flutter

L’application doit transmettre :

Élégance

Exclusivité

Minimalisme premium

Fluidité

Modernité

Référence UX/UI :

Zara

Balenciaga

Aime Leon Dore

Farfetch

Apple Store App

2. Architecture UX Globale

L’expérience doit être progressive, non bloquante et persuasive.

3. Flow Utilisateur Détaillé
🔹 3.1 Splash Screen

Durée : 2–3 secondes

Contenu :

Logo Chris Couture centré

Fond noir profond

Animation légère de fade-in

Micro-animation sur le logo (scale subtil)

Transition :
Fade vers onboarding ou home selon état utilisateur.

🔹 3.2 Onboarding (3 écrans max)

Design minimal.

Screen 1

Image immersive d’une collection
Titre :

L’élégance sur mesure

Screen 2

Image atelier / couture
Titre :

Chaque pièce raconte une histoire

Screen 3

Image modèle portant une création
Titre :

Découvrez nos collections exclusives

CTA principal :

"Découvrir l’univers"

CTA secondaire discret :

"Passer"

🔹 3.3 Accès invité (critique)

Si utilisateur clique sur "Continuer en invité" :

→ Accès direct à la Home.

Stratégie UX :

L’utilisateur peut explorer librement

Des micro-prompts non agressifs incitent à créer un compte

Exemple :

Sauvegarde favoris → popup :

Créez un compte pour sauvegarder vos pièces préférées

4. Authentification
🔹 4.1 Écran Login / Register

Design épuré.

Options :

Email / mot de passe

Google

Apple

Facebook

Bouton principal noir.
Bouton secondaire outline.

Micro-copy rassurante :

Accédez à votre univers couture

5. Home Screen (Client)

Structure :

🔹 Header minimal

Logo centré

Icône profil

Icône favoris

🔹 Hero Section

Carousel plein écran :

Dernière collection

Lookbook

Pièces exclusives

Animation auto-scroll lente.

🔹 Section Collections

Grid 2 colonnes :

Image

Nom

Année

Badge "Nouveau"

🔹 Section Créations Récentes

Affichage masonry premium.

🔹 Section Réseaux Sociaux

Bloc :

Suivez-nous

Affichage automatique des 10 derniers posts Instagram / Facebook

Thumbnail carré

Skeleton loader pendant fetch

Scroll horizontal

Tap → ouvre modal ou lien externe

-- 6. Page Détail Produit

Layout :

Galerie plein écran

Swipe horizontal

Zoom image

Infos :

Nom

Collection

Description

Matière

Saison

Boutons :

Ajouter aux favoris

Prendre rendez-vous

7. Système Skeleton Loading

Obligatoire pour :

Home

Collections

Détail produit

Réseaux sociaux

Utiliser shimmer subtil gris clair.

But :

Perception de rapidité

UX premium

8. Navigation

Bottom Navigation :

Accueil

Collections

Favoris

Profil

Transitions fluides (fade + slide).

9. Profil Utilisateur

Sections :

Infos personnelles

Mes favoris

Notifications

Paramètres

En invité :

Bouton principal :

Créer un compte

10. Admin App (Flutter)

Accès protégé.

Fonctions :

Ajouter collection

Ajouter produit

Modifier contenu

Upload image

Gérer mise en avant

Activer / désactiver produit

Gérer posts sociaux (fallback manuel si API fail)

UI admin :

Sidebar navigation

Data tables

Upload drag & drop

Preview produit

11. Design System
🎨 Palette

Basée sur le logo :

Noir profond #000000

Blanc cassé

Beige couture

Gris subtil

Accent or très léger

🖋 Typographie

Playfair Display (titres)

Inter ou SF Pro (corps)

Hiérarchie claire.

📐 Layout

Beaucoup d’espace blanc

Marges larges

Pas d’encombrement

12. Micro-interactions

Hover subtle (admin web)

Fade transition pages

Boutons avec légère élévation

Haptic feedback mobile

Skeleton shimmer

Lazy loading images

13. Performance

Images compressées WebP

Pagination Firestore

Cache local

Préchargement Hero images

14. Préférences Techniques
Architecture

Clean Architecture

Feature-first structure

Riverpod

GoRouter

Firebase backend

State Management

Riverpod AsyncValue

Séparation UI / logique

Sécurité

Routes protégées

Firebase rules

Rôle admin

15. Objectif UX Final

L’utilisateur doit ressentir :

Luxe

Fluidité

Modernité

Exclusivité

Sans friction.

16. Résumé Stratégique

MVP = Vitrine digitale premium.
Évolution future :

E-commerce

Paiement

Rendez-vous intégré

Notifications push

Programme fidélité