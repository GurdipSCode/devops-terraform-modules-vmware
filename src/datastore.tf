resource "vsphere_vmfs_datastore" "datastore" {
  name           = "terraform-test"
  host_system_id = data.vsphere_host.host.id

  disks = [
    "mpx.vmhba1:C0:T1:L0",
    "mpx.vmhba1:C0:T2:L0",
    "mpx.vmhba1:C0:T2:L0",
  ]
}
