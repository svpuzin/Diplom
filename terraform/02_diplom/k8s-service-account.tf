resource "yandex_iam_service_account" "k8s-sa" {
  name        = "k8s-sa"
  description = "K8S service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  folder_id = var.yandex_folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  folder_id = var.yandex_folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.key-g.id
  role             = "viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}",
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "encryptor" {
  folder_id = var.yandex_folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_binding" "load-balancer-admin" {
  folder_id = var.yandex_folder_id
  role      = "load-balancer.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-pusher" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.pusher"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}
