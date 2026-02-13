End‑to‑End Production‑Grade Observability on AWS EKS with OpenTelemetry, Jaeger, Flask, Helm, Terraform, and AWS ALB
“Winners never quit, quitters never win.”  
This project implements a full real‑world distributed tracing pipeline from browser → ALB → Flask → OpenTelemetry Collector → Jaeger, deployed on AWS EKS with Terraform and Helm.

🎯 What This Project Demonstrates
This repository is a complete, production‑aligned observability stack:

AWS EKS (Terraform-managed)

AWS ALB Ingress Controller

Flask app (Gunicorn + OpenTelemetry auto‑instrumentation)

OpenTelemetry Collector (OTLP)

Jaeger backend

Horizontal Pod Autoscaling (HPA)

ECR for container images

Helm for Kubernetes deployments

CI/CD with Jenkins (build → push → deploy)

This project mirrors real production constraints, failures, and fixes.

🧱 Architecture Overview
Code
Browser
   │
   ▼
AWS ALB (Ingress)
   │
   ▼
Flask App (Gunicorn + OpenTelemetry)
   │  OTLP (4317/4318)
   ▼
OpenTelemetry Collector
   │  OTLP
   ▼
Jaeger
Namespaces
Namespace	Purpose
app	Flask application
opentelemetry	OpenTelemetry Collector
jaeger	Jaeger backend
kube-system	ALB Controller, CNI
📁 Repository Structure
Code
OpenTelemetryProject/
│
├── app/
│   ├── flaskapp/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   └── templates/
│   └── Dockerfile
│
├── helm/
│   └── flask-hello/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── ingress.yaml
│       │   └── hpa.yaml
│       ├── values.yaml
│       └── Chart.yaml
│
├── observability/
│   ├── otel-collector-values.yaml
│   └── jaeger-values.yaml
│
├── infra/
│   └── terraform/
│       ├── main.tf
│       ├── versions.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── modules/
│           ├── eks/
│           └── vpc/
│
├── jenkins/
│   ├── Jenkinsfile
│   └── scripts/
│       └── deploy-alb-controller.ps1
│
└── README.md
⚙️ Prerequisites
Before running anything, ensure you have:

AWS CLI configured (aws configure)

Docker Desktop running

kubectl installed

Helm installed

Terraform ≥ 1.5

PowerShell (Windows)

IAM permissions for EKS, ECR, VPC, IAM, ALB

🚀 Deployment Steps (with all missing operational steps)
1️⃣ Provision Infrastructure (Terraform)
Cluster already exists — Terraform is used in import‑mode for documentation and node groups.

1. Configure AWS credentials
Code
aws sts get-caller-identity
2. Initialize Terraform
Code
cd infra/terraform
terraform init
3. Validate provider authentication
Code
aws eks list-clusters
aws ec2 describe-vpcs
4. Import existing EKS cluster (if needed)
Code
terraform import module.eks.aws_eks_cluster.this <cluster-name>
5. Apply Terraform
Code
terraform plan
terraform apply
2️⃣ Build & Push Flask Image to ECR
1. Authenticate Docker to ECR
Code
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
2. Build the image
Code
docker build -t opentelemetryproject:local .
3. Tag the image
Code
docker tag opentelemetryproject:local <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello:v2
4. Push the image
Code
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello:v2
3️⃣ Prepare kubectl & IAM Authentication
1. Update kubeconfig
Code
aws eks update-kubeconfig --region us-east-1 --name opentelemetryproject-dev-eks
2. Verify cluster access
Code
kubectl get nodes
kubectl get pods -A
3. Confirm OIDC provider exists
Code
aws eks describe-cluster --name opentelemetryproject-dev-eks \
  --query "cluster.identity.oidc.issuer"
4. Confirm ALB controller IAM role exists
Code
aws iam list-roles | grep eksctl-opentelemetryproject
4️⃣ Deploy Flask App (Helm)
1. Deploy using CI/CD‑friendly overrides
Code
helm upgrade --install flask-hello helm/flask-hello \
  -n app --create-namespace \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello \
  --set image.tag=v2 \
  --set otel.collectorEndpoint="otel-collector.opentelemetry.svc.cluster.local:4317"
2. Verify deployment
Code
kubectl get pods -n app
kubectl logs -n app deployment/flask-hello
5️⃣ Deploy Jaeger
Code
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade --install jaeger jaegertracing/jaeger \
  -n jaeger --create-namespace \
  -f observability/jaeger-values.yaml
6️⃣ Deploy OpenTelemetry Collector
Code
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  -n opentelemetry --create-namespace \
  -f observability/otel-collector-values.yaml
7️⃣ Verification
Check pods
Code
kubectl get pods -A
Port‑forward Jaeger UI
Code
kubectl -n jaeger port-forward svc/jaeger 16686:16686
Open:

Code
http://localhost:16686
Generate traffic
Code
kubectl -n app run load --image=busybox --restart=Never -- sh -c "while true; do wget -q -O- http://flask-hello-svc; sleep 1; done"
Traces appear in Jaeger within seconds.
