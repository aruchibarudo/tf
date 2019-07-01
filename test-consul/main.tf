variable "stand" {
  default = 2
}

provider "consul" {
  address    = "localhost:8500"
  datacenter = "dc1"
}

# Access a key in Consul
data "consul_keys" "vms" {
  key {
    name    = "cnt"
    path    = "vm/${var.stand}/count"
    default = "0"
  }  
}

data "consul_key_prefix" "vm" {

  # Prefix to add to prepend to all of the subkey names below.
  path_prefix = "vm/${var.stand}/spb${count.index+1}/"
  #path_prefix = "vm/1/spb1/"
  count = "${data.consul_keys.vms.var.cnt}"

 }

data "null_data_source" "nr" {  
  inputs = {
    cpu = "${join(";",data.consul_key_prefix.vm.*.subkeys.cpu)}"
    ram = "${join(";",data.consul_key_prefix.vm.*.subkeys.ram)}"
  }
}

# Use our variable from Consul

output "count" {
  value = "${data.consul_keys.vms.var.cnt}"
}

output "cpu" {
  #value = ["${data.null_data_source.nr.outputs["cpu"]}"]
  value = ["${data.consul_key_prefix.vm.*.subkeys.cpu}"]
}
output "ram" {
  value = ["${data.null_data_source.nr.outputs["ram"]}"]
}

