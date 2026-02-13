# End‑to‑End Production‑Grade Observability on AWS EKS with OpenTelemetry, Jaeger, Flask, Helm, Terraform, and AWS ALB

> *“Winners never quit, quitters never win.”*  
> This project implements a real‑world distributed tracing pipeline from browser → ALB → Flask → OpenTelemetry Collector → Jaeger, deployed on AWS EKS using Terraform and Helm.

---

## 🎯 What This Project Demonstrates

- AWS EKS (Terraform-managed)  
- AWS ALB Ingress Controller  
- Flask app (Gunicorn + OpenTelemetry auto‑instrumentation)  
- OpenTelemetry Collector (OTLP)  
- Jaeger backend  
- Horizontal Pod Autoscaling (HPA)  
- ECR for container images  
- Helm for Kubernetes deployments  
- CI/CD with Jenkins (build → push → deploy)  

This project mirrors real production constraints, failures, and fixes.

---

## 🧱 Architecture Overview

```
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
```

### Namespaces

| Namespace       | Purpose                     |
|-----------------|-----------------------------|
| app             | Flask application           |
| opentelemetry   | OpenTelemetry Collector     |
| jaeger          | Jaeger backend              |
| kube-system     | ALB Controller, CNI         |

---

## 📁 Repository Structure

```
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
```

---

## ⚙️ Prerequisites

- AWS CLI configured  
- Docker Desktop  
- kubectl  
- Helm  
- Terraform ≥ 1.5  
- PowerShell (Windows)  
- IAM permissions for EKS, ECR, VPC, IAM, ALB  

---

# 🚀 Deployment Steps (with all operational steps included)

---

# 1️⃣ Provision Infrastructure (Terraform)

> *Cluster already exists — Terraform is used in import‑mode for documentation and node groups.*

### Configure AWS credentials

```
aws sts get-caller-identity
```

### Initialize Terraform

```
cd infra/terraform
terraform init
```

### Validate AWS access

```
aws eks list-clusters
aws ec2 describe-vpcs
```

### Import existing EKS cluster (if needed)

```
terraform import module.eks.aws_eks_cluster.this <cluster-name>
```

### Apply Terraform

```
terraform plan
terraform apply
```

---

# 2️⃣ Build & Push Flask Image to ECR

### Authenticate Docker to ECR

```
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### Build the image

```
docker build -t opentelemetryproject:local .
```

### Tag the image

```
docker tag opentelemetryproject:local <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello:v2
```

### Push the image

```
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello:v2
```

---

# 3️⃣ Prepare kubectl & IAM Authentication

### Update kubeconfig

```
aws eks update-kubeconfig --region us-east-1 --name opentelemetryproject-dev-eks
```

### Verify cluster access

```
kubectl get nodes
kubectl get pods -A
```

### Confirm OIDC provider

```
aws eks describe-cluster --name opentelemetryproject-dev-eks \
  --query "cluster.identity.oidc.issuer"
```

### Confirm ALB controller IAM role

```
aws iam list-roles | grep eksctl-opentelemetryproject
```

---

# 4️⃣ Deploy Flask App (Helm)

```
helm upgrade --install flask-hello helm/flask-hello \
  -n app --create-namespace \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/opentelemetryproject/flask-hello \
  --set image.tag=v2 \
  --set otel.collectorEndpoint="otel-collector.opentelemetry.svc.cluster.local:4317"
```

### Verify deployment

```
kubectl get pods -n app
kubectl logs -n app deployment/flask-hello
```

---

# 5️⃣ Deploy Jaeger

```
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade --install jaeger jaegertracing/jaeger \
  -n jaeger --create-namespace \
  -f observability/jaeger-values.yaml
```

---

# 6️⃣ Deploy OpenTelemetry Collector

```
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  -n opentelemetry --create-namespace \
  -f observability/otel-collector-values.yaml
```

---

# 7️⃣ Verification

### Check pods

```
kubectl get pods -A
```

### Port‑forward Jaeger UI

```
kubectl -n jaeger port-forward svc/jaeger 16686:16686
```

Open:

```
http://localhost:16686
```

### Generate traffic

```
kubectl -n app run load --image=busybox --restart=Never -- sh -c "while true; do wget -q -O- http://flask-hello-svc; sleep 1; done"
```

Traces appear in Jaeger within seconds.

---

## 🧠 Lessons Learned

- AWS CNI IP exhaustion silently breaks pods  
- Terraform state drift causes 409 CreateCluster loops  
- Jaeger exporter is deprecated — OTLP is the standard  
- Helm values merging requires correct map structures  
- Python 3.12 + OTEL requires explicit dependency handling  
- ALB Ingress requires correct IAM roles and OIDC provider  

---

## 👤 Author

**Temitayo Olanbiwonnu**  
Cloud • DevOps • Observability • Data Engineering
