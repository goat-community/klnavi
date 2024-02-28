apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: klnavi-dev
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: main
    argocd-image-updater.argoproj.io/image-list: |
      ui=ghcr.io/goat-community/digitransit-ui
    argocd-image-updater.argoproj.io/update-strategy: latest
    argocd-image-updater.argoproj.io/ignore-tags: next,latest
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/goat-community/klnavi
    targetRevision: HEAD
    path: argocd/apps/klnavi/overlays/dev
  destination: 
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    automated:
      selfHeal: true
      prune: true
