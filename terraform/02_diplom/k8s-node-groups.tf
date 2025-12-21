resource "yandex_kubernetes_node_group" "k8s-group-a" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "k8s-group-a"

  labels = {
    app = "diplom"
  }

  instance_template {
    name = "node-a-{instance.short_id}"

    labels = {
      app = "diplom"
    }


    platform_id = "standard-v1"

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-a.id}"]
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  scale_policy {
    auto_scale {
      min     = 1
      max     = 2
      initial = 1
    }
  }
}


resource "yandex_kubernetes_node_group" "k8s-group-b" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "k8s-group-b"

  labels = {
    app = "diplom"
  }

  instance_template {
    name        = "node-b-{instance.short_id}"
    platform_id = "standard-v1"

    labels = {
      app = "diplom"
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-b.id}"]
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }

  scale_policy {
    auto_scale {
      min     = 1
      max     = 2
      initial = 1
    }
  }
}


resource "yandex_kubernetes_node_group" "k8s-group-d" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "k8s-group-d"

  labels = {
    app = "diplom"
  }

  instance_template {
    name        = "node-d-{instance.short_id}"
    platform_id = "standard-v2"

    labels = {
      app = "diplom"
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-d.id}"]
      security_group_ids = [
        yandex_vpc_security_group.k8s-main-sg.id,
        yandex_vpc_security_group.k8s-public-services.id,
        yandex_vpc_security_group.k8s-nodes-ssh-access.id
      ]
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-d"
    }
  }

  scale_policy {
    auto_scale {
      min     = 1
      max     = 2
      initial = 1
    }
  }
}
