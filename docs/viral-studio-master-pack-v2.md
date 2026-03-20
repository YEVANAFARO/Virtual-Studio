# VIRAL STUDIO

## Master Pack V2 — Produit, MVP, UX, data, IA, build et prompt Codex

Document de cadrage complet pour construire Viral Studio : vision, positionnement, MVP, écrans, design system, base de données, endpoints, prompts IA, roadmap, stratégie de lancement et prompt maître pour Codex.

**Objectif principal :** qu’un utilisateur ouvre l’app et sache immédiatement quoi poster aujourd’hui, comment le dire, et comment mesurer sa progression.

---

## 1. Résumé exécutif

- Viral Studio est un coach IA mobile-first pour créateurs débutants, micro-influenceurs, freelances, experts et petites marques personnelles.
- Le produit ne se positionne pas comme un simple outil de social media scheduling. Il agit comme un copilote de croissance : il donne une idée du jour, un plan de contenu, une aide à l’exécution, puis une preuve de progression.
- Promesse : passer de créateur perdu à créateur qui grandit avec une vraie stratégie quotidienne.

---

## 2. Vision, promesse et positionnement

- Vision : créer le coach de croissance personnel des petits créateurs.
- Mantra : chaque jour une idée, chaque semaine une stratégie, chaque mois une progression visible.
- Positionnement : AI Growth Copilot for Creators.
- Différence clé : Viral Studio orchestre la clarté, la régularité et la progression visible, là où la plupart des outils se limitent à publier, analyser ou générer du texte.

---

## 3. Cibles et problèmes à résoudre

- Créateur débutant : ne sait pas quoi poster, manque de confiance, poste de manière irrégulière.
- Créateur intermédiaire : publie déjà mais stagne, ne comprend pas pourquoi certains contenus performent.
- Freelance / coach / expert : veut transformer son contenu en visibilité, crédibilité et opportunités business.
- Problèmes à résoudre : manque d’idées, manque de méthode, manque de différenciation, manque de feedback compréhensible, manque de temps.

---

## 4. MVP strict à construire

- Auth
- Onboarding intelligent
- Onboarding summary
- Home / cockpit
- Daily Idea
- Create / générateur de contenu
- Plan 7 Days
- Growth dashboard simple
- Before / After
- Pricing
- Settings

### Ce qui sort du MVP
- Autopost multi-plateformes avancé
- Inbox commentaires cross-platform complète
- Clone de ton avancé
- Trend engine temps réel complexe
- Viral score sophistiqué
- Benchmark concurrence
- Automatisations risquées ou non fiables

---

## 5. Vue d’ensemble du MVP

### Promesse MVP
Le MVP doit permettre à l’utilisateur de vivre cette séquence en moins de 10 minutes :
1. je m’inscris,
2. je définis mon profil,
3. je reçois mon idée du jour,
4. je vois mon plan 7 jours,
5. je peux générer un contenu,
6. je vois déjà comment suivre ma progression.

### Règle produit
Le MVP ne cherche pas à automatiser tout le social media. Il cherche à créer :
- de la clarté,
- de la régularité,
- de la guidance,
- de la progression visible.

### Stack MVP imposée
- FlutterFlow
- Supabase
- OpenAI API
- RevenueCat

### Règle technique
- Pas de dépendance critique à une API sociale externe.
- Toutes les données de croissance peuvent être saisies manuellement au départ.
- Toute la logique IA doit passer par backend sécurisé.

---

## 6. Architecture FlutterFlow complète

### Structure app
Navigation basse recommandée :
- Home
- Plan
- Create
- Growth
- Settings

### Flow principal
Signup → Onboarding → Résumé → Home → Daily Idea / Create / Plan → Growth → Before/After.

### Pages FlutterFlow à créer
- SplashPage
- AuthPage
- OnboardingStepGoalPage
- OnboardingStepPlatformPage
- OnboardingStepNichePage
- OnboardingStepTonePage
- OnboardingStepLevelPage
- OnboardingStepFrequencyPage
- OnboardingSummaryPage
- MainNavPage
- HomePage
- DailyIdeaPage
- CreatePage
- Plan7DaysPage
- GrowthPage
- BeforeAfterPage
- PricingPage
- SettingsPage
- ManualStatsBottomSheet
- ReplacePlanItemBottomSheet

### Architecture logicielle
- FlutterFlow UI + navigation + état local/global.
- Supabase Auth + DB + RLS.
- Backend API pour IA et orchestration.
- RevenueCat pour paiement.

### Recommandation d’implémentation
Dans FlutterFlow, ne pas faire porter la logique métier lourde au front. Le front doit :
- afficher,
- saisir,
- appeler,
- naviguer.

Le backend doit :
- générer l’IA,
- valider le JSON,
- persister les données complexes,
- recalculer les objets composites.

---

## 7. Arborescence des écrans

```text
SplashPage
└── AuthPage
    └── OnboardingStepGoalPage
        └── OnboardingStepPlatformPage
            └── OnboardingStepNichePage
                └── OnboardingStepTonePage
                    └── OnboardingStepLevelPage
                        └── OnboardingStepFrequencyPage
                            └── OnboardingSummaryPage
                                └── MainNavPage
                                    ├── HomePage
                                    ├── Plan7DaysPage
                                    ├── CreatePage
                                    ├── GrowthPage
                                    └── SettingsPage
DailyIdeaPage
BeforeAfterPage
PricingPage
ManualStatsBottomSheet
ReplacePlanItemBottomSheet
```

---

## 8. Navigation globale

### Splash
- si user non connecté → AuthPage
- si user connecté mais sans profil → OnboardingStepGoalPage
- si user connecté avec `onboarding_complete = false` → OnboardingStepGoalPage
- sinon → MainNavPage / HomePage

### Auth
- login/signup succès → vérifier `creator_profiles`
- pas de profil → OnboardingStepGoalPage
- profil incomplet → OnboardingStepGoalPage
- profil complet → MainNavPage

### Home
- action du jour → DailyIdeaPage
- preview idée du jour → DailyIdeaPage
- raccourci Create → CreatePage
- raccourci Plan → Plan7DaysPage
- raccourci Growth → GrowthPage

### Growth
- bouton Voir avant/après → BeforeAfterPage
- bouton Upgrade → PricingPage

### Settings
- bouton abonnement → PricingPage
- bouton logout → AuthPage

---

## 9. App State FlutterFlow

### Globals
- `appUserId` : String
- `hasCompletedOnboarding` : bool
- `isPremium` : bool
- `currentPlanId` : String
- `todayIdeaId` : String
- `momentumScore` : int

### Onboarding states
- `onboardingGoal` : String
- `onboardingPlatform` : String
- `onboardingNiche` : String
- `onboardingTone` : String
- `onboardingLevel` : String
- `onboardingFrequency` : int
- `onboardingPreferredFormats` : List<String>

### Create states
- `selectedCreatePlatform` : String
- `selectedCreateFormat` : String
- `selectedCreateTone` : String
- `createBrief` : String
- `generatedHooks` : List<String>
- `generatedCaption` : String
- `generatedScript` : String
- `generatedHashtags` : List<String>
- `generatedCTA` : String
- `generatedToneVariants` : JSON

### Growth states
- `manualFollowersInput` : int
- `manualEngagementInput` : double
- `manualPostsInput` : int

### Local page states recommandés
- `isLoadingProfile`
- `isBuildingStrategy`
- `isRegeneratingIdea`
- `isGeneratingContent`
- `showManualStatsForm`
- `selectedPlanItemId`

---

## 10. Identité produit et design system

Direction artistique : dark mode premium, moderne, mobile-first, avec une esthétique claire, motivante et orientée croissance.

| Élément | Valeur | Usage |
|---|---|---|
| Fond principal | `#0B1020` | Fond global de l’app |
| Cartes | `#121A2F` | Modules, cards, surfaces élevées |
| Texte principal | `#F4F7FB` | Titres, chiffres, contenu clé |
| Texte secondaire | `#A8B3C7` | Labels, explications, métadonnées |
| Violet IA | `#7B61FF` | Titres clés, accent IA, highlights |
| Bleu électrique | `#39A0FF` | Actions secondaires, navigation, infos |
| Corail viral | `#FF6B6B` | Énergie, signaux créatifs |
| Vert croissance | `#22C55E` | Croissance, validation, succès |
| CTA principal | `#7B61FF → #FF4D9D` | Boutons principaux et actions à forte priorité |

Typographies recommandées : Inter ou SF Pro pour le corps et l’UI ; Sora ou Plus Jakarta Sans pour les titres.
Radius : 16 px pour boutons, 20-24 px pour cartes.

---

## 11. Structure app et navigation

- Navigation basse recommandée : Home, Plan, Create, Growth, Settings.
- Flow principal : Signup → Onboarding → Résumé → Home → Daily Idea / Create / Plan → Growth → Before/After.
- Question fondamentale du Home : **“Qu’est-ce que je fais maintenant ?”**

---

## 12. Écrans clés — résumé exécutable

### Splash
Logo VS, tagline, vérification auth, redirection automatique selon état de session et onboarding.

### Auth
Connexion email/Google, CTA simples, faible friction, redirection intelligente.

### Onboarding
Objectif, plateforme, niche, ton, niveau, fréquence, formats préférés.

### Onboarding Summary
Résumé profil, 3 opportunités, preview idée du jour, CTA “Ouvrir mon studio”.

### Home
Score momentum, action du jour, preview idée du jour, mini progression, raccourcis vers Plan / Create / Growth.

### Daily Idea
Titre idée, why now, hook, structure, caption, hashtags, format, heure, mission engagement, CTA régénérer / créer / ajouter au calendrier.

### Create
Sélecteurs plateforme/format/ton, brief libre, tabs Hook/Caption/Script/Hashtags/CTA, sauvegarde génération.

### Plan 7 Days
7 cartes, sujet, angle, ton, créneau, mission engagement, effort, statut, actions fait/remplacer/générer brouillon.

### Growth
KPI, courbe, top format, meilleure tonalité, insight principal, accès Before/After.

### Before / After
Comparaison baseline vs maintenant, deltas, timeline de progression, CTA partage / prochain mois.

### Pricing
Plans Free / Pro / Growth, bénéfices et CTA RevenueCat.

### Settings
Profil, niche, ton, fréquence, abonnement, déconnexion.

---

## 13. Détail écran par écran — structure FlutterFlow

| Page | Blocs UI | Données | Actions |
|---|---|---|---|
| Home | Header prénom + notif, card Momentum, card Action du jour, card Daily Idea preview, mini progression, accès rapides, tab bar. | `creator_profiles`, `daily_ideas` (today), `weekly_plan_items`, `growth_snapshots` latest | Créer maintenant, Voir le détail, Aller au plan, Aller à Growth |
| Daily Idea | Hero card idée, why now, hook, structure, caption, hashtags, format+heure, mission engagement, sticky CTA. | `daily_ideas by date` | Régénérer, Ajouter au calendrier, En faire un script |
| Create | Dropdown plateforme, dropdown format, chips ton, brief, générer, tabs résultats, sauvegarder. | `content_generations` insert/update | Générer, Sauvegarder, Copier, Variantes |
| Plan 7 Days | ListView 7 cards avec sujet, angle, ton, créneau, mission, effort, statut. | `weekly_plans`, `weekly_plan_items` | Marquer fait, Remplacer, Générer brouillon |
| Growth | Row KPI, line chart, top format, meilleure tonalité, main insight, bouton Before/After. | `growth_snapshots`, `baseline_snapshots` | Enregistrer mes stats, Voir avant/après |
| Before / After | Cartes comparatives, deltas, timeline progression, CTA partage. | `baseline_snapshots latest`, `growth_snapshots latest` | Partager, Préparer prochain mois |

---

## 14. Tables Supabase détaillées

Le SQL exécutable est fourni dans :
`supabase/migrations/20260319_001_viral_studio_mvp.sql`

### creator_profiles
- `id`
- `user_id`
- `niche`
- `primary_platform`
- `goal`
- `desired_tone`
- `level`
- `frequency_per_week`
- `preferred_formats`
- `language`
- `country`
- `onboarding_complete`
- `created_at`
- `updated_at`

### daily_ideas
- `id`
- `user_id`
- `idea_date`
- `idea_title`
- `why_now`
- `topic`
- `angle`
- `hook`
- `content_structure`
- `caption`
- `cta`
- `hashtags`
- `recommended_format`
- `recommended_time`
- `engagement_mission`
- `effort_level`
- `confidence_note`

### weekly_plans
- `id`
- `user_id`
- `week_start`
- `week_theme`
- `coach_note`

### weekly_plan_items
- `id`
- `weekly_plan_id`
- `day_index`
- `platform`
- `objective`
- `format`
- `topic`
- `angle`
- `tone`
- `time_window`
- `engagement_task`
- `effort`
- `status`

### content_generations
- `id`
- `user_id`
- `source_brief`
- `platform`
- `format`
- `tone`
- `hooks`
- `caption`
- `script`
- `hashtags`
- `cta`
- `tone_variants`

### growth_snapshots
- `id`
- `user_id`
- `snapshot_date`
- `followers_total`
- `engagement_rate`
- `posts_count`
- `regularity_rate`
- `top_format`
- `main_insight`

### baseline_snapshots
- `id`
- `user_id`
- `baseline_date`
- `followers_baseline`
- `engagement_baseline`
- `posts_baseline`
- `notes`

### subscriptions
- `id`
- `user_id`
- `plan_name`
- `status`
- `started_at`
- `expires_at`

---

## 15. Endpoints API MVP

| Endpoint | Méthode | Input | Output |
|---|---|---|---|
| `/api/v1/daily-idea` | POST | `creator_profile`, `recent_growth` optional | idée du jour complète en JSON |
| `/api/v1/weekly-plan` | POST | `creator_profile` | plan 7 jours + coach_note |
| `/api/v1/weekly-plan/replacement` | POST | `creator_profile`, `existing_item_context` | nouvelle suggestion pour un item du plan |
| `/api/v1/generate-content` | POST | `creator_profile`, `brief`, `platform`, `format`, `tone` | hooks, caption, script, hashtags, cta, tone_variants |
| `/api/v1/growth-insight` | POST | `baseline`, `latest_growth` | wins, weak_signals, actions_next_week, main_insight |
| `/api/v1/subscriptions/sync` | POST | `user_id`, `plan`, `status` | synchronisation abonnement / RevenueCat |

---

## 16. Prompts IA — API ready (résumé)

### Daily Idea Engine
Produit une idée quotidienne personnalisée : titre, why_now, topic, angle, hook, structure, caption, CTA, hashtags, format, heure, mission engagement, effort, confidence note.

### Weekly Plan Engine
Construit un plan 7 jours réaliste en fonction du niveau, du temps disponible, de la plateforme et de l’objectif.

### Content Engine
Transforme un brief en hooks, caption, script, hashtags, CTA et variantes de ton.

### Growth Insight Engine
Analyse baseline + snapshots récents pour générer des insights simples, des gains, des signaux faibles et 3 actions prioritaires.

### Exemple de JSON — Daily Idea
```json
{
  "idea_title": "string",
  "why_now": "string",
  "topic": "string",
  "angle": "string",
  "hook": "string",
  "content_structure": ["string", "string", "string", "string"],
  "caption": "string",
  "cta": "string",
  "hashtags": ["#string"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "string",
  "effort_level": "low",
  "confidence_note": "string"
}
```

---

## 17. Détail FlutterFlow écran par écran

### A. Splash
**Widgets**
- Container full screen
- Column centrée
- Image logo VS
- Text : Viral Studio
- Text : Votre copilote IA de croissance créateur
- CircularProgressIndicator ou loader discret

**Actions on page load**
- Vérifier si user connecté
- Si non connecté → AuthPage
- Si connecté : query `creator_profiles` par `user_id`
- si `onboarding_complete = true` → HomePage
- sinon → OnboardingStepGoalPage

### B. Auth
**Widgets**
- Column
- Text titre
- Text sous-titre
- Button Continuer avec Google
- TextField email
- TextField mot de passe
- Button Commencer gratuitement
- TextButton J’ai déjà un compte

**Actions**
- Google auth
- Email/password signup ou login
- Après succès : fetch profile puis redirection intelligente

### C. OnboardingStepGoal
**Widgets**
- ProgressBar
- Text : Quel est votre objectif principal ?
- ChoiceChip / Wrap
- Button Continuer
- TextButton Retour

**App State**
- `onboardingGoal`

### D. OnboardingStepPlatform
**Widgets**
- ProgressBar
- Selectable cards : Instagram / TikTok / LinkedIn / YouTube Shorts
- Button Continuer

**App State**
- `onboardingPlatform`

### E. OnboardingStepNiche
**Widgets**
- Text
- TextField niche
- Suggestion chips
- Button Continuer

**App State**
- `onboardingNiche`

### F. OnboardingStepTone
**Widgets**
- Choice chips : authentique / expert / drôle / inspirant / direct / éducatif
- Button Continuer

**App State**
- `onboardingTone`

### G. OnboardingStepLevel
**Widgets**
- Choice cards : je démarre / je poste déjà un peu / je suis régulier mais je stagne
- Button Continuer

**App State**
- `onboardingLevel`

### H. OnboardingStepFrequency
**Widgets**
- Choice cards : 2 fois/semaine / 4 fois/semaine / 1 fois/jour
- Button Construire ma stratégie

**Actions**
- Upsert `creator_profiles`
- Call `/daily-idea`
- Insert / upsert `daily_ideas`
- Call `/weekly-plan`
- Insert `weekly_plans` + `weekly_plan_items`
- Navigate `OnboardingSummary`

### I. OnboardingSummary
**Widgets**
- Hero card
- Card résumé profil
- Card 3 opportunités
- Card preview idée du jour
- Button Ouvrir mon studio

### J. Home
**Ordre exact**
- Header prénom + notif
- Card Momentum
- Card Action du jour
- Card Daily Idea preview
- Card Mini progression
- Card accès rapide
- BottomNavigationBar

### K. DailyIdea
**Widgets**
- Date
- Hero Card
- Hook
- Structure
- Caption
- Hashtags
- Format + Heure
- Mission engagement
- Sticky CTA

### L. Create
**Widgets**
- Dropdown plateforme
- Dropdown format
- Choice chips ton
- TextField brief
- Button Générer
- TabBar Hooks / Caption / Script / Hashtags / CTA
- Result cards
- Buttons Sauvegarder / Copier / Variantes

### M. Plan7Days
**Widgets**
- Text thème semaine
- ListView 7 cards
- Boutons fait / remplacer / générer brouillon

### N. Growth
**Widgets**
- KPI row
- LineChart
- Top format
- Meilleure tonalité
- Main insight
- Button Voir avant/après
- Formulaire manuel si pas de data

### O. BeforeAfter
**Widgets**
- Hero Card
- Comparison cards
- Delta chips
- Timeline
- Buttons partager / préparer prochain mois

### P. Pricing
**Widgets**
- Hero title
- Pricing cards Free / Pro / Growth
- CTA Subscribe

### Q. Settings
**Widgets**
- Profil résumé
- Modifier niche / ton / fréquence
- Abonnement
- Logout

---

## 18. SQL Supabase complet

Le SQL complet est déjà versionné ici :
- `supabase/migrations/20260319_001_viral_studio_mvp.sql`

### Ce que la migration couvre
- création des tables MVP,
- contraintes et checks,
- indexes,
- trigger `updated_at`,
- activation du RLS,
- policies utilisateur,
- ownership check sur `weekly_plan_items` via `weekly_plans`.

---

## 19. Actions FlutterFlow les plus importantes

### Action “Construire ma stratégie”
- upsert `creator_profiles`
- call `/daily-idea`
- insert `daily_ideas`
- call `/weekly-plan`
- insert `weekly_plans`
- insert `weekly_plan_items`
- navigate `OnboardingSummary`

### Action “Générer” dans Create
- vérifier brief
- call `/generate-content`
- set App State résultats
- insert `content_generations`
- afficher tabs résultats

### Action “Enregistrer mes stats” dans Growth
- si pas baseline → insert `baseline_snapshots`
- insert `growth_snapshots`
- refresh KPI
- afficher CTA avant/après

---

## 20. Wow features et différenciation

- Avant / Après Viral Studio : matérialiser la progression noir sur blanc.
- Mode créateur débutant guidé : missions simples, rassurantes, non culpabilisantes.
- Copilote d’engagement : détecter les commentaires à fort potentiel et transformer certaines questions en idées de posts.
- Détecteur de potentiel de contenu : score prudent avant publication, avec sous-scores et améliorations.
- Clone de ton progressif : cohérence éditoriale, pas imitation artificielle.
- Radar d’opportunités : trend adaptée, contenu à recycler, meilleur créneau.
- Journal de croissance créateur : timeline des déclics et victoires importantes.

---

## 21. Roadmap de build — 6 sprints

### Sprint 1
Auth, onboarding, creator_profiles, navigation principale.

### Sprint 2
Daily Idea API, écran Daily Idea, Home branché.

### Sprint 3
Weekly plan API, tables `weekly_plans`/`weekly_plan_items`, écran Plan 7 Days.

### Sprint 4
Create API, écran Create, sauvegarde `content_generations`.

### Sprint 5
Growth, baseline manuelle, Before/After, graphiques simples.

### Sprint 6
Pricing, RevenueCat, polish UI, tests utilisateurs, bêta.

---

## 22. Données à simuler manuellement au début

- followers actuels,
- engagement estimé,
- posts du mois,
- top format,
- insight principal,
- baseline initiale,
- progression hebdomadaire.

### Principe
Tant que les intégrations sociales ne sont pas branchées, l’utilisateur peut entrer ses stats à la main. Cela suffit pour valider la promesse de progression visible.

---

## 23. Pièges à éviter

- Brancher des APIs sociales complexes trop tôt.
- Surpromettre l’automatisation.
- Faire dépendre le Home de trop de requêtes.
- Gérer OpenAI directement côté client.
- Ne pas valider les réponses JSON IA.
- Construire un dashboard vide sans fallback de saisie manuelle.
- Complexifier l’onboarding avec trop de questions dès la V1.
- Trop disperser le MVP hors du noyau Home / Daily Idea / Plan / Growth.

---

## 24. Stratégie 100 premiers utilisateurs

- Choisir un segment de départ : soit créateurs lifestyle Instagram/TikTok, soit coachs/freelances/experts Instagram+LinkedIn. Le segment experts/freelances est souvent plus simple à convertir au départ.
- Landing page simple : “Ne postez plus au hasard. Viral Studio vous dit quoi publier, comment le dire et comment voir votre progression.”
- Contenu organique : build in public sur LinkedIn / Reels / TikTok.
- DM ciblés à 10 puis 50 micro-créateurs ou experts pour tester la bêta gratuitement.
- Offre bêta : accès gratuit 30 jours contre feedback ou bêta fondatrice à petit prix.

---

## 25. Recommandations finales

- Le premier miracle du produit n’est pas l’automatisation : c’est la clarté immédiate.
- Le noyau à protéger : Home, Daily Idea, Plan, Growth.
- Ne pas survendre la viralité. Promesse crédible : plus de structure, plus de régularité, plus de progression visible.
- Construire d’abord la valeur perçue en 7 jours : profil, idée du jour, premier contenu, premier mini rapport, premier avant/après.

---

## Annexe A — Prompt maître pour Codex

Tu es un expert senior en product design, FlutterFlow, Supabase, OpenAI API, architecture SaaS et build MVP.

Ta mission : transformer le document Viral Studio fourni en plan de construction exécutable.

Tu dois produire :
1. l’architecture FlutterFlow complète ;
2. le SQL Supabase des tables et relations ;
3. les endpoints API et leurs payloads JSON ;
4. les prompts IA API-ready ;
5. le détail écran par écran (widgets, ordre, bindings, actions, états) ;
6. le build sprint par sprint ;
7. les données à simuler manuellement au début ;
8. les pièges à éviter.

Contraintes :
- mobile-first ;
- simple ;
- rapide à builder ;
- sans dépendre d’intégrations complexes au départ ;
- scope MVP contrôlé.

Le MVP contient uniquement : Auth, Onboarding, Onboarding Summary, Home, Daily Idea, Create, Plan 7 Days, Growth, Before/After, Pricing, Settings.

Le Home doit répondre à : “Qu’est-ce que je fais maintenant ?”
Le cœur produit est : clarté, régularité, guidance, progression visible.

Format final demandé :
1. Vue d’ensemble du MVP
2. Arborescence des écrans
3. Navigation globale
4. App State FlutterFlow
5. Tables Supabase détaillées
6. Détail écran par écran FlutterFlow
7. Endpoints API
8. Prompts IA API-ready
9. Build sprint par sprint
10. Données à simuler manuellement au début
11. Pièges à éviter
12. Recommandations finales de build

Sois extrêmement concret. Ne donne pas de théorie inutile. Écris comme un CTO qui doit livrer en 30 jours.

---

## Annexe B — Comment utiliser ce pack

- Envoyer ce document à Codex avec le prompt maître.
- En second message, demander 4 livrables séparés : spec FlutterFlow, SQL Supabase, endpoints backend, checklists sprint par sprint.
- Ne pas lancer simultanément tout le scope. Commencer par le MVP strict décrit dans ce document.
