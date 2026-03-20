# Viral Studio — Endpoints API MVP

> Livrable API uniquement. Scope strictement limité aux 4 endpoints MVP.

---

## 1. `/api/v1/daily-idea`

### Route
`POST /api/v1/daily-idea`

### Méthode
`POST`

### Rôle de l’endpoint
Générer et persister l’idée du jour personnalisée d’un utilisateur à partir de son profil créateur et, si disponible, d’un résumé simple de croissance récente.

### Payload input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "business",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["face_cam", "conseils"],
    "language": "fr",
    "country": "FR"
  },
  "recent_growth": {
    "top_format": "reel",
    "regularity_rate": 50,
    "main_insight": "les contenus conseils performent mieux"
  }
}
```

### Payload output JSON
```json
{
  "idea_date": "2026-03-20",
  "idea_title": "L'erreur qui rend un freelance invisible",
  "why_now": "Votre audience répond bien aux conseils simples et votre rythme actuel favorise un format court.",
  "topic": "erreur de visibilité freelance",
  "angle": "montrer une erreur fréquente puis proposer un correctif concret",
  "hook": "Si vous êtes freelance et que vous postez sans angle clair, vous faites probablement cette erreur.",
  "content_structure": [
    "nommer l'erreur",
    "montrer la conséquence",
    "donner le correctif simple"
  ],
  "caption": "Beaucoup de freelances publient sans savoir ce qu'ils veulent déclencher. Voici l'erreur que je vois le plus, et comment la corriger simplement.",
  "cta": "Si vous voulez, je peux faire une partie 2 avec d'autres erreurs à éviter.",
  "hashtags": ["#freelance", "#branding", "#instagrambusiness"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "Répondez aux 5 premiers commentaires dans l'heure.",
  "effort_level": "low",
  "confidence_note": "Très bon fit avec un format face cam court."
}
```

### Validations minimales
- JWT Supabase valide.
- `user_id` présent et doit correspondre au user authentifié.
- `creator_profile.niche` non vide.
- `creator_profile.primary_platform` dans la liste autorisée.
- `creator_profile.goal` dans la liste autorisée.
- `creator_profile.desired_tone` non vide.
- `creator_profile.level` non vide.
- `creator_profile.frequency_per_week` entre 1 et 14.
- `language` non vide.
- `recent_growth` optionnel.
- réponse IA conforme au schéma JSON attendu.

### Comportement backend attendu
1. vérifier le JWT Supabase.
2. comparer `auth.uid()` avec `user_id`.
3. valider le payload d’entrée.
4. charger optionnellement le `creator_profile` depuis la DB si le payload est partiel.
5. appeler OpenAI avec le prompt Daily Idea.
6. parser et valider strictement le JSON de sortie.
7. compléter `idea_date` avec la date UTC du jour si absent.
8. upsert dans `daily_ideas` via `(user_id, idea_date)`.
9. retourner le JSON final normalisé.
10. en cas de JSON IA invalide : faire 1 retry maximum puis renvoyer `422`.

---

## 2. `/api/v1/weekly-plan`

### Route
`POST /api/v1/weekly-plan`

### Méthode
`POST`

### Rôle de l’endpoint
Générer et persister un plan éditorial de 7 jours adapté au profil du créateur, avec une ligne par jour dans `weekly_plan_items`.

### Payload input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "business",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["conseils"],
    "language": "fr",
    "country": "FR"
  }
}
```

### Payload output JSON
```json
{
  "week_start": "2026-03-16",
  "week_theme": "Se rendre identifiable en 7 jours",
  "coach_note": "Cette semaine, on cherche surtout la régularité et la clarté, pas la perfection.",
  "days": [
    {
      "day_index": 1,
      "platform": "instagram",
      "objective": "followers",
      "format": "reel",
      "topic": "erreur de visibilité freelance",
      "angle": "conseil simple",
      "tone": "authentique",
      "time_window": "18:00-19:00",
      "engagement_task": "Répondre à 5 comptes de niche en commentaire ou story.",
      "effort": "low",
      "status": "planned"
    }
  ]
}
```

### Validations minimales
- JWT Supabase valide.
- `user_id` correspond à l’utilisateur authentifié.
- `creator_profile` présent.
- `niche`, `primary_platform`, `goal`, `desired_tone`, `level`, `frequency_per_week` obligatoires.
- `frequency_per_week` entre 1 et 14.
- la réponse IA doit contenir exactement 7 items dans `days`.
- chaque `day_index` doit être compris entre 1 et 7.
- chaque `status` doit valoir `planned` à la création.

### Comportement backend attendu
1. vérifier auth.
2. valider le payload.
3. calculer `week_start` en UTC sur le lundi courant.
4. appeler OpenAI avec le prompt Weekly Plan.
5. parser et valider strictement le JSON.
6. upsert dans `weekly_plans` via `(user_id, week_start)`.
7. supprimer les anciens `weekly_plan_items` liés à ce plan.
8. insérer les 7 nouveaux `weekly_plan_items`.
9. retourner le plan complet, avec `week_start` et `days` normalisés.
10. si la réponse IA ne contient pas 7 jours valides : `422`.

---

## 3. `/api/v1/generate-content`

### Route
`POST /api/v1/generate-content`

### Méthode
`POST`

### Rôle de l’endpoint
Transformer un brief utilisateur en contenu prêt à exploiter dans l’écran Create : hooks, caption, script, hashtags, CTA et variantes de ton.

### Payload input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "design freelance",
    "primary_platform": "linkedin",
    "goal": "clients",
    "desired_tone": "expert",
    "level": "intermediaire",
    "frequency_per_week": 3,
    "preferred_formats": ["conseils"],
    "language": "fr",
    "country": "FR"
  },
  "brief": "post sur l'erreur de branding qui fait perdre des clients premium",
  "platform": "linkedin",
  "format": "post",
  "tone": "expert"
}
```

### Payload output JSON
```json
{
  "hooks": [
    "L'erreur de branding la plus chère chez les freelances.",
    "Pourquoi certains freelances repoussent les clients premium sans le voir.",
    "Votre branding ne manque peut-être pas de style, mais de clarté."
  ],
  "caption": "Beaucoup de freelances pensent que leur problème est le manque de visibilité. Souvent, c'est surtout un problème de lisibilité.",
  "script": "Voici l'erreur que je vois le plus : un branding joli mais flou. Si votre promesse n'est pas claire en 3 secondes, vous perdez les bons clients avant même la conversation.",
  "hashtags": ["#branding", "#freelance", "#positionnement"],
  "cta": "Si vous voulez, je peux faire un post sur les 3 signaux d'un branding flou.",
  "tone_variants": [
    {
      "tone": "direct",
      "text": "Votre branding n'est pas faible. Il est flou."
    },
    {
      "tone": "authentique",
      "text": "J'ai longtemps cru que mes clients voulaient plus de style. En réalité, ils voulaient surtout plus de clarté."
    }
  ]
}
```

### Validations minimales
- JWT Supabase valide.
- `user_id` correspond à l’utilisateur authentifié.
- `brief` non vide, longueur minimale recommandée 10 caractères.
- `platform` non vide.
- `format` non vide.
- `tone` non vide.
- `creator_profile` présent.
- la sortie IA doit contenir au minimum 3 hooks, 1 caption, 1 CTA.
- `hashtags` doit être un tableau.
- `tone_variants` doit être un tableau d’objets `{ tone, text }`.

### Comportement backend attendu
1. vérifier auth.
2. valider le payload.
3. appeler OpenAI avec le prompt Generate Content.
4. parser et valider strictement le JSON.
5. insérer une ligne dans `content_generations` avec les entrées et la sortie.
6. retourner le JSON final.
7. si `brief` est vide → `400`.
8. si JSON IA invalide → retry 1 fois puis `422`.

---

## 4. `/api/v1/growth-insight`

### Route
`POST /api/v1/growth-insight`

### Méthode
`POST`

### Rôle de l’endpoint
Générer un insight simple et actionnable à partir d’une baseline et d’un snapshot récent de croissance pour alimenter Growth et Before/After.

### Payload input JSON
```json
{
  "user_id": "uuid",
  "baseline": {
    "followers_baseline": 100,
    "engagement_baseline": 2.0,
    "posts_baseline": 3
  },
  "latest_growth": {
    "followers_total": 142,
    "engagement_rate": 2.9,
    "posts_count": 8,
    "regularity_rate": 75,
    "top_format": "reel"
  }
}
```

### Payload output JSON
```json
{
  "wins": [
    "Votre régularité est nettement meilleure qu'au départ.",
    "Les formats courts semblent mieux soutenir votre progression actuelle."
  ],
  "weak_signals": [
    "Vous manquez encore de recul pour isoler une tonalité gagnante certaine."
  ],
  "actions_next_week": [
    "Répéter un Reel conseil proche de votre meilleur format.",
    "Maintenir un post à faible effort pour garder la cadence.",
    "Noter les questions qui reviennent pour inspirer le prochain plan."
  ],
  "main_insight": "Votre progression actuelle semble surtout tirée par une meilleure régularité et des contenus plus simples à consommer."
}
```

### Validations minimales
- JWT Supabase valide.
- `user_id` correspond à l’utilisateur authentifié.
- `baseline` présent.
- `latest_growth` présent.
- `followers_baseline`, `engagement_baseline`, `posts_baseline` numériques >= 0.
- `followers_total`, `engagement_rate`, `posts_count`, `regularity_rate` numériques >= 0.
- la sortie IA doit contenir `wins`, `weak_signals`, `actions_next_week`, `main_insight`.

### Comportement backend attendu
1. vérifier auth.
2. valider le payload.
3. appeler OpenAI avec le prompt Growth Insight.
4. parser et valider strictement le JSON.
5. retourner l’insight.
6. optionnel : mettre à jour `growth_snapshots.main_insight` pour le snapshot le plus récent.
7. si les objets `baseline` ou `latest_growth` sont incomplets → `400`.
8. si JSON IA invalide → retry 1 fois puis `422`.
