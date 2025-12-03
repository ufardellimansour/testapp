#!/bin/bash

# Script de setup pour l'application test Argo CD
set -e

echo "🚀 Setup de l'application test Argo CD"
echo "========================================"

# Vérifier que kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl n'est pas installé"
    exit 1
fi

# Vérifier que le cluster est accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Impossible de se connecter au cluster Kubernetes"
    exit 1
fi

echo "✅ Connexion au cluster OK"

# Vérifier si Argo CD est installé
if ! kubectl get namespace argocd &> /dev/null; then
    echo "⚠️  Argo CD n'est pas installé"
    echo "Voulez-vous installer Argo CD ? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "📦 Installation d'Argo CD..."
        kubectl create namespace argocd
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        
        echo "⏳ Attente du démarrage d'Argo CD..."
        kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
        
        echo "✅ Argo CD installé"
        echo ""
        echo "Pour accéder à l'interface Argo CD:"
        echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
        echo ""
        echo "Mot de passe admin initial:"
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
        echo ""
        echo ""
    else
        echo "❌ Argo CD est requis. Installation annulée."
        exit 1
    fi
else
    echo "✅ Argo CD est installé"
fi

# Demander l'URL du repository Git
echo ""
echo "📝 Configuration du repository Git"
echo "Entrez l'URL de votre repository Git (ex: https://github.com/username/repo.git):"
read -r repo_url

if [ -z "$repo_url" ]; then
    echo "❌ URL du repository requise"
    exit 1
fi

# Modifier le fichier app.yaml avec la bonne URL
echo "✏️  Mise à jour de app.yaml avec votre repository..."
sed -i.bak "s|repoURL:.*|repoURL: $repo_url|g" app.yaml
rm -f app.yaml.bak

echo "✅ app.yaml mis à jour"

# Demander si on doit déployer maintenant
echo ""
echo "Voulez-vous déployer l'application maintenant ? (y/n)"
read -r deploy_now

if [[ "$deploy_now" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🚀 Déploiement de l'application..."
    kubectl apply -f app.yaml
    
    echo ""
    echo "✅ Application déployée dans Argo CD"
    echo ""
    echo "Pour voir l'état de l'application:"
    echo "  kubectl get application test-app -n argocd"
    echo ""
    echo "Pour accéder à l'application:"
    echo "  kubectl port-forward -n test-app svc/test-app 8080:80"
    echo "  Puis ouvrir: http://localhost:8080"
else
    echo ""
    echo "Pour déployer plus tard, exécutez:"
    echo "  kubectl apply -f app.yaml"
fi

echo ""
echo "🎉 Setup terminé !"
echo ""
echo "Prochaines étapes:"
echo "1. Pousser ce code dans votre repository Git"
echo "2. L'application sera automatiquement synchronisée par Argo CD"
echo "3. Consultez TEST_GUIDE.md pour des exemples de modifications"
