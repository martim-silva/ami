packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.4"
      source = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  ssh_username = vault("infra/data/windows-ami", "username")
  chipset = "${consul_key("infra/windows-ami/chipset")}"
  firmware = "${consul_key("infra/windows-ami/firmware")}"
  disk_size = "${consul_key("infra/windows-ami/disk_size")}"
  cpus = "${consul_key("infra/windows-ami/cpus")}"
  memory = "${consul_key("infra/windows-ami/memory")}"
  iso_url = "${consul_key("infra/windows-ami/iso_url")}"
  guest_os_type = "${consul_key("infra/windows-ami/guest_os_type")}"
  vm_name = "${consul_key("infra/windows-ami/vm_name")}"
  autounattend_path = "${consul_key("infra/windows-ami/autounattend_path")}"
}

local "ssh_password" {
  expression = vault("infra/data/windows-ami", "password")
  sensitive  = true
}

source "virtualbox-iso" "windows-vm" {
  guest_os_type    = local.guest_os_type
  
  iso_url          = local.iso_url
  iso_checksum     = "none"
  
  floppy_files     = [local.autounattend_path]
  
  pause_before_connecting = "30m"
  ssh_username     = local.ssh_username
  ssh_password     = local.ssh_password

  chipset          = local.chipset
  firmware         = local.firmware
  disk_size        = local.disk_size
  vm_name          = local.vm_name
  nested_virt      = true
  shutdown_command = "shutdown /s"
  cpus             = local.cpus
  memory           = local.memory
  gfx_vram_size    = 128
  gfx_controller   = "vboxsvga"
  gfx_efi_resolution = "1920x1080"
  audio_controller = "hda"

  boot_command = [
    "<enter>"
  ]
  boot_wait = "60s"
}

build {
  sources = [
    "sources.virtualbox-iso.windows-vm"
    ]
}
