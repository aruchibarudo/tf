
# qcow2 image from file
resource "libvirt_volume" "al-qcow2" {
  name   = "al-qcow2"
  source = "/home/archy/Downloads/img/linux-tinycore-linux-6.4.img"
  pool = "vm"
}

# volume with qcow2 backing storage
resource "libvirt_volume" "vol-al-qcow2" {
  name           = "vol-al-qcow2"
  base_volume_id = "${libvirt_volume.al-qcow2.id}"
  pool = "vm"
}

# domain using qcow2-backed volume
resource "libvirt_domain" "domain-al-qcow2" {
  name   = "domain-al-qcow2"
  memory = "256"
  vcpu   = 1

  network_interface {
    network_name = "tf"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.vol-al-qcow2.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "al-ip" {
  value = "${libvirt_domain.domain-al-qcow2.network_interface.0.addresses.0}"
}