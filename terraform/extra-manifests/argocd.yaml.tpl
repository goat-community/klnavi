apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: argocd
  namespace: kube-system
spec:
  repo: https://argoproj.github.io/argo-helm
  chart: argo-cd
  targetNamespace: argocd
  valuesContent: |-
    configs:
      params:
        server.insecure: true
      cm:
        exec.enabled: true
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: argocd-image-updater
  namespace: kube-system
spec:
  repo: https://argoproj.github.io/argo-helm
  chart: argocd-image-updater
  targetNamespace: argocd
  valuesContent: |-
    image:
      tag: "v0.12.2"
    metrics:
      enabled: true
    extraArgs:
      - --interval
      - 5m
        
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-plan4better-de
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  namespace: argocd
spec:
  tls:
  - hosts:
    - ${argocd_ingress_host}
    secretName: argocd-klnavi-plan4better-de-tls
  rules:
  - host: ${argocd_ingress_host}
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: argocd-server
              port:
                name: http