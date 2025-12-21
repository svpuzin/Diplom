resource "yandex_vpc_subnet" "public-a" {
  name           = "public-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.0.10.0/24"]
}
resource "yandex_vpc_subnet" "public-b" {
  name           = "public-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.0.20.0/24"]
}
resource "yandex_vpc_subnet" "public-d" {
  name           = "public-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.0.30.0/24"]
}

