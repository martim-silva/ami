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
  winrm_timeout = "1h"
  
  guest_additions_mode = "disable"
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

  shutdown_command = "shutdown -P now"
  shutdown_timeout = "1h"

}

build {
  sources = [
    "sources.virtualbox-iso.windows-vm"
    ]

    provisioner "powershell" {
      inline = [
        "Write-Host \"Installing Chocolatey...\"",
        "Set-ExecutionPolicy Bypass -Scope Process -Force",
        "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
        "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",

        "choco install virtualbox-guest-additions-guest.install -y",

        "Write-Host \"Installing BMW Certificates...\"",
        "$zipFile = \"$env:TEMP\\certificates.zip\"",
        "Invoke-WebRequest -Uri \"http://sslcrl.bmwgroup.net/pki/BMW_Trusted_Certificates_Latest.zip\" -OutFile $zipFile -UseBasicParsing",
        "Expand-Archive -Path $zipFile -DestinationPath \"$env:TEMP\\certificates\" -Force",
        "Get-ChildItem -Path \"$env:TEMP\\*.crt\" -Recurse | ForEach-Object { Import-Certificate -FilePath $_.FullName -CertStoreLocation Cert:\\\\LocalMachine\\\\Root }"
      ]
    }

    post-processor "vagrant" {
      output = "output/${local.vm_name}-vagrant.box"
  }
}
