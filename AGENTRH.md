# AgentRH · back de l'espace conformité

Ce dépôt est une version modifiée de `pia-back`, le back du logiciel PIA de la CNIL
([LINCnil/pia-back](https://github.com/LINCnil/pia-back), licence GPLv3), adaptée par
AgentRH en octobre 2026. Le front correspondant est dans
[AgentRH/pia](https://github.com/AgentRH/pia).

La CNIL n'est ni l'éditeur ni le garant de cette version.

## Ce qui a été modifié par rapport au back CNIL

| Sujet | Fichiers |
| --- | --- |
| Connexion à la base par `DATABASE_URL` | `config/database.yml` |
| Réglages SMTP et expéditeur par variables d'environnement | `config/initializers/mailer.rb`, `config/initializers/devise.rb`, `app/mailers/application_mailer.rb` |
| Nom d'hôte par défaut fourni par Render | `config/initializers/default_url_options.rb` |
| Initialisation automatique d'une instance | `lib/tasks/agentrh.rake` |
| Déploiement Render | `render.yaml` |

Aucune règle métier ni aucun contrôle d'accès n'a été modifié.

## Règle d'architecture : une instance par client

Ce back ne cloisonne pas les données entre organisations : un utilisateur connecté
peut atteindre les réponses, commentaires et pièces jointes de n'importe quelle
analyse de l'instance. Chaque client a donc son propre service Render et sa propre
base Neon. Ne jamais inviter deux clients sur la même instance.

## Déployer une instance (Render + Neon)

1. Créer une base Neon dédiée au client, en région UE, et copier son adresse de connexion.
2. Dans Render : New > Blueprint, choisir ce dépôt. Le fichier `render.yaml` crée le
   service (région Francfort) avec un disque pour les pièces jointes.
3. Saisir les valeurs demandées :

| Variable | Valeur |
| --- | --- |
| `DATABASE_URL` | adresse de connexion Neon |
| `ALLOWED_CORS_ORIGINS` | adresse du front, par exemple `https://argos.exemple.fr` |
| `ADMIN_EMAIL` | email du premier administrateur (AgentRH) |
| `ADMIN_PASSWORD` | 12 caractères minimum, avec majuscule, minuscule, chiffre et caractère spécial |
| `EMAIL_FROM` | expéditeur des emails, par exemple `conformite@exemple.fr` |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_AUTHENTICATION` | réglages du service d'envoi d'emails (`SMTP_AUTHENTICATION` vaut en général `plain`) |

4. Au premier démarrage, le back crée les tables, l'application OAuth et le compte
   administrateur. Les journaux Render affichent des lignes `[agentrh]` qui le confirment.
5. Recopier `OAUTH_CLIENT_ID` et `OAUTH_CLIENT_SECRET` (onglet Environment de Render)
   dans le projet Vercel du front : `PIA_CLIENT_ID` et `PIA_CLIENT_SECRET`. Y renseigner
   aussi `PIA_SERVER_URL` avec l'adresse du service Render, puis redéployer le front.
6. Une fois connecté, supprimer `ADMIN_PASSWORD` des variables Render.

À savoir :

- Sans SMTP, la création de comptes échoue : chaque nouveau compte reçoit son code
  d'activation par email.
- `DEVISE_PEPPER` ne doit jamais changer, sinon tous les mots de passe deviennent invalides.
- Les pièces jointes sont sur le disque Render (sauvegarde quotidienne par Render),
  le reste est dans Neon.

## Récupérer les mises à jour de la CNIL

```
git remote add upstream https://github.com/LINCnil/pia-back.git
git fetch upstream
git merge upstream/master
```

## Licence

GPLv3, comme le logiciel d'origine (voir `LICENSE`).
