resource "yandex_iam_service_account" "sa" {
  folder_id   = var.yandex_folder_id
  name        = "tf-state-ops"
  description = "Service account for Terraform state object storage management"
}

resource "yandex_resourcemanager_folder_iam_member" "s3-admin" {
  folder_id = var.yandex_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "s3-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Static access key for object storage"
}

resource "yandex_resourcemanager_folder_iam_member" "encryptor" {
  folder_id = var.yandex_folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
