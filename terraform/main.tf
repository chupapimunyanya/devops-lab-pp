terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# Змінна для токена (значення передамо через Environment Variable в GitHub)
variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

# 1. Кластер Kubernetes
resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "devops-lab-cluster"
  region  = "fra1"
  version = "1.32.1-do.0" # Якщо буде помилка версії, змініть на "latest_patch"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb" # Мінімум для k8s
    node_count = 1
  }
}

# 2. База даних (PostgreSQL) - Вимога РР
resource "digitalocean_database_cluster" "postgres-db" {
  name       = "devops-lab-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "fra1"
  node_count = 1
}

# 3. Налаштування провайдера K8s
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  token = digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].cluster_ca_certificate
  )
}

# 4. Створення Namespaces (dev, stage, prod)
resource "kubernetes_namespace" "envs" {
  for_each = toset(["dev", "stage", "prod"])
  metadata {
    name = each.key
  }
}

# Виводимо дані, щоб потім використовувати
output "cluster_name" {
  value = digitalocean_kubernetes_cluster.k8s_cluster.name
}

output "db_host" {
  value = digitalocean_database_cluster.postgres-db.private_host
}