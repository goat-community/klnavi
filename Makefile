.SILENT:
.PHONY: vote metrics

help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-22s\033[0m%s\n", $$1, $$2 }'


argocd-admin-password: # Export ArgoCD Admin Password
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	 
# export HCLOUD_TOKEN="your_hcloud_token"	
packer-image-create: # Create Packer Image
	packer init packer/hcloud-microos-snapshots.pkr.hcl
	packer build packer/hcloud-microos-snapshots.pkr.hcl
