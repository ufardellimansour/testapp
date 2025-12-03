# Application de Test Argo CD

Cette application simple permet de tester le déploiement automatique avec Argo CD.

## Structure du projet

```
argocd-test-app/
├── README.md
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── namespace.yaml
└── app.yaml (Application Argo CD)
```

## Prérequis

- Un cluster Kubernetes
- Argo CD installé sur le cluster
- kubectl configuré
- Git repository pour stocker ces fichiers

## Déploiement

### 1. Pousser le code dans un repository Git

```bash
git init
git add .
git commit -m "Initial commit - Test app for Argo CD"
git remote add origin <VOTRE_REPO_GIT>
git push -u origin main
```

### 2. Créer l'application dans Argo CD

**Option A: Via l'interface web Argo CD**
1. Ouvrir l'interface Argo CD
2. Cliquer sur "+ NEW APP"
3. Remplir les informations:
   - Application Name: `test-app`
   - Project: `default`
   - Sync Policy: `Automatic`
   - Repository URL: `<URL_DE_VOTRE_REPO>`
   - Path: `k8s`
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `test-app`

**Option B: Via kubectl**
```bash
# Modifier le fichier app.yaml avec votre URL de repo
kubectl apply -f app.yaml
```

### 3. Vérifier le déploiement

```bash
# Voir les applications Argo CD
kubectl get applications -n argocd

# Voir les pods déployés
kubectl get pods -n test-app

# Voir le service
kubectl get svc -n test-app
```

### 4. Accéder à l'application

```bash
# Port-forward pour tester localement
kubectl port-forward -n test-app svc/test-app 8080:80

# Puis ouvrir http://localhost:8080
```

## Tester le déploiement automatique

1. Modifier le fichier `k8s/deployment.yaml` (par exemple, changer le nombre de replicas)
2. Commit et push les changements
3. Argo CD va automatiquement détecter les changements et synchroniser

```bash
git add k8s/deployment.yaml
git commit -m "Update replicas to 3"
git push
```

4. Observer la synchronisation dans l'interface Argo CD ou via:
```bash
kubectl get pods -n test-app -w
```

## Commandes utiles

```bash
# Voir l'état de l'application
argocd app get test-app

# Forcer une synchronisation
argocd app sync test-app

# Voir les logs de l'application
kubectl logs -n test-app -l app=test-app

# Supprimer l'application
kubectl delete -f app.yaml
```
