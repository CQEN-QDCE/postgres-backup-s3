# Prise de sauvegarde de base de données

Ce dépôt contient les instructions nécessaires pour installer une prise de sauvegarde automatique de base de données sur OpenShift.

| Gabarit  | Descripton |
| -------- | ---------- |
| [postgres-backup-s3.yaml](https://github.com/CQEN-QDCE/openshift-services-generiques/blob/main/sauvegarde/postgres-backup-s3.yaml) | Sauvegarde automatique de base de données PostgreSQL dans un bucket S3 d'AWS. |

## Paramètres du gabarit

Tous les paramètres du gabarit sont obligatoires. Certains parmi eux ont des valeurs par défaut. Ils doivent être fournis lors de l'installation avec 'oc process'.

### Paramètres d'entrée requis

| Paramètre | Description |
| --------- | ----------- |
| **DATABASE_USER** | Le nom d'utilisateur pour accéder à la base de données. |
| **DATABASE_PASSWORD** | Le mot de passe de l'utilisateur pour accéder à la base de données. |
| **DATABASE_HOST** | Le nom d'hôte de la base de données. |
| **DATABASE_NAME** | Le nom de la base de données à sauvegarder. |
| **AWS_ACCESS_KEY_ID** | Identifiant de la clé d'accès au bucket S3 d'AWS. |
| **AWS_ACCESS_KEY_SECRET** | Mot de passe de la clé d'accès au bucket S3 d'AWS. |

### Pré-requis
Préalablement au lancement du gabarit, une clé d'accès à un bucket S3 d'AWS est requise. Référez vous à la configuration disponible dans le lien suivant: 
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-set 

### Installation
Connecter vous à OpenShift en ligne de commande et sélectionnez le projet contenant la base de données à sauvegarder:
```bash
oc project <votre-nom-project>
```

Lancez l'installation:
```bash
oc process -f postgres-backup-s3.yaml -p DATABASE_USER=<dbuser> \
                                      -p DATABASE_PASSWORD=<dbpassword> \
                                      -p DATABASE_HOST=<dbhost> \
                                      -p DATABASE_NAME=<dbname> \
                                      -p AWS_ACCESS_KEY_ID=<awsaccesskeyid> \
                                      -p AWS_ACCESS_KEY_SECRET=<awsaccesskeysecret> | oc create -f -
```

### Paramètres avec valeurs par défaut
| Paramètre | Description | Défaut      |
| --------- | ----------- | ----------- |
| **DATABASE_BACKUP_KEEP** | Nombre de sauvegarde à conserver. | 7 |
| **DATABASE_BACKUP_SCHEDULE** | Horaire, au format Cron, de la prise de sauvegarde. | 0-55/5 * * * * |
| **DATABASE_PORT** | Port sur lequel la base de données écoute. | 5432 |
| **BACKUP_VOLUME_CLAIM_NAME** | Nom du volume claim. | postgres-backup-s3 |
| **BACKUP_VOLUME_STORAGE_CLASS_NAME** |Nom de la classe de stockage à utiliser. | ocs-storagecluster-cephfs |
| **AWS_S3_BUCKET_NAME** | Nom du bucket S3 d'AWS. | cqen-taiga-backups |
| **BACKUP_VOLUME_CAPACITY** | Espace de volume disponible pour les données PostgreSQL, par exemple 512Mi, 2Gi. | 1Gi |
| **AWS_DEFAULT_REGION** | Région AWS par defaut. | ca-central-1 |

### Restoration d'une sauvegarde
Dans le cas où une restoration devrait être appliquée, récupérez le fichier de sauvegarde voulu (normalement, le dernier fichier généré) et placez-le dans le nouveau conteneur 
de l'application dans le répertoire `/database-backup`, par example.

Si vous récupérez le fichier à partir du bucket S3 AWS, télécharger-le sur votre poste de travail. 

Décompréssez le fichier avec la commande suivante: 

```bash
gunzip /database-backup/<backupfile>.gz
```

Le résultat sera un fichier en format `sql`. Ceci est le script qui fera la restoration de la base de données.

Copiez le fichier sql dans le pod de la base de données à restaurer avec oc rsync ./database-backup <nom du pod>:/tmp
  
Ensuite exécutez la commande suivante: 

```bash
psql --username=taiga --password --host=taiga-db --port=5432 postgres < /database-backup/<backupfile>.sql
```

Example de commande complète à exécuter: 

```bash
psql --username=taiga --password --host=taiga-db --port=5432 postgres < /database-backup/backup-taiga-2021-10-05_152512Z.sql.gz
```

