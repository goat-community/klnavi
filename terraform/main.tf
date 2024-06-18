##################
## KUBE-HETZNER ##
##################

resource "aws_iam_user" "cluster_user" {
  name = "srv_klnavi_cluster_user"
}

resource "aws_iam_access_key" "cluster_user_keys" {
  user = aws_iam_user.cluster_user.name
}

resource "aws_iam_user_policy" "cluster_user_policy" {
  name = "srv_klnavi_cluster_user_policy"
  user = aws_iam_user.cluster_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.aws_region}:253602339696:secret:klnavi*"
      ]
    }
  ]
}
EOF
}



module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token    = var.hcloud_token
  source          = "kube-hetzner/kube-hetzner/hcloud"
  ssh_public_key  = file(var.kube_hetzner_ssh_public_key)
  ssh_private_key = file(var.kube_hetzner_ssh_private_key)
  network_region  = "eu-central"
  cluster_name    = "klnavi"
  control_plane_nodepools = [
    {
      name        = "control-plane-nbg1",
      server_type = "cpx21",
      location    = "nbg1",
      labels      = [],
      taints      = [],
      count       = 1
    },
  ]
  agent_nodepools = [
    {
      name        = "agent-large",
      server_type = "cpx41",
      location    = "nbg1",
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  load_balancer_type       = "lb11"
  load_balancer_location   = "nbg1"
  ssh_max_auth_tries       = 15
  automatically_upgrade_os = false
  automatically_upgrade_k3s = false
  create_kubeconfig        = false
  kured_version            = "1.13.1"
  extra_kustomize_parameters = {
    aws_access_key        = base64encode(aws_iam_access_key.cluster_user_keys.id)
    aws_secret_key        = base64encode(aws_iam_access_key.cluster_user_keys.secret)
    aws_region            = var.aws_region
    argocd_ingress_host   = "argocd.klnavi.plan4better.de"
    argocd_aws_secret_key = "klnavi/ArgoCD"
  }

  extra_firewall_rules = [
    {
      description     = "For external access to the mail server"
      direction       = "out"
      protocol        = "tcp"
      port            = "587"
      source_ips      = []
      destination_ips = ["0.0.0.0/0", "::/0"]
    }
  ]

  # Extra commands to be executed after the `kubectl apply -k` (useful for post-install actions, e.g. wait for CRD, apply additional manifests, etc.).
  extra_kustomize_deployment_commands = <<-EOT
    kubectl apply -f /var/user_kustomize/letsencrypt-issuer.yaml

    kubectl -n external-secrets wait --for condition=established --timeout=120s crd/clustersecretstores.external-secrets.io
    kubectl apply -f /var/user_kustomize/external-secrets-store.yaml

    kubectl -n argocd wait --for condition=established --timeout=120s crd/appprojects.argoproj.io
    kubectl -n argocd wait --for condition=established --timeout=120s crd/applications.argoproj.io
    kubectl apply -f /var/user_kustomize/argocd-secret.yaml
    kubectl -n argocd wait --for condition=ready --timeout=10s externalsecret.external-secrets.io/infra-repo-external-secret
    kubectl apply -f /var/user_kustomize/argocd-app.yaml
    
  EOT
}


output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}



