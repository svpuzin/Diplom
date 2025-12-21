resource "yandex_kms_symmetric_key" "key-bde" {
  name              = "key-buckets-data-encode"
  description       = "For buckets content encode only"
  default_algorithm = "AES_128"
  rotation_period   = "2928h"
}
