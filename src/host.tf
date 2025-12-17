resource "vsphere_host" "esx-01" {
  hostname   = "esxi-01.example.com"
  username   = "root"
  password   = "password"
  license    = "00000-00000-00000-00000-00000"
  thumbprint = data.vsphere_host_thumbprint.thumbprint.id
  datacenter = data.vsphere_datacenter.datacenter.id
}
