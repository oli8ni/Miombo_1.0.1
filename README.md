# Miombo Analytics Pro v2

Application webSIG de monitoring environnemental 100% serverless - Sans VPS, sans Docker.

## Stack technique

| Composant | Technologie | Cout |
|-----------|------------|------|
| Frontend | Streamlit (Python) | Gratuit |
| Données satellites | Google Earth Engine | Gratuit (compte académique/Cloud) |
| Base de données | Supabase PostgreSQL | Gratuit (500 MB) |
| Cache | Session State + Supabase | Gratuit |
| Météo | Open-Meteo API | Gratuit (pas de clé API) |
| Email | SendGrid | Gratuit (100/jour) |
| Webhook | Telegram/Discord/Slack | Gratuit |
| Hébergement | Streamlit Cloud | Gratuit |

## Déploiement étape par étape

### Étape 1: Créer un repo Git

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/TON_USER/miombo-analytics-v2.git
git push -u origin main
```

### Étape 2: Créer un projet Supabase (gratuit)

1. Va sur [supabase.com](https://supabase.com) → Sign Up
2. Create New Project → Nom: `miombo-analytics`
3. Dans le SQL Editor, copie-colle le contenu de `supabase/schema.sql`
4. Exécute le script (bouton Run)
5. Récupère tes credentials:
   - Project Settings → API
   - **URL**: `https://xxxxx.supabase.co`
   - **anon public**: `eyJhbGci...`

### Étape 3: Configurer les secrets Streamlit

1. Dans Streamlit Cloud → Settings → Secrets
2. Colle:

```toml
SUPABASE_URL = "https://ton-projet.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIs...ta-cle-anon"
SENDGRID_KEY = ""  # Optionnel - ajoute quand tu veux
WEBHOOK_URL = ""   # Optionnel - Telegram/Discord
GEE_ENABLED = true
```

### Étape 4: Déployer sur Streamlit Cloud

1. Va sur [share.streamlit.io](https://share.streamlit.io)
2. Connecte ton compte GitHub
3. Sélectionne le repo `miombo-analytics-v2`
4. Fichier principal: `app.py`
5. Deploy!

## Ce qui fonctionne immédiatement

Sans aucune configuration Supabase:
- ✅ Dashboard avec KPIs et carte interactive
- ✅ Monitoring forestier (NDVI/NDWI/NBR/EVI) - données de démo si GEE non connecté
- ✅ Détection des feux avec filtres
- ✅ Surveillance des inondations (3 méthodes)
- ✅ Météo (Open-Meteo API gratuite)
- ✅ Système d'alertes (local)
- ✅ Génération de rapports (JSON/CSV/Markdown)

Avec Supabase configuré:
- ✅ Persistance des alertes en base de données
- ✅ Règles d'alerte sauvegardées
- ✅ Multi-utilisateurs avec auth
- ✅ Historique des analyses
- ✅ Stockage des rapports générés

## Structure du projet

```
miombo_v2_complete/
├── app.py                  # Application principale (Streamlit)
├── requirements.txt        # Dépendances Python
├── .streamlit/
│   └── secrets.toml        # Configuration secrets (NE PAS COMMIT)
├── supabase/
│   └── schema.sql          # Schema PostgreSQL
└── README.md               # Ce fichier
```

## Personnalisation

### Ajouter une zone de surveillance
Dans la sidebar: sélectionne ou upload un fichier KML/GeoJSON.

### Créer une règle d'alerte
Onglet Alertes → Créer une règle → configure le seuil et les notifications.

### Notifications webhook (Telegram)
1. Crée un bot avec [@BotFather](https://t.me/BotFather) sur Telegram
2. Récupère le token et ton chat ID
3. Dans les secrets: `WEBHOOK_URL = "https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>"`

## Licence
MIT - Libre d'utilisation et de modification.
