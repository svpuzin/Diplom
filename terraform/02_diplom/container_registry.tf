resource "yandex_container_registry" "container_registry" {
  name      = "diplom-container-registry"
  folder_id = var.yandex_folder_id
}
