# Guide de Test du Déploiement Automatique

Ce guide contient des exemples de modifications à faire pour tester le déploiement automatique avec Argo CD.

## Test 1: Changer le nombre de replicas

Modifier `k8s/deployment.yaml`:
```yaml
spec:
  replicas: 3  # Changer de 2 à 3
```

Puis:
```bash
git add k8s/deployment.yaml
git commit -m "Scale to 3 replicas"
git push
```

Observer:
```bash
kubectl get pods -n test-app -w
```

## Test 2: Modifier le contenu HTML

Modifier la ConfigMap dans `k8s/deployment.yaml`:
```yaml
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    ...
            <div class="status">✅ Déploiement réussi !</div>
            <div class="info">Version: v2.0.0</div>  # Changer la version
            <div class="info">Replicas: 3</div>      # Mettre à jour
    ...
```

Puis:
```bash
git add k8s/deployment.yaml
git commit -m "Update version to v2.0.0"
git push
```

## Test 3: Changer l'image

Modifier `k8s/deployment.yaml`:
```yaml
containers:
- name: nginx
  image: nginx:1.26-alpine  # Changer la version
```

Puis:
```bash
git add k8s/deployment.yaml
git commit -m "Update nginx to 1.26"
git push
```

## Test 4: Ajouter des labels

Modifier `k8s/deployment.yaml`:
```yaml
metadata:
  labels:
    app: test-app
    environment: development  # Nouveau label
```

## Test 5: Modifier les ressources

Modifier `k8s/deployment.yaml`:
```yaml
resources:
  requests:
    memory: "128Mi"  # Augmenter
    cpu: "200m"      # Augmenter
  limits:
    memory: "256Mi"  # Augmenter
    cpu: "400m"      # Augmenter
```

## Commandes utiles pour observer

```bash
# Voir l'état de synchronisation
argocd app get test-app

# Voir les logs d'Argo CD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Voir les événements
kubectl get events -n test-app --sort-by='.lastTimestamp'

# Voir les pods en temps réel
watch kubectl get pods -n test-app

# Voir l'historique des déploiements
kubectl rollout history deployment/test-app -n test-app
```

## Rollback en cas de problème

Si un déploiement échoue, vous pouvez faire un rollback:

```bash
# Via Argo CD
argocd app rollback test-app

# Ou via kubectl
kubectl rollout undo deployment/test-app -n test-app
```

## Vérifier l'application

```bash
# Port-forward
kubectl port-forward -n test-app svc/test-app 8080:80

# Curl
curl http://localhost:8080
```
