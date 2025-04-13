packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.4"
      source = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
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
  guest_additions_path = "${consul_key("infra/windows-ami/guest_additions_path")}"
  guest_additions_url = "${consul_key("infra/windows-ami/guest_additions_url")}"
}

local "ssh_password" {
  expression = vault("infra/data/windows-ami", "password")
  sensitive  = true
}

locals {
  output_box = "output/${local.vm_name}-vagrant.box"
  box_name = "win-server-22"
  box_version = "1.0.0"
  provider = "virtualbox"
  registry_root = "\\\\beelink\\share2\\boxes"
  box_url_base = "http://beelink:8040/vagrant/boxes"
}

source "virtualbox-iso" "windows-vm" {
  guest_os_type    = local.guest_os_type
  
  iso_url          = local.iso_url
  iso_checksum     = "none"
  
  floppy_files     = [local.autounattend_path]
  
  communicator        = "winrm"
  winrm_username = local.ssh_username
  winrm_password = local.ssh_password
  winrm_use_ssl = true
  winrm_port = 5986
  winrm_insecure = true  # because your cert is self-signed
  winrm_timeout = "1h30m"
  
  guest_additions_mode = "attach"
  guest_additions_url = local.guest_additions_url
  guest_additions_path = local.guest_additions_path  

  # pause_before_connecting = "30m"
  # ssh_username     = local.ssh_username
  # ssh_password     = local.ssh_password


  chipset          = local.chipset
  firmware         = local.firmware
  disk_size        = local.disk_size
  vm_name          = local.vm_name
  nested_virt      = true
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

  shutdown_command = "cmd /c shutdown /s /t 10 /f /d p:4:1 /c \"Packer shutdown\""
  shutdown_timeout = "1h"

}

build {
  sources = [
    "sources.virtualbox-iso.windows-vm"
    ]

    provisioner "powershell" {
      script = "scripts/chocolatey-packages.ps1"
    }

    post-processor "vagrant" {
      output = "output/${local.vm_name}-vagrant.box"
    }

    post-processor "shell-local" {
      command = "powershell.exe -ExecutionPolicy Bypass -File scripts/box-metadata.ps1 `\"${var.output_box}`\" `\"${var.box_name}`\" `\"${var.box_version}`\" `\"${var.provider}`\" `\"${var.registry_root}`\" `\"${var.box_url_base}`\""
    }
}
