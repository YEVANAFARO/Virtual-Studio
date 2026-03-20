# Viral Studio — FlutterFlow MVP Screens Pack

> Détail écran par écran du MVP Viral Studio. Scope strict : widgets, ordre, actions, bindings, empty states, loading states, error states.

## 1. SplashPage

### Nom exact
- `SplashPage`

### Widgets exacts
- `Container` full-screen
- `Column` centrée verticalement
- `Image` logo Viral Studio
- `Text` titre `Viral Studio`
- `Text` sous-titre `Votre copilote IA de croissance créateur`
- `SizedBox` spacing
- `CircularProgressIndicator`

### Ordre des blocs
1. Logo
2. Titre
3. Sous-titre
4. Loader

### Actions au clic
- Aucune action manuelle
- `On Page Load` :
  1. vérifier session Supabase
  2. si user absent → navigate `AuthPage`
  3. si user présent → query `creator_profiles`
  4. si profil absent ou `onboarding_complete = false` → navigate `OnboardingStepGoalPage`
  5. sinon → navigate `MainShellPage` avec onglet `HomePage`

### Bindings de données
- Aucun binding visuel requis
- Binding logique au résultat de la session auth et de `creator_profiles.onboarding_complete`

### Empty states
- Aucun empty state dédié

### Loading states
- Loader affiché tant que session + profil ne sont pas résolus

### Error states
- Si la requête profil échoue : afficher `Text` `Impossible de charger votre studio.`
- Bouton secondaire `Réessayer`
- Bouton tertiaire `Retour à la connexion`

## 2. AuthPage

### Nom exact
- `AuthPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Image` logo réduit
- `Text` titre `Commencez gratuitement`
- `Text` sous-titre `Recevez chaque jour une idée claire, un plan simple et un vrai cap.`
- `Button` `Continuer avec Google`
- `Divider` avec texte `ou`
- `TextFormField` email
- `TextFormField` password
- `Button` primaire `Créer mon compte`
- `Button` secondaire `J’ai déjà un compte`
- `TextButton` `Mot de passe oublié` optionnel

### Ordre des blocs
1. Logo
2. Titre
3. Sous-titre
4. Bouton Google
5. Divider
6. Champ email
7. Champ password
8. CTA principal
9. CTA login
10. Lien mot de passe oublié

### Actions au clic
- `Continuer avec Google` → auth Google Supabase → fetch `creator_profiles` → redirection conditionnelle
- `Créer mon compte` → sign up email/password → fetch `creator_profiles` → navigate onboarding ou app
- `J’ai déjà un compte` → log in email/password → fetch `creator_profiles` → navigate onboarding ou app
- `Mot de passe oublié` → reset password email

### Bindings de données
- Binding des champs vers controllers locaux `emailController`, `passwordController`
- Binding logique sur `AuthPage.isSubmittingAuth`

### Empty states
- Aucun

### Loading states
- Désactiver tous les boutons pendant auth
- Remplacer le texte du CTA actif par `Connexion...` ou `Création...`
- Afficher un petit `CircularProgressIndicator` dans le bouton actif

### Error states
- Validation email invalide → message inline sous le champ email
- Password vide ou trop court → message inline sous le champ password
- Erreur auth Supabase → snackbar `Connexion impossible. Vérifiez vos identifiants.`
- Erreur réseau → snackbar `Connexion réseau impossible.`

## 3. OnboardingStepGoalPage

### Nom exact
- `OnboardingStepGoalPage`

### Widgets exacts
- `SafeArea`
- `Column`
- `LinearProgressIndicator` à 1/6
- `Text` question `Quel est votre objectif principal ?`
- `Text` aide `Choisissez l’objectif le plus important pour les 30 prochains jours.`
- `Wrap` de `ChoiceChip` :
  - `Gagner des abonnés`
  - `Plus d’engagement`
  - `Plus de visibilité`
  - `Trouver des clients`
  - `Développer ma marque`
- `Spacer`
- `Button` primaire `Continuer`
- `TextButton` secondaire `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Texte d’aide
4. Choice chips
5. Bouton continuer
6. Bouton retour

### Actions au clic
- Tap sur chip → set `FFAppState().onboardingGoal`
- `Continuer` → navigate `OnboardingStepPlatformPage`
- `Retour` → navigate `AuthPage`

### Bindings de données
- `ChoiceChip.selected` lié à `FFAppState().onboardingGoal`
- Bouton `Continuer` activé seulement si `onboardingGoal` non vide

### Empty states
- État initial : aucun choix sélectionné, CTA désactivé

### Loading states
- Aucun

### Error states
- Si l’utilisateur clique `Continuer` sans sélection → snackbar `Choisissez un objectif pour continuer.`

## 4. OnboardingStepPlatformPage

### Nom exact
- `OnboardingStepPlatformPage`

### Widgets exacts
- `SafeArea`
- `Column`
- `LinearProgressIndicator` à 2/6
- `Text` question `Où voulez-vous progresser en premier ?`
- `Text` aide `Choisissez la plateforme à prioriser pour votre MVP créateur.`
- `Column` de `SelectableCard` custom :
  - Instagram
  - TikTok
  - LinkedIn
  - YouTube Shorts
  - X / Twitter
- `Spacer`
- `Button` primaire `Continuer`
- `TextButton` `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Aide
4. Liste de cartes plateforme
5. CTA
6. Retour

### Actions au clic
- Tap carte → set `FFAppState().onboardingPlatform`
- `Continuer` → navigate `OnboardingStepNichePage`
- `Retour` → navigate `OnboardingStepGoalPage`

### Bindings de données
- État sélectionné de la carte lié à `onboardingPlatform`
- CTA activé si une plateforme est sélectionnée

### Empty states
- Aucune sélection = CTA désactivé

### Loading states
- Aucun

### Error states
- Snackbar si CTA forcé sans plateforme : `Sélectionnez votre plateforme principale.`

## 5. OnboardingStepNichePage

### Nom exact
- `OnboardingStepNichePage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `LinearProgressIndicator` à 3/6
- `Text` question `Quelle est votre niche ?`
- `Text` aide `Soyez simple et précis. Exemple : fitness pour femmes actives.`
- `TextFormField` niche
- `Wrap` de `ChoiceChip` suggestions :
  - business
  - fitness
  - lifestyle
  - beauté
  - food
  - design
  - bien-être
- `Text` label secondaire `Formats préférés (optionnel)`
- `Wrap` de `FilterChip` formats :
  - face cam
  - conseils
  - storytelling
  - carrousel
  - coulisses
- `Spacer`
- `Button` primaire `Continuer`
- `TextButton` `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Aide
4. Champ niche
5. Suggestions niche
6. Label formats
7. Formats optionnels
8. CTA
9. Retour

### Actions au clic
- Saisie niche → set `FFAppState().onboardingNiche`
- Tap suggestion → remplit le champ niche et l’App State
- Tap format → add/remove dans `FFAppState().onboardingPreferredFormats`
- `Continuer` → navigate `OnboardingStepTonePage`
- `Retour` → navigate `OnboardingStepPlatformPage`

### Bindings de données
- `TextFormField.initialValue/controller` lié à `onboardingNiche`
- `FilterChip.selected` lié à `onboardingPreferredFormats`

### Empty states
- Champ vide = CTA désactivé

### Loading states
- Aucun

### Error states
- Si niche vide → message inline `Décrivez votre niche pour personnaliser votre stratégie.`

## 6. OnboardingStepTonePage

### Nom exact
- `OnboardingStepTonePage`

### Widgets exacts
- `SafeArea`
- `Column`
- `LinearProgressIndicator` à 4/6
- `Text` question `Quel ton vous ressemble le plus ?`
- `Wrap` de `ChoiceChip` :
  - authentique
  - expert
  - drôle
  - inspirant
  - direct
  - éducatif
- `Button` primaire `Continuer`
- `TextButton` `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Chips ton
4. CTA
5. Retour

### Actions au clic
- Tap ton → set `FFAppState().onboardingTone`
- `Continuer` → navigate `OnboardingStepLevelPage`
- `Retour` → navigate `OnboardingStepNichePage`

### Bindings de données
- Chip selected state lié à `onboardingTone`

### Empty states
- Aucun ton choisi = CTA désactivé

### Loading states
- Aucun

### Error states
- Snackbar si aucun ton : `Choisissez le ton à utiliser par défaut.`

## 7. OnboardingStepLevelPage

### Nom exact
- `OnboardingStepLevelPage`

### Widgets exacts
- `SafeArea`
- `Column`
- `LinearProgressIndicator` à 5/6
- `Text` question `Où en êtes-vous aujourd’hui ?`
- `Column` de `SelectableCard` :
  - `Je démarre`
  - `Je poste déjà un peu`
  - `Je suis régulier mais je stagne`
- `Button` primaire `Continuer`
- `TextButton` `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Cartes niveau
4. CTA
5. Retour

### Actions au clic
- Tap carte → set `FFAppState().onboardingLevel`
- `Continuer` → navigate `OnboardingStepFrequencyPage`
- `Retour` → navigate `OnboardingStepTonePage`

### Bindings de données
- Carte sélectionnée liée à `onboardingLevel`

### Empty states
- Aucun niveau = CTA désactivé

### Loading states
- Aucun

### Error states
- Snackbar si aucun niveau : `Choisissez votre niveau actuel.`

## 8. OnboardingStepFrequencyPage

### Nom exact
- `OnboardingStepFrequencyPage`

### Widgets exacts
- `SafeArea`
- `Column`
- `LinearProgressIndicator` à 6/6
- `Text` question `Combien de fois pouvez-vous publier par semaine ?`
- `Column` de `SelectableCard` :
  - `2 fois / semaine`
  - `4 fois / semaine`
  - `1 fois / jour`
- `Text` optionnel `Langue et pays`
- `Row`
  - `DropdownButtonFormField` langue
  - `DropdownButtonFormField` pays
- `Spacer`
- `Button` primaire `Construire ma stratégie`
- `TextButton` `Retour`

### Ordre des blocs
1. Progress bar
2. Question
3. Cartes fréquence
4. Langue / pays
5. CTA construire
6. Retour

### Actions au clic
- Tap carte fréquence → set `FFAppState().onboardingFrequency`
- Changement langue → set `FFAppState().onboardingLanguage`
- Changement pays → set `FFAppState().onboardingCountry`
- `Construire ma stratégie` :
  1. upsert `creator_profiles`
  2. call `POST /api/v1/daily-idea`
  3. insert/upsert `daily_ideas`
  4. call `POST /api/v1/weekly-plan`
  5. insert/upsert `weekly_plans`
  6. batch insert `weekly_plan_items`
  7. set `hasCompletedOnboarding = true`
  8. navigate `OnboardingSummaryPage`
- `Retour` → navigate `OnboardingStepLevelPage`

### Bindings de données
- Carte fréquence liée à `onboardingFrequency`
- Dropdowns liés à `onboardingLanguage` et `onboardingCountry`
- Loading button lié à `OnboardingStepFrequencyPage.isBuildingStrategy`

### Empty states
- Fréquence non choisie = bouton désactivé
- Langue/pays peuvent être préremplis avec valeurs par défaut `fr` / `FR`

### Loading states
- Afficher loader dans le bouton `Construire ma stratégie`
- Désactiver retour et inputs pendant génération stratégie
- Texte du bouton : `Création de votre studio...`

### Error states
- Si upsert profil échoue → snackbar `Impossible d’enregistrer votre profil.`
- Si API daily idea échoue → snackbar `Impossible de générer votre idée du jour.`
- Si API weekly plan échoue → snackbar `Impossible de générer votre plan 7 jours.`
- Dans tous les cas, bouton `Réessayer`

## 9. OnboardingSummaryPage

### Nom exact
- `OnboardingSummaryPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Icon` check cercle
- `Text` titre `Votre studio est prêt`
- `Text` sous-titre `Voici votre point de départ pour cette semaine.`
- `Card` résumé profil
  - niche
  - plateforme principale
  - objectif
  - ton
  - fréquence
- `Card` `3 opportunités à activer`
  - opportunité 1
  - opportunité 2
  - opportunité 3
- `Card` preview idée du jour
  - titre
  - hook
  - format
  - heure
- `Button` primaire `Ouvrir mon studio`
- `Button` secondaire `Voir l’idée complète`

### Ordre des blocs
1. Icône succès
2. Titre
3. Sous-titre
4. Résumé profil
5. Carte opportunités
6. Preview daily idea
7. CTA principal
8. CTA secondaire

### Actions au clic
- `Ouvrir mon studio` → navigate `MainShellPage` avec `HomePage`
- `Voir l’idée complète` → navigate `DailyIdeaPage`

### Bindings de données
- `creator_profiles` pour résumé profil
- `daily_ideas` du jour pour preview
- opportunités dérivées des champs profil/plan via texte local ou champs calculés

### Empty states
- Si l’idée du jour n’est pas encore disponible → carte skeleton avec texte `Votre première idée arrive...`

### Loading states
- Skeleton cards pour profil et idée du jour pendant chargement

### Error states
- Si requêtes échouent → afficher résumé minimum avec bouton `Entrer dans l’app`

## 10. HomePage

### Nom exact
- `HomePage`

### Widgets exacts
- `SafeArea`
- `RefreshIndicator`
- `SingleChildScrollView`
- `Column`
- `Row` header
  - avatar cercle
  - `Column` salut prénom / sous-texte
  - `IconButton` notifications ou upgrade
- `Card` Momentum
  - score
  - delta semaine
  - micro-texte guidance
- `Card` Action du jour
  - mission du jour
  - tag effort
  - bouton `Créer maintenant`
- `Card` Preview idée du jour
  - titre
  - hook
  - format
  - heure
  - bouton `Voir le détail`
- `Card` Mini progression
  - tâches faites / prévues
  - followers delta si existant
  - régularité
- `Row` accès rapides
  - bouton `Plan`
  - bouton `Create`
  - bouton `Growth`
- `BottomNavigationBar`

### Ordre des blocs
1. Header
2. Momentum card
3. Action du jour
4. Daily idea preview
5. Mini progression
6. Accès rapides
7. Bottom nav

### Actions au clic
- Header action → `PricingPage` ou future notifications
- `Créer maintenant` → `CreatePage`
- `Voir le détail` → `DailyIdeaPage`
- `Plan` → `Plan7DaysPage`
- `Create` → `CreatePage`
- `Growth` → `GrowthPage`
- Pull to refresh → refetch toutes les queries

### Bindings de données
- `creator_profiles` : prénom dérivé email si pas de nom
- `daily_ideas` : preview du jour
- `weekly_plan_items` : mission du jour = premier item `todo`
- `growth_snapshots` : score / mini progression
- `baseline_snapshots` : delta si dispo

### Empty states
- Pas d’idée du jour → card `Générez votre idée du jour` + bouton vers `DailyIdeaPage`
- Pas de growth snapshot → mini progression affiche `Ajoutez vos stats pour débloquer votre progression`
- Pas de weekly plan → CTA `Créer mon plan`

### Loading states
- Skeleton header
- Skeleton cards sur momentum, action du jour et idée du jour

### Error states
- Si home query échoue → bannière `Impossible de charger votre cockpit.`
- Bouton `Réessayer`
- Les accès rapides restent cliquables

## 11. DailyIdeaPage

### Nom exact
- `DailyIdeaPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Text` date du jour
- `Card` hero idée
  - titre
  - why now
- `Card` hook
  - texte hook
  - `IconButton` copy
- `Card` structure
  - `ListView` ou `Column` de bullets depuis `content_structure`
- `Card` caption
  - texte caption
  - `IconButton` copy
- `Card` hashtags
  - `Wrap` de chips
  - `IconButton` copy
- `Card` format et heure
- `Card` mission engagement
- `Card` effort + confidence note
- `Row` sticky CTA
  - `Créer ce contenu`
  - `Régénérer`
- `Row` secondaire
  - `En faire un script`
  - `Ajouter au calendrier`

### Ordre des blocs
1. Date
2. Hero idée
3. Hook
4. Structure
5. Caption
6. Hashtags
7. Format/heure
8. Mission engagement
9. Effort/confidence
10. CTA principaux
11. CTA secondaires

### Actions au clic
- `Créer ce contenu` → navigate `CreatePage` avec brief prérempli à partir de `topic + angle + hook`
- `Régénérer` → call `POST /api/v1/daily-idea` → upsert `daily_ideas` → refresh page
- `En faire un script` → navigate `CreatePage` avec `format = reel` ou format recommandé
- `Ajouter au calendrier` → MVP simple : snackbar `Ajouté à votre workflow` ou update ciblé si item disponible
- Boutons copy → copier hook/caption/hashtags

### Bindings de données
- Binding principal sur `daily_ideas` row du jour
- `content_structure` rendu en liste
- `hashtags` rendus en chips

### Empty states
- Si aucune idée du jour → illustration simple + texte `Aucune idée générée pour aujourd’hui.` + bouton `Générer mon idée`

### Loading states
- Skeleton cards pour hero, hook, structure et caption
- Loader dans le bouton `Régénérer` quand `isRegeneratingIdea = true`

### Error states
- Si requête initiale échoue → bannière d’erreur + bouton `Réessayer`
- Si régénération échoue → snackbar `La régénération a échoué.`

## 12. CreatePage

### Nom exact
- `CreatePage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Text` titre `Créer un contenu`
- `DropdownButtonFormField` plateforme
- `DropdownButtonFormField` format
- `Wrap` de `ChoiceChip` ton
- `TextFormField` multiline brief
- `Button` primaire `Générer`
- `TabBar`
  - Hooks
  - Caption
  - Script
  - Hashtags
  - CTA
- `TabBarView`
  - onglet Hooks : liste de cartes hook + copy
  - onglet Caption : carte texte + copy
  - onglet Script : carte script + copy
  - onglet Hashtags : wrap chips + copy
  - onglet CTA : carte CTA + copy
- `Row` actions résultats
  - `Button` secondaire `Sauvegarder`
  - `Button` tertiaire `Créer 3 variantes`

### Ordre des blocs
1. Titre
2. Plateforme
3. Format
4. Ton
5. Brief
6. Bouton générer
7. Tabs résultats
8. Actions résultats

### Actions au clic
- `Générer` :
  1. valider `brief`, `platform`, `format`
  2. call `POST /api/v1/generate-content`
  3. set App State résultats
  4. insert `content_generations`
- `Sauvegarder` → snackbar `Brouillon sauvegardé` ou insert confirmé
- `Créer 3 variantes` → second call API avec brief enrichi ou simple toggle futur
- Boutons copy par onglet
- Initialisation possible depuis `DailyIdeaPage` ou `Plan7DaysPage`

### Bindings de données
- Dropdown plateforme initialisé depuis `creator_profiles.primary_platform` ou `selectedCreatePlatform`
- Ton initialisé depuis `creator_profiles.desired_tone` ou `selectedCreateTone`
- Onglets liés aux App States `generatedHooks`, `generatedCaption`, `generatedScript`, `generatedHashtags`, `generatedCTA`

### Empty states
- Avant génération : bloc d’aide `Décrivez votre idée en une phrase pour recevoir hooks, caption et script.`
- Onglets masqués ou placeholder tant qu’aucun résultat n’existe

### Loading states
- Bouton `Générer` désactivé avec loader
- Placeholder shimmer dans la zone résultats

### Error states
- Brief vide → message inline sous le champ
- API échoue → snackbar `Impossible de générer le contenu.`
- Si insert base échoue après génération → conserver résultat en local + snackbar `Résultat généré mais non sauvegardé.`

## 13. Plan7DaysPage

### Nom exact
- `Plan7DaysPage`

### Widgets exacts
- `SafeArea`
- `RefreshIndicator`
- `Column`
- `Text` thème de semaine
- `Text` coach note
- `Expanded` + `ListView.builder` de 7 cards
- Chaque `PlanDayCard` contient :
  - label jour
  - plateforme
  - format
  - sujet
  - angle
  - ton
  - créneau
  - mission engagement
  - effort chip
  - status chip
  - `Row` boutons `Fait`, `Remplacer`, `Générer brouillon`
- `BottomNavigationBar`

### Ordre des blocs
1. Thème semaine
2. Coach note
3. Liste 7 jours
4. Bottom nav

### Actions au clic
- `Fait` → update `weekly_plan_items.status = done`
- `Remplacer` → ouvrir `ReplacePlanItemBottomSheet`
- `Générer brouillon` → navigate `CreatePage` avec préremplissage depuis la card
- Pull to refresh → refetch plan et items

### Bindings de données
- `weekly_plans.week_theme`
- `weekly_plans.coach_note`
- `weekly_plan_items` list triée par `day_index`
- Couleur chip liée à `status`

### Empty states
- Si aucun plan → illustration + texte `Votre plan n’est pas encore prêt.` + bouton `Régénérer mon plan`

### Loading states
- Skeleton titre semaine
- 3 à 7 skeleton cards

### Error states
- Si requête échoue → bannière `Impossible de charger votre plan.` + bouton `Réessayer`
- Si update status échoue → snackbar `Statut non mis à jour.`

## 14. GrowthPage

### Nom exact
- `GrowthPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Text` titre `Votre progression`
- `Row` KPI cards :
  - followers gagnés
  - engagement
  - posts
  - régularité
- `Card` chart container
  - line chart followers / posts
- `Card` top format
- `Card` main insight
- `Button` `Voir avant / après`
- `Button` secondaire `Mettre à jour mes stats`
- `BottomNavigationBar`

### Ordre des blocs
1. Titre
2. KPI row
3. Chart
4. Top format
5. Main insight
6. CTA before/after
7. CTA stats
8. Bottom nav

### Actions au clic
- `Voir avant / après` → navigate `BeforeAfterPage`
- `Mettre à jour mes stats` → ouvrir `ManualStatsBottomSheet`
- `Obtenir un insight` si présent comme CTA secondaire → call `POST /api/v1/growth-insight`

### Bindings de données
- `growth_snapshots` latest pour KPI
- `growth_snapshots` list pour chart
- `baseline_snapshots` pour delta de croissance
- `subscriptions` pour verrouiller certains blocs premium si nécessaire

### Empty states
- Si aucun snapshot → afficher formulaire ou bottom sheet manuel avec message `Ajoutez vos stats du moment pour commencer à suivre votre progression.`

### Loading states
- Skeleton KPI cards
- Skeleton chart card
- Loader sur CTA save stats

### Error states
- Si query échoue → bannière `Impossible de charger vos stats.`
- Si save snapshot échoue → snackbar `Vos stats n’ont pas pu être enregistrées.`

## 15. BeforeAfterPage

### Nom exact
- `BeforeAfterPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Card` hero
  - titre `Depuis votre inscription`
  - sous-titre insight
- `Row` comparaison cards
  - followers avant / maintenant
  - engagement avant / maintenant
  - posts avant / maintenant
- `Wrap` delta chips
- `Card` timeline progression
  - baseline créée
  - premier plan généré
  - premier snapshot
  - progression actuelle
- `Button` primaire `Partager ma progression`
- `Button` secondaire `Préparer mon prochain mois`

### Ordre des blocs
1. Hero
2. Comparaison avant / maintenant
3. Delta chips
4. Timeline
5. CTA partager
6. CTA prochain mois

### Actions au clic
- `Partager ma progression` → ouvrir share sheet natif avec résumé texte
- `Préparer mon prochain mois` → navigate `Plan7DaysPage` ou `PricingPage` si verrou premium

### Bindings de données
- `baseline_snapshots` latest/oldest baseline
- `growth_snapshots` latest snapshot
- Timeline construite à partir de baseline + weekly plans + snapshots

### Empty states
- Si baseline absente → texte `Ajoutez d’abord vos stats de départ.` + bouton `Retour à Growth`

### Loading states
- Skeleton hero et skeleton comparison cards

### Error states
- Si données incomplètes → message `Comparaison indisponible pour le moment.` + bouton retour

## 16. PricingPage

### Nom exact
- `PricingPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Text` titre `Passez à la vitesse supérieure`
- `Text` sous-titre bénéfices
- `PricingCard` Free
- `PricingCard` Pro
- `PricingCard` Growth
- `BulletList` bénéfices inclus
- `Button` primaire `Choisir cette offre`
- `TextButton` `Continuer en gratuit`

### Ordre des blocs
1. Titre
2. Sous-titre
3. Cartes pricing
4. Liste bénéfices
5. CTA principal
6. CTA gratuit

### Actions au clic
- Sélection d’une carte → set plan courant local
- `Choisir cette offre` → RevenueCat purchase → update `subscriptions`
- `Continuer en gratuit` → retour page précédente

### Bindings de données
- `subscriptions` pour marquer plan actif
- éventuels produits RevenueCat si intégration branchée

### Empty states
- Si aucune offre RevenueCat chargée → fallback cartes statiques

### Loading states
- Skeleton pricing cards pendant fetch des offerings
- Loader dans CTA pendant achat

### Error states
- Achat annulé → snackbar `Achat annulé.`
- Achat échoué → snackbar `Impossible de finaliser l’abonnement.`

## 17. SettingsPage

### Nom exact
- `SettingsPage`

### Widgets exacts
- `SafeArea`
- `SingleChildScrollView`
- `Column`
- `Card` résumé profil
  - niche
  - plateforme
  - ton
  - fréquence
- `TextFormField` niche
- `DropdownButtonFormField` ton
- `DropdownButtonFormField` fréquence
- `Card` abonnement
  - plan actif
  - statut
  - bouton `Gérer mon abonnement`
- `Button` primaire `Enregistrer`
- `Button` secondaire `Se déconnecter`
- `BottomNavigationBar`

### Ordre des blocs
1. Résumé profil
2. Champ niche
3. Ton
4. Fréquence
5. Carte abonnement
6. Bouton enregistrer
7. Bouton logout
8. Bottom nav

### Actions au clic
- `Enregistrer` → update `creator_profiles`
- `Gérer mon abonnement` → navigate `PricingPage`
- `Se déconnecter` → clear App State + Supabase sign out + navigate `AuthPage`

### Bindings de données
- `creator_profiles` pour niche / ton / fréquence
- `subscriptions` pour plan actif
- Champs éditables initialisés avec les valeurs profil

### Empty states
- Si profil absent → texte `Profil introuvable.` + bouton `Relancer l’onboarding`

### Loading states
- Skeleton card profil
- Loader dans bouton `Enregistrer`

### Error states
- Update profil échoue → snackbar `Impossible d’enregistrer vos changements.`
- Logout échoue → snackbar `Déconnexion impossible.`
