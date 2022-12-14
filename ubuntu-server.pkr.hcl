# https://www.packer.io/docs/builders/vmware/vsphere-iso

variable boot_command {
  type = string
  description = "Specifies the keys to type when the virtual machine is first booted in order to start the OS installer. This command is typed after boot_wait, which gives the virtual machine some time to actually load."
  default = <<-EOF
  <enter><wait2><enter><wait><f6><esc><wait>
   autoinstall ds=nocloud;
  <enter>
  EOF
}

variable cluster {
  type = string
  description = "The vSphere cluster where the target VM is created."
  default = "Cluster-1"
}

variable datacenter {
  type = string
  description = "The vSphere datacenter name. Required if there is more than one datacenter in vCenter."
  default = "SDDC-Datacenter"
}

variable datastore {
  type = string
  description = "The vSAN, VMFS, or NFS datastore for virtual disk and ISO file storage. Required for clusters, or if the target host has multiple datastores."
  default = "WorkloadDatastore"
}

variable disk_controller_type {
  type = string
  description = "The virtual disk controller type."
  default = "pvscsi"
}

variable floppy_files {
  type = list(string)
  description = "The list of local files to be mounted to the VM floppy drive. At a minimum, the cloud-init user-data and meta-data files should be included in this list."
  default = [
    "./http/ubuntu-server/user-data",
    "./http/ubuntu-server/meta-data",
  ]
}

variable folder {
  type = string
  description = "The VM folder in which the VM template will be created."
  default = "Templates"
}

variable host {
  type = string
  description = "The ESXi host where target VM is created. A full path must be specified if the host is in a host folder."
  default = ""
}

variable insecure_connection {
  type = bool
  description = "If true, does not validate the vCenter server's TLS certificate."
  default = false
}

variable iso_filename {
  type = string
  description = "The file name of the guest operating system ISO image installation media."
  # https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso
  default = "ubuntu-20.04.2-live-server-amd64.iso"
}

variable iso_filepath {
  type = string
  description = "The file path within your datastore to your ISO image installation media."
  default = "/ISOs"
}

variable network {
  type = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected. A full path must be specified if the network is in a network folder."
  default = "sddc-cgw-network-1"
}

variable password {
  type = string
  description = "The plaintext password for authenticating to vCenter."
}

variable resource_pool {
  type = string
  description = "The vSphere resource pool in which the VM will be created."
  default = "Compute-ResourcePool"
}

variable ssh_password {
  type = string
  description = "The plaintext password to use to authenticate over SSH."
}

variable ssh_username {
  type = string
  description = "The username to use to authenticate over SSH."
  default = "ubuntu"
}

variable username {
  type = string
  description = "The username for authenticating to vCenter."
  default = "cloudadmin@vmc.local"
}

variable vcenter_server {
  type = string
  description = "The vCenter server hostname, IP, or FQDN. For VMware Cloud on AWS, this should look like: 'vcenter.sddc-[ip address].vmwarevmc.com'."
}

variable vm_name {
  type = string
  description = "The name of the new VM template to create."
  default = "template-ubuntu-server-20.04-amd64"
}

variable vm_version {
  type = number
  description = "The VM virtual hardware version."
  # https://kb.vmware.com/s/article/1003746
  default = 17
}

locals {
  iso_path = "[${var.datastore}] ${var.iso_filepath}/${var.iso_filename}"
  vm_name = "${var.vm_name}-${formatdate("YYYYMMDD'T'hhmmss", timestamp())}Z"
}

source vsphere-iso ubuntu-server {
  CPUs = 2
  RAM = 2048
  RAM_reserve_all = true
  boot_command = [
    var.boot_command,
  ]
  boot_wait = "2s"
  cluster = var.cluster
  convert_to_template = true
  datacenter = var.datacenter
  datastore = var.datastore
  disk_controller_type = [
    var.disk_controller_type,
  ]
  floppy_files = var.floppy_files
  floppy_label = "cidata"
  folder = var.folder
  guest_os_type = "ubuntu64Guest"
  host = var.host
  insecure_connection = var.insecure_connection
  iso_paths = [
    local.iso_path,
  ]
  network_adapters {
    network = var.network
    network_card = "vmxnet3"
  }
  password = var.password
  resource_pool = var.resource_pool
  ssh_password = var.ssh_password
  ssh_timeout = "20m"
  ssh_username = var.ssh_username
  storage {
    disk_size = 8192
    disk_thin_provisioned = true
  }
  username = var.username
  vcenter_server = var.vcenter_server
  vm_name = local.vm_name
  vm_version = var.vm_version
}

build {
  sources = [
    "source.vsphere-iso.ubuntu-server",
  ]

  provisioner shell {
    scripts = [
      "./http/scripts/linux/awscli.sh",
    ]
  }
}
