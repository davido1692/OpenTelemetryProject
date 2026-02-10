$ErrorActionPreference = "Stop"

Write-Host "Installing tools checks..."

# AWS CLI
aws --version

# kubectl
kubectl version --client

# Helm
helm version

Write-Host "Tools look OK."
