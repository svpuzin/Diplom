resource "yandex_kubernetes_cluster" "k8s-regional" {
  name                    = "k8s-regional"
  network_id              = yandex_vpc_network.diplom-network.id
  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

  labels = {
    app = "diplom"
  }

  master {
    public_ip = true


    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.public-a.zone
        subnet_id = yandex_vpc_subnet.public-a.id
      }
      location {
        zone      = yandex_vpc_subnet.public-b.zone
        subnet_id = yandex_vpc_subnet.public-b.id
      }
      location {
        zone      = yandex_vpc_subnet.public-d.zone
        subnet_id = yandex_vpc_subnet.public-d.id
      }
    }

    security_group_ids = [
      yandex_vpc_security_group.k8s-main-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }

  }
  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller,
  ]

  kms_provider {
    key_id = yandex_kms_symmetric_key.key-g.id
  }
}
