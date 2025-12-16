Предварительная подготовка к установке и запуску Kubernetes кластера.

Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
ChatGPT сказал:
Хорошо, давай сделаем правильный bootstrap для Terraform, который подготовит сервисный аккаунт в Яндекс Облаке для управления инфраструктурой без суперправ.
Ниже — пошаговая конфигурация с пояснениями.

1️⃣ Создание сервисного аккаунта
resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "Service account for managing infrastructure"
}
Имя любое, но желательно указать terraform
Это аккаунт будет использоваться для всех операций Terraform
2️⃣ Назначение минимальных ролей
Для подготовки Kubernetes кластера сервисному аккаунту нужны только необходимые права, а именно:
Назначение	Роль
VPC / сети	vpc.admin
Compute / ноды	compute.admin
Storage (backend, registry)	storage.editor
Container Registry (если нужен)	container-registry.admin
Пример:
resource "yandex_resourcemanager_folder_iam_member" "vpc" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "compute" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry" {
  folder_id = var.folder_id
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
✅ Это минимальные и достаточные права
❌ Не используется editor или admin на уровне всей папки
3️⃣ Создание статического ключа доступа
Чтобы Terraform мог работать с Object Storage (для backend):
resource "yandex_iam_service_account_static_access_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Static access key for Terraform"
}
access_key и secret_key потом передаются в backend Terraform через переменные окружения, а не хардкодом.
4️⃣ Создание bucket для tfstate (опционально на этом этапе)
resource "yandex_storage_bucket" "tfstate" {
  bucket = "tfstate-${var.folder_id}"

  access_key = yandex_iam_service_account_static_access_key.terraform_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_key.secret_key

  acl = "private"

  versioning {
    enabled = true
  }
}
Versioning обязательно, чтобы можно было откатывать состояние
ACL private, чтобы никто кроме сервисного аккаунта не имел доступа
5️⃣ Provider для bootstrap
provider "yandex" {
  token     = var.token     # только на bootstrap
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}
После bootstrap Terraform использует static access key, token больше не нужен.
🔹 Итог
Сервисный аккаунт создан
Назначены минимальные роли для Terraform
Backend S3 подготовлен (bucket + ключ)
Без суперпользователя, без editor
Если хочешь, я могу сразу написать готовый пример Terraform bootstrap, который:
Создаёт сервисный аккаунт
Создаёт bucket для backend
Генерирует static access key
Полностью готов к terraform apply и terraform destroy без ручных действий
Хочешь, чтобы я это сделал?
Вы сказали:
да
ChatGPT сказал:
Отлично! Ниже — готовый, production-ready Terraform bootstrap для подготовки сервисного аккаунта и bucket под backend Terraform в Яндекс Облаке. Он полностью соответствует требованиям: минимальные права, безопасно, без суперпользователя, готов к terraform apply и destroy.
1️⃣ Структура проекта
bootstrap/
├── main.tf
├── variables.tf
└── outputs.tf
2️⃣ variables.tf
variable "folder_id" {
  description = "ID папки в Яндекс Облаке"
  type        = string
}

variable "cloud_id" {
  description = "ID облака в Яндекс Облаке"
  type        = string
}

variable "token" {
  description = "OAuth-токен для bootstrap (только временно)"
  type        = string
  sensitive   = true
}
3️⃣ main.tf
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120"
    }
  }
}

provider "yandex" {
  token     = var.token      # только для bootstrap
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# 1. Сервисный аккаунт Terraform
resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "Service account for Terraform infrastructure management"
}

# 2. Минимальные роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "vpc" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "compute" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry" {
  folder_id = var.folder_id
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# 3. Статический ключ доступа для Terraform backend
resource "yandex_iam_service_account_static_access_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Static access key for Terraform backend"
}

# 4. Bucket для tfstate
resource "yandex_storage_bucket" "tfstate" {
  bucket = "tfstate-${var.folder_id}"

  access_key = yandex_iam_service_account_static_access_key.terraform_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_key.secret_key

  acl = "private"

  versioning {
    enabled = true
  }
}
4️⃣ outputs.tf
output "service_account_id" {
  value = yandex_iam_service_account.terraform_sa.id
}

output "bucket_name" {
  value = yandex_storage_bucket.tfstate.bucket
}

output "access_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_key.access_key
  sensitive = true
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_key.secret_key
  sensitive = true
}
5️⃣ Использование
Инициализировать bootstrap:
cd bootstrap
terraform init
terraform apply
Экспортировать ключи для backend Terraform:
export AWS_ACCESS_KEY_ID=$(terraform output -raw access_key)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw secret_key)
В основной инфраструктуре (infra/) использовать backend:
terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "tfstate-<folder_id>"
    key                         = "infra/terraform.tfstate"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
✅ Этот bootstrap:
Создаёт сервисный аккаунт
Назначает только необходимые права
Создаёт bucket с versioning и private ACL
Генерирует static access key
Полностью готов к CI/CD
Можно использовать terraform destroy без ручных действий
Если хочешь, следующим шагом я могу написать готовый Terraform для VPC + multi-AZ, чтобы сразу подготовить сеть под Kubernetes.
Хочешь, чтобы я это сделал?