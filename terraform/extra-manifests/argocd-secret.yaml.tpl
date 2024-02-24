apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: infra-repo-external-secret
  namespace: argocd
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: cluster-secret-store
    kind: ClusterSecretStore
  target:
    name: infra-repo-secret
    template:
      metadata:
        labels:
          argocd.argoproj.io/secret-type: repository
      data:
        type: git
        url: '{{ .repository_url | toString }}'
        username: not-used
        password: '{{ .private_access_token | toString }}'
  data:
  - secretKey: private_access_token
    remoteRef:
      key: ${argocd_aws_secret_key}
      property: private_access_token
  
  - secretKey: repository_url
    remoteRef:
      key: ${argocd_aws_secret_key}
      property: repository_url
