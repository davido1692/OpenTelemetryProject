# OpenTelemetryProject 🚀

End‑to‑end **production‑grade observability** on **AWS EKS** using **OpenTelemetry**, **Jaeger**, **Flask**, **Helm**, **Terraform**, and **AWS ALB Ingress**.

> *“Winners never quit, quitters never win.”*
> This project proves a full, real‑world tracing pipeline from browser → ALB → app → collector → Jaeger.

---

## 🔥 What This Project Demonstrates

* ✅ AWS EKS with ALB Ingress Controller
* ✅ Python Flask app (Gunicorn) with OpenTelemetry auto‑instrumentation
* ✅ OpenTelemetry Collector (OTLP)
* ✅ Jaeger distributed tracing backend
* ✅ Horizontal Pod Autoscaling (HPA)
* ✅ Real‑world troubleshooting (CNI IP exhaustion, Terraform state drift, Helm merge conflicts)

This is **not** a toy demo — it reflects real production constraints and fixes.

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

Namespaces:

* `app` – Flask application
* `opentelemetry` – OTEL Collector
* `jaeger` – Jaeger backend
* `kube-system` – AWS ALB Controller, CNI

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

* AWS Account
* AWS CLI configured
* Docker Desktop
* kubectl
* Helm
* Terraform ≥ 1.5
* PowerShell (Windows)

---

## 🚀 Deployment Steps (High Level)

### 1️⃣ Provision Infrastructure (Terraform)

> **Note:** Cluster already exists — Terraform is used in import‑mode for documentation and node groups.

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

---

### 2️⃣ Build & Push Flask Image

```bash
docker build -t opentelemetryproject:local .

docker tag opentelemetryproject:local <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/opentelemetryproject/flask-hello:v2

docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/opentelemetryproject/flask-hello:v2
```

---

### 3️⃣ Deploy Flask App

```bash
helm upgrade --install flask-hello helm/flask-hello -n app --create-namespace
```

---

### 4️⃣ Deploy Jaeger

```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade --install jaeger jaegertracing/jaeger -n jaeger --create-namespace -f observability/jaeger-values.yaml
```

---

### 5️⃣ Deploy OpenTelemetry Collector

```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  -n opentelemetry --create-namespace \
  -f observability/otel-collector-values.yaml
```

---

## 📡 OpenTelemetry Collector Configuration (Key)

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: ${env:MY_POD_IP}:4317
      http:
        endpoint: ${env:MY_POD_IP}:4318

exporters:
  otlp:
    endpoint: jaeger.jaeger.svc.cluster.local:4317
    tls:
      insecure: true
```

---

## 🔍 Verification

### Check pods

```bash
kubectl get pods -A
```

### Port‑forward Jaeger UI

```bash
kubectl -n jaeger port-forward svc/jaeger 16686:16686
```

Open:

```
http://localhost:16686
```

### Generate traffic

```bash
kubectl -n app run load --image=busybox --restart=Never -- sh -c "while true; do wget -q -O- http://flask-hello-svc; sleep 1; done"
```

Traces should appear in Jaeger within seconds.

---

## 🧠 Lessons Learned (Real‑World)

* AWS CNI **IP exhaustion** will break pods silently
* Terraform state drift causes endless `CreateCluster (409)` loops
* Jaeger exporter is **deprecated** — use OTLP
* Helm values merging requires correct **map structures**
* Python 3.12 + OTEL requires explicit dependency handling

---

## 🏆 Why This Matters

This project mirrors **real production incidents** and their fixes — not sanitized tutorials.

It demonstrates:

* Systems thinking
* Deep Kubernetes knowledge
* Cloud networking awareness
* Observability best practices

---

## 📌 Next Enhancements

* Grafana dashboards
* Span metrics pipeline
* Trace‑to‑log correlation
* CI/CD automation

---

## 👤 Author

**Temitayo Olanbiwonnu**
Cloud • DevOps • Observability • Data Engineering

---

If this helped you, ⭐ the repo and reach out.
