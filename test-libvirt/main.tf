provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "tf" {
  name      = "tf"
  domain    = "tf.local"
  mode      = "nat"
  addresses = ["10.0.100.0/24"]
}

# qcow2 image from file
resource "libvirt_volume" "cirros-qcow2" {
  name   = "cirros-qcow2"
  source = "/home/archy/Downloads/img/cirros-0.4.0-x86_64-disk.img"
  pool = "vm"
}

# volume with qcow2 backing storage
resource "libvirt_volume" "vol-cirros-qcow2" {
  name           = "vol-cirros-qcow2"
  base_volume_id = "${libvirt_volume.cirros-qcow2.id}"
  pool = "vm"
}

# domain using qcow2-backed volume
resource "libvirt_domain" "domain-cirros-qcow2" {
  name   = "domain-cirros-qcow2"
  memory = "256"
  vcpu   = 1

  network_interface {
    network_name = "tf"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.vol-cirros-qcow2.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ip" {
  value = "${libvirt_domain.domain-cirros-qcow2.network_interface.0.addresses.0}"
}