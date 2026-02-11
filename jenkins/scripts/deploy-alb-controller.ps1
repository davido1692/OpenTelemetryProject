param(
  [Parameter(Mandatory=$true)][string]$ClusterName,
  [Parameter(Mandatory=$true)][string]$Region,
  [Parameter(Mandatory=$true)][string]$VpcId
)

$ErrorActionPreference = "Stop"

# 1) Associate OIDC
eksctl utils associate-iam-oidc-provider --cluster $ClusterName --region $Region --approve

# 2) Download IAM policy JSON
$policyUrl = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
Invoke-WebRequest -Uri $policyUrl -OutFile "iam_policy.json"

# 3) Create IAM Policy (or reuse if exists)
$policyName = "AWSLoadBalancerControllerIAMPolicy"
$existing = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$policyName'].Arn | [0]" --output text

if ($existing -and $existing -ne "None") {
  $policyArn = $existing
} else {
  $policyArn = aws iam create-policy --policy-name $policyName --policy-document file://iam_policy.json --query "Policy.Arn" --output text
}

# 4) Create service account
eksctl create iamserviceaccount `
  --cluster $ClusterName `
  --region $Region `
  --namespace kube-system `
  --name aws-load-balancer-controller `
  --attach-policy-arn $policyArn `
  --override-existing-serviceaccounts `
  --approve

# 5) Install controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller `
  -n kube-system `
  --set clusterName=$ClusterName `
  --set serviceAccount.create=false `
  --set serviceAccount.name=aws-load-balancer-controller `
  --set region=$Region `
  --set vpcId=$VpcId

# 6) Verify
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller
kubectl -n kube-system get pods | Select-String "aws-load-balancer-controller"
