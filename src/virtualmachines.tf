resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = local.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  num_cpus = var.cpu_count
  memory   = var.memory_mb
  
  dynamic "network_interface" { ... }
  dynamic "disk" { ... }
  dynamic "clone" { ... }
}
