### Objective

Create a compatible image for Terraform.

It looks like [Packer](https://www.packer.io/) is the way to go.

> What is Packer?
> 
>Packer is an open source tool that lets you create identical machine images for multiple platforms from a single source >template. Packer can create golden images to use in image pipelines.

[Installed Packer](https://developer.hashicorp.com/packer/downloads)

[Hashicorp Packer Crash Course with Digital Ocean](https://www.youtube.com/watch?v=T2Gx2fGT9kk)

<<<<<<< HEAD
Digital Ocean Token - *****************
=======
Digital Ocean Token - ******************
>>>>>>> 1192966 ( - Removed token from story.md)

Now that we complete the tutorial, let's try building a Windows image using Packer [virtualbox-iso](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso) builder.

>virtualbox-iso - Starts from an ISO file, creates a brand new VirtualBox VM, installs an OS, provisions software within the OS, then exports that machine to create an image. This is best for people who want to start from scratch.

There are also [virtualbox-ovf](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/ovf) and [virtualbox-vm](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/vm) builders, check [VirtualbBox Builders for Packer](https://developer.hashicorp.com/packer/plugins/builders/virtualbox)

We can successfully start a VM using packer with the following packer file:

````hcl
source "virtualbox-iso" "basic-example" {
  guest_os_type    = "Windows10_64"
  iso_url          = "file:///media/ee12099/Data/images/Windows%2010%20X64%2022H2%2019045.2546%20Pro%20incl%20ACT%20en-US%20LATEST%202023.iso"
  iso_checksum     = "md5:53838b12919e3db23e4036e2f405836b"
  ssh_username     = "packer"
  ssh_password     = "packer"
  disk_size        = 30000
  vm_name          = "Windows Test"
  nested_virt      = true
  shutdown_command = "shutdown /s"
  cpus             = 2
  memory           = 2048
  gfx_vram_size    = 128
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
}
````

We are using the **Windows 10 X64 22H2 19045.2546 Pro incl ACT en-US LATEST 2023.iso** iso file we download from the [torrent link](magnet:?xt=urn:btih:C886ECBC03B0757737D23BC767D7AB4A3F33DFE0&dn=Windows+10+X64+22H2+19045.2546+Pro+incl+Office+2021+en-US+LATEST+2023&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2F47.ip-51-68-199.eu%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2920%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Fopentracker.i2p.rocks%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce).

We just add to create a md5 checksum for that file by running:

```
pv -pteIrabT /media/ee12099/Data/images/Windows\ 10\ X64\ 22H2\ 19045.2546\ Pro\ incl\ ACT\ en-US\ LATEST\ 2023.iso | md5sum
```

where ***/media/ee12099/Data/images/Windows\ 10\ X64\ 22H2\ 19045.2546\ Pro\ incl\ ACT\ en-US\ LATEST\ 2023.iso*** is the path to the file.
And pv -pteIrabT is just to provide progress for the [md5sum](https://manpages.ubuntu.com/manpages/xenial/man1/md5sum.1.html) command - [How to check the progress of md5sum on many huge files?](https://askubuntu.com/questions/463321/how-to-check-the-progress-of-md5sum-on-many-huge-files)

By running `packer build .` we can build the virtualbox image, it's opening VirtualBox and starting the VM with the iso image attached and booting successfully.

![](assets/images/20230207143129.png)  

We now should think on how to automate the installation to have an unnatended install.
By checking [Packer - Automatic Operating System Installs](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs) they say:
> for Windows, it's done using an Autounattend.xml

We can check [Answer files (unattend.xml)](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11) from Microsoft Docs for more information.

And I checked [this youtube video](https://www.youtube.com/watch?v=woR3fFAQSt4) about **Creating an Unattended Install of Windows 10 Pro** where it shows that there is this [Windows Answer File Generator](https://www.windowsafg.com/win10x86_x64.html) thats super usefull to generate the autounattend.xml file. 

In [Unattended Installation for Windows](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/autounattend_windows) they say about **Where to put the Answer File**

>Windows will automatically look for an autounattend.xml file on mounted drives. Many users use the floppy_files option or a secondary mounted iso for providing the answer file to their iso builders.
>
>You can also specify an unattend file to use by using the /unattend: option when running >Windows Setup (setup.exe) in your boot_command.

So we need try this options to attach the file for unattended installation.

Besides that we are getting an error `Build 'virtualbox-iso.basic-example' errored after 5 minutes 27 seconds: Timeout waiting for SSH.`that kill the build process, so we need to find how to setup ssh or something.

In the [What does Packer need the Answer File to do?](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/autounattend_windows#what-does-packer-need-the-answer-file-to-do) they say:

>Packer needs the Answer File to handle any questions that would normally be answered interactively during a Windows installation.
>
>If you want to be able to use provisioners, the Answer file must also contain a script that sets up SSH or WinRM so that Packer can connect to the instance.
>
>inally, your Packer build will be much smoother if the Answer File handles or disables Windows updates rather than you trying to run them using a Packer provisioner. This is because the winrm communicator does not handle the disconnects caused by automatic reboots in Windows updates well, and the disconnections can fail a build.

Focus on **If you want to be able to use provisioners, the Answer file must also contain a script that sets up SSH or WinRM so that Packer can connect to the instance.**

So lets first check how to use the autounattend.xml file by reading [Floppy Configuration](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso#floppy-configuration) for [virtualbox-iso](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso)

So for the `floppy_files` option they say:

>floppy_files ([]string) - A list of files to place onto a floppy disk that is attached when the VM is booted. Currently, no support exists for creating sub-directories on the floppy. Wildcard characters (\*, ?, and []) are allowed. Directory names are also allowed, which will add all the files found in the directory to the floppy.

So we just need to add that variable with a list with the path to our autounnatend.xml file path as the only list item:

```
  floppy_files     = ["/media/ee12099/Data/repo/homelab/packer-tutorial/virtualbox/autounattend.xml"]
```

I tried with just a relative path to the directory where the packer build is called but it didn't work, it only worked with a full path.

![](assets/videos/Peek2023-02-07-15-16.gif)

When building the image the VM opened correctly and it went straight to the installation process meaning that the unnatended installation worked!

During the beggining of the installation we got an error - `Windows cannot install required files. Make sure all files required for installation are available, and restart installation. Error code: 0x8007001B`

![](assets/images/20230207151749.png)  

And this is something probably related to our VM configuration settings or something.
Trying to just create a Windows 10 64 bit VM with this ISO image gave the exactly same result, weird, since I was able to run this in a Windows Host and install to a USB stick using VirtualBox.

Trying to get other images it's being difficult, Microsoft used to provide Win10 images and VirtualBox/VMWare files for Win10 with Edge installed for Edge developers but not anymore. Found this repo [Running IE 8/9/10/11/Edge Virtual machines from Microsoft under Linux via VirtualBox](https://github.com/magnetikonline/linux-microsoft-ie-virtual-machines) that says

>Microsoft have (sadly) removed most (if not all) of these VM images from their public CDN. Repository will remain for historical purposes.

So that explains why we couldn't find any file in [Microsoft Edge Websitee](https://developer.microsoft.com/en-us/microsoft-edge/)

The links are dead but looking at [this issue](https://gist.github.com/zmwangx/e728c56f428bc703c6f6#gistcomment-3115797) they provide a list of new links for the archived images:

````
* [IE6 - Windows XP](https://archive.org/details/ie6.xp.virtualbox)

* [IE8 - Windows XP](https://archive.org/details/ie8.xp.virtualbox)

* [IE8 - Windows 7](https://archive.org/details/ie8.win7.virtualbox)

* [IE9 - Windows 7](https://archive.org/details/ie9.win7.virtualbox)

* [IE10 - Windows 7](https://archive.org/details/ie10.win7.virtualbox)

* [IE11 - Windows 7](https://archive.org/details/ie11.win7.virtualbox)

* [IE11 - Windows 8.1](https://archive.org/details/ie11.win81.virtualbox)

* [Edge - Windows 10](https://archive.org/details/msedge.win10.virtualboxhttps://archive.org/details/msedge.win10.virtualbox)
````

Lets download the [msedge.win10.virtualbox](https://archive.org/details/msedge.win10.virtualbox) image but it will take a while.

While we wait lets try using Packer to create Ubuntu VMs.

Moved our `main.pkr.hcl` and a`utounattend.xml` files to its own `windows/` directory and created a new one `ubuntu/` where I created a new empty `main.pkr.hcl`

Lets go back to [Packer VirtualBox ISO Builder](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso) and start with the example provided.

````
source "virtualbox-iso" "basic-example" {
  guest_os_type = "Ubuntu_64"
  iso_url = "http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso"
  iso_checksum = "md5:769474248a3897f4865817446f9a4a53"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
}

````

It's using [Ubuntu Server 12.04.5](http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso), lets try use a newer version like [Ubuntu Server 22.04.1](https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso)

So just update the `iso_url` to https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso and we also need to update the `iso_checksum` value, you can get the sha255 checksum from https://releases.ubuntu.com/22.04/SHA256SUMS and it's `10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb`

So your `main.pkr.hcl` file should look like:

````
source "virtualbox-iso" "basic-example" {
  guest_os_type = "Ubuntu_64"
  iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso"
  iso_checksum = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
}
````

If we build this with Packer we get the VM up successfully.

![](assets/videos/Peek-2023-02-07-17-43.gif))

Now lets see how we can do an unnatended installation with Ubuntu.

If we look back at [Packer - Automatic Operating System Installs](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs) they say about Debian:

>For Debian operating systems, this is done using a preseed file

So lets see what the hell is a preseed file. 
Packer was the first entry in Google with [Unattended Installation for Debian](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/preseed_ubuntu) and they say about making a preseed file:

>How to make a Preseed File
>
>You can either start from an example preseed file from a known repo (take a look at the examples links below), or you can start with the official example preseed, and comment or uncomment the options as you need them.

:warning: According to [How to use d-i and preseeding on 22.04](https://serverfault.com/questions/1098581/how-to-use-d-i-and-preseeding-on-22-04)

>Preceeding has been deprecated since 20.04 and was removed in 22.04. Ubuntu is now using autoinstall (also called cloud-init): https://ubuntu.com/server/docs/install/autoinstall

So lets check more about cloud-init, I actually did a little tutorial a while ago but honestly did not understand much.

At [Ubuntu - Automated Server installation](https://ubuntu.com/server/docs/install/autoinstall) there is a good explanation on how to configure it and they point to their [Quickstart Page](https://ubuntu.com/server/docs/install/autoinstall-quickstart) but they use [QEMU](https://www.qemu.org/) and we want to use Packer.

This tutorial - [Packer build using Ubuntu 20.04 server ISO](https://imagineer.in/blog/packer-build-for-ubuntu-20-04/) - seems promissing.

>There are multiple ways to provide configuration data for cloud-init. Typically user config is stored in user-data and cloud specific config in meta-data file. The list of supported cloud datasources can be found in cloudinit docs. Since packer builds it locally, data source is NoCloud in our case and the config files will served to the installer over http.

Some more links used
- [HashiCorp Packer to Build a Ubuntu 22.04 Image Template in VMware vSphere](https://tekanaid.com/posts/hashicorp-packer-build-ubuntu22-04-vmware)
- [Ubuntu Server 22.04 image with Packer and Subiquity for Proxmox](https://www.aerialls.eu/posts/ubuntu-server-2204-image-packer-subiquity-for-proxmox/)

So it looks like we only need to create a folder called `http` in the same folder where we have our `main.pkr.hcl` and create the `meta-data` and `user-data` files inside it. 

*You can create more complex structures like the one in the tutorial we are following, if you look at the [github repo](https://github.com/Praseetha-KR/packer-ubuntu) you see they have the folder `subiquity/http` and then it's just a matter of specifying that path in the `http_directory` option in your packer configuration.*

Tried running with the packer config like:

````
source "virtualbox-iso" "basic-example" {
  guest_os_type = "Ubuntu_64"
  iso_url       = "https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso"
  iso_checksum  = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  memory         = 2000
  http_directory = "http"

  boot_wait = "5s"
  boot_command = [
    "<enter><enter><f6><esc><wait> ",
    "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>"
  ]

  shutdown_command = "shutdown -P now"

  ssh_username           = "ee12099"
  ssh_password           = "ubuntu"
  ssh_pty                = true
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "20"
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
}
````

But it just went to normal installation, it looks like the issue is with the `boot_command` it's trying to use F6 to go to boot options but the grub of Ubuntu 22.04 does not use that key, but the c key. So we will need to find the right boot_command for the 22.04 version.

![](assets/images/20230207192021.png)  

For now lets update our file to use Ubuntu 20.04 like in the example to check if the boot_command works (had to update the url and checksum, the ones provided in the example were not working)

````
source "virtualbox-iso" "basic-example" {
  guest_os_type = "Ubuntu_64"
  iso_url        = "https://releases.ubuntu.com/20.04/ubuntu-20.04.5-live-server-amd64.iso"
  iso_checksum   = "sha256:5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
  memory         = 2000
  http_directory = "http"

  boot_wait = "5s"
  boot_command = [
    "<enter><enter><f6><esc><wait> ",
    "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>"
  ]
  shutdown_command = "shutdown -P now"

  ssh_username           = "ee12099"
  ssh_password           = "ubuntu"
  ssh_pty                = true
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "20"
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
}
````

In Ubuntu 20.04.05 we can see that the Boot Screen is different and it uses the F6 like in the `boot_command`.

![](assets/images/20230207192419.png)  

If we run packer build with this configuration we successfully skip the manual installation so it seems the autoinstall is working.

![](assets/videos/Peek-2023-02-07-19-27.gif)

However after a while we get the error:

```
virtualbox-iso.basic-example: Error waiting for SSH: Packer experienced an authentication error when trying to connect via SSH. 
This can happen if your username/password are wrong. 
You may want to double-check your credentials as part of your debugging process. 
original error: ssh: handshake failed: ssh: unable to authenticate, attempted methods [none password], no supported methods remain`
```

I actually thought this could be an issue related to this option in `user-data` and commented it out:

```
  late-commands:
    - 'sed -i "s/dhcp4: true/&\n      dhcp-identifier: mac/" /target/etc/netplan/00-installer-config.yaml'
    # - echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/ubuntu
```

But with no success. From [this issue](https://github.com/hashicorp/packer/issues/11656) we get in a [comment](https://github.com/hashicorp/packer/issues/11656#issuecomment-1071085123):
>We have the same issue with the RHEL 9 beta images.
>
>It seems to be related to the stronger crypto policy requirements on recent OS releases. By running packer in debug mode, we paused after the VM was created, but before packer tries to connect to it using SSH.
>
>While packer is waiting we connect to the machine with ssh (regular OpenSSH, which works just fine) and run update-crypto-policies --set LEGACY.
>
>After that we continue the packer process which now works just fine. Packer can connect with SSH and starts to do the tasks in our packer file.
>
>Our conclusion is that the internal SSH agent used by packer is not up to date with contemporary requirements. It can't handle the DEFAULT policy on RHEL/CentOS (and presumably Fedora). The LEGACY policy, as the name suggests, allows also older less secure algorithms.

Tried adding [update-crypto-policies](https://manpages.ubuntu.com/manpages/focal/en/man8/update-crypto-policies.8.html) to LEGACY in user-data 

```
runcmd:
  - [ /bin/update-crypto-policies, --set, LEGACY]
```

But with no effect. [Another comment](https://github.com/hashicorp/packer/issues/11656#issuecomment-1105435867) in the issue states:

>Having the same problem with Ubuntu 22.04, but with virtualbox-iso as the builder. What's funny if I pass -on-error='ask', and wait for the ISO build to finish, Ubuntu 22.04 actually boots successfully.
>
>EDIT: I tried one of the workaround for the virtualbox-iso build, but the problem is that Ubuntu 22.04 LTS is using the new Subiquity autoinstall interface. Based on the schema (https://ubuntu.com/server/docs/install/autoinstall-reference), you can either use early-commands or late-commands to put in the following fix from above: #11656 (comment).
>
>However, early-commands occurs at a point in the install process where SSH is not yet installed (nor is anything else AFAICT), and late-commands never has a chance to run because Packer fails before then.
>
>In short, it seems for certain *-iso builds, you're SOL until the fix.

So it looks we will have no chance with user-data. But [another comment](https://github.com/hashicorp/packer/issues/11733#issuecomment-1108791457) pointed out:

>I found a temporary workaround which should work for *-iso builds. I tested it on virtualbox-iso. I remembered that the https://github.com/chef/bento project already had a working Ubuntu 20.04 LTS build of the live version of their ISO. I was wondering how they were able to get theirs working.
>
>This is the magic sauce: https://github.com/chef/bento/blob/118ad132f6bd7c09cbf40b4933281d32dfe139fe/packer_templates/ubuntu/http/user-data#L9-L11
>
>Basically, you need to stop SSH during the Subiquity install process so that Packer doesn't freak out, and continues when SSH connectivity is restored.

And the solution is actually to add an early command to kill ssh in the user-data:

```
early-commands:
# otherwise packer tries to connect and exceed max attempts:
- systemctl stop ssh
```

And actually this repository that I also looked at when creating the packer config has this trick in it's [user-data file](https://github.com/nickcharlton/packer-ubuntu-2004/blob/master/http/user-data)

Well we now got the error *Timeout waiting for SSH*. Who would have thought?! :smile:

`Build 'virtualbox-iso.basic-example' errored after 20 minutes 23 seconds: Timeout waiting for SSH.`

I tried again with the build option -on-error=abort so that it wouldn't destroy the machine on error and we got the timeout 20 seconds after the stipulated timeout of 30 minutes. The abort option worked and it didn't kill the machine and in the VM it actually installed but took a while, the openssh server was only installed about 45 mins after the build started. So maybe we should increase the timeout to 1 or 2 hours? But this is taking a lot of time, when I do manual install I don't think it takes so much time but we are running on a VM with limited resources so that may be the issue. 

So I wanna try to run a build again with a higher timeout and after I want to do the same without the early command to kill the ssh service just in case the issue was always just the short timeout, because in the issues they always said that it was resolved with Packer version 1.8.1 and I'm running version 1.8.5

So, I've now ran the build again with timeout set to 1 hour, the only thing I had to do was to change the source name so that it created a different output directory.

While waiting for this build update the configuration file to use the Ubuntu 22.04 again and used the following `boot_command` with success:

```
boot_command = [
      "c",
      "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>"
    ]
```

So this is the `boot_command` to use with the new Ubuntu versions. 
And I also removed the early command from user-data to check if we don't need it anymore.
Also set the timeout to 2h just in case, lets see what happens.

22.04 is way faster installing than the 20.04.5! Getting the ssh authentication failure, gonna try again with the early command to shutdown the ssh service.

Nothing worked, always getting the ssh authentication failure.

Got disappointed so stopped the play here. Went back to Windows, was able to install the Windows 10 Pro iso manually in a VM so we should retry the configuration we were running for virtualbox-iso builder with the Windows ISO, one of the issues I think it was because the VirtualBox folder was being saved on the HDD and was super slow, saving it in the SSD was way fast. Gonna dump the configuration os the VM used here just in case:

(*the configuration is just opening up the .vbox file of the VM that is just an xml file*)

````xml
<?xml version="1.0"?>
<!--
** DO NOT EDIT THIS FILE.
** If you make changes to this file while any VirtualBox related application
** is running, your changes will be overwritten later, without taking effect.
** Use VBoxManage or the VirtualBox Manager GUI to make changes.
-->
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.15-linux">
  <Machine uuid="{855cfe19-0b28-43ad-9871-8ab15cde7435}" name="Win10 Pro" OSType="Windows10_64" snapshotFolder="Snapshots" lastStateChange="2023-02-09T17:21:22Z">
    <MediaRegistry>
      <HardDisks>
        <HardDisk uuid="{15eb91a3-4045-496a-a079-2047fa5dfba4}" location="Win10 Pro.vdi" format="VDI" type="Normal"/>
      </HardDisks>
      <DVDImages>
        <Image uuid="{7197c28b-1a58-47e2-a77c-e6684fafb54e}" location="/media/ee12099/Data/images/Windows 10 X64 22H2 19045.2546 Pro incl ACT en-US LATEST 2023.iso"/>
      </DVDImages>
    </MediaRegistry>
    <ExtraData>
      <ExtraDataItem name="GUI/LastCloseAction" value="PowerOff"/>
      <ExtraDataItem name="GUI/LastNormalWindowPosition" value="519,91,1024,812"/>
    </ExtraData>
    <Hardware>
      <CPU count="2">
        <PAE enabled="true"/>
        <LongMode enabled="true"/>
        <HardwareVirtExLargePages enabled="false"/>
      </CPU>
      <Memory RAMSize="4096"/>
      <Firmware type="EFI"/>
      <HID Pointing="USBTablet"/>
      <Chipset type="ICH9"/>
      <Paravirt provider="Default"/>
      <Display controller="VBoxSVGA" VRAMSize="128"/>
      <RemoteDisplay>
        <VRDEProperties>
          <Property name="TCP/Address" value="127.0.0.1"/>
          <Property name="TCP/Ports" value="5947"/>
        </VRDEProperties>
      </RemoteDisplay>
      <BIOS>
        <IOAPIC enabled="true"/>
        <SmbiosUuidLittleEndian enabled="true"/>
      </BIOS>
      <USB>
        <Controllers>
          <Controller name="XHCI" type="XHCI"/>
        </Controllers>
      </USB>
      <Network>
        <Adapter slot="0" enabled="true" MACAddress="0800274BDD31" cable="true" type="82540EM">
          <DisabledModes>
            <BridgedInterface name="wlp3s0"/>
            <InternalNetwork name="intnet"/>
            <NATNetwork name="NatNetwork"/>
          </DisabledModes>
          <NAT>
            <Forwarding name="packercomm" proto="1" hostip="127.0.0.1" hostport="2835" guestport="5985"/>
          </NAT>
        </Adapter>
        <Adapter slot="8" type="Am79C973"/>
        <Adapter slot="9" type="Am79C973"/>
        <Adapter slot="10" type="Am79C973"/>
        <Adapter slot="11" type="Am79C973"/>
        <Adapter slot="12" type="Am79C973"/>
        <Adapter slot="13" type="Am79C973"/>
        <Adapter slot="14" type="Am79C973"/>
        <Adapter slot="15" type="Am79C973"/>
        <Adapter slot="16" type="Am79C973"/>
        <Adapter slot="17" type="Am79C973"/>
        <Adapter slot="18" type="Am79C973"/>
        <Adapter slot="19" type="Am79C973"/>
        <Adapter slot="20" type="Am79C973"/>
        <Adapter slot="21" type="Am79C973"/>
        <Adapter slot="22" type="Am79C973"/>
        <Adapter slot="23" type="Am79C973"/>
        <Adapter slot="24" type="Am79C973"/>
        <Adapter slot="25" type="Am79C973"/>
        <Adapter slot="26" type="Am79C973"/>
        <Adapter slot="27" type="Am79C973"/>
        <Adapter slot="28" type="Am79C973"/>
        <Adapter slot="29" type="Am79C973"/>
        <Adapter slot="30" type="Am79C973"/>
        <Adapter slot="31" type="Am79C973"/>
        <Adapter slot="32" type="Am79C973"/>
        <Adapter slot="33" type="Am79C973"/>
        <Adapter slot="34" type="Am79C973"/>
        <Adapter slot="35" type="Am79C973"/>
      </Network>
      <AudioAdapter controller="HDA" driver="Pulse" enabled="true" enabledIn="false"/>
      <Clipboard/>
      <GuestProperties>
        <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="en_US" timestamp="1675962223895554000" flags=""/>
      </GuestProperties>
    </Hardware>
    <StorageControllers>
      <StorageController name="SATA" type="AHCI" PortCount="2" useHostIOCache="false" Bootable="true" IDE0MasterEmulationPort="0" IDE0SlaveEmulationPort="1" IDE1MasterEmulationPort="2" IDE1SlaveEmulationPort="3">
        <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
          <Image uuid="{15eb91a3-4045-496a-a079-2047fa5dfba4}"/>
        </AttachedDevice>
        <AttachedDevice passthrough="false" tempeject="true" type="DVD" hotpluggable="false" port="1" device="0">
          <Image uuid="{7197c28b-1a58-47e2-a77c-e6684fafb54e}"/>
        </AttachedDevice>
      </StorageController>
    </StorageControllers>
  </Machine>
</VirtualBox>
````

Also was able to start the MSEdge VM that we found above, it came has a .ova file and imported correctly.
The configuration is the following:

````xml
<?xml version="1.0"?>
<!--
** DO NOT EDIT THIS FILE.
** If you make changes to this file while any VirtualBox related application
** is running, your changes will be overwritten later, without taking effect.
** Use VBoxManage or the VirtualBox Manager GUI to make changes.
-->
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.15-linux">
  <Machine uuid="{4ab2325d-14f6-47af-8b01-b222e251f2cb}" name="MSEdge - Win10" OSType="Windows10_64" snapshotFolder="Snapshots" lastStateChange="2023-02-09T12:33:23Z">
    <MediaRegistry>
      <HardDisks>
        <HardDisk uuid="{8f6dce61-fdac-4f0e-be5e-219cafa83e6f}" location="MSEdge - Win10-disk002.vdi" format="vdi" type="Normal"/>
      </HardDisks>
    </MediaRegistry>
    <ExtraData>
      <ExtraDataItem name="GUI/LastCloseAction" value="PowerOff"/>
      <ExtraDataItem name="GUI/LastGuestSizeHint" value="800,600"/>
      <ExtraDataItem name="GUI/LastNormalWindowPosition" value="959,304,800,644"/>
    </ExtraData>
    <Hardware>
      <CPU count="2">
        <PAE enabled="true"/>
        <LongMode enabled="true"/>
        <HardwareVirtExLargePages enabled="true"/>
      </CPU>
      <Memory RAMSize="4096"/>
      <Firmware type="EFI"/>
      <Chipset type="ICH9"/>
      <Paravirt provider="Default"/>
      <Boot>
        <Order position="1" device="DVD"/>
        <Order position="2" device="HardDisk"/>
        <Order position="3" device="None"/>
        <Order position="4" device="None"/>
      </Boot>
      <Display VRAMSize="128"/>
      <RemoteDisplay>
        <VRDEProperties>
          <Property name="TCP/Address" value="127.0.0.1"/>
          <Property name="TCP/Ports" value="5970"/>
        </VRDEProperties>
      </RemoteDisplay>
      <BIOS>
        <IOAPIC enabled="true"/>
      </BIOS>
      <Network>
        <Adapter slot="0" enabled="true" MACAddress="080027041804" cable="true" type="82540EM">
          <DisabledModes>
            <InternalNetwork name="intnet"/>
            <NATNetwork name="NatNetwork"/>
          </DisabledModes>
          <BridgedInterface name="wlp3s0"/>
        </Adapter>
        <Adapter slot="8" type="Am79C973"/>
        <Adapter slot="9" type="Am79C973"/>
        <Adapter slot="10" type="Am79C973"/>
        <Adapter slot="11" type="Am79C973"/>
        <Adapter slot="12" type="Am79C973"/>
        <Adapter slot="13" type="Am79C973"/>
        <Adapter slot="14" type="Am79C973"/>
        <Adapter slot="15" type="Am79C973"/>
        <Adapter slot="16" type="Am79C973"/>
        <Adapter slot="17" type="Am79C973"/>
        <Adapter slot="18" type="Am79C973"/>
        <Adapter slot="19" type="Am79C973"/>
        <Adapter slot="20" type="Am79C973"/>
        <Adapter slot="21" type="Am79C973"/>
        <Adapter slot="22" type="Am79C973"/>
        <Adapter slot="23" type="Am79C973"/>
        <Adapter slot="24" type="Am79C973"/>
        <Adapter slot="25" type="Am79C973"/>
        <Adapter slot="26" type="Am79C973"/>
        <Adapter slot="27" type="Am79C973"/>
        <Adapter slot="28" type="Am79C973"/>
        <Adapter slot="29" type="Am79C973"/>
        <Adapter slot="30" type="Am79C973"/>
        <Adapter slot="31" type="Am79C973"/>
        <Adapter slot="32" type="Am79C973"/>
        <Adapter slot="33" type="Am79C973"/>
        <Adapter slot="34" type="Am79C973"/>
        <Adapter slot="35" type="Am79C973"/>
      </Network>
      <AudioAdapter driver="Pulse" enabled="true" enabledIn="false" enabledOut="false"/>
      <Clipboard/>
      <GuestProperties>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxControl.exe" value="5.2.8r121009" timestamp="1675944606859665000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxCredProv.dll" value="-" timestamp="1675944606865320000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxDisp.dll" value="-" timestamp="1675944606861004000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxGINA.dll" value="-" timestamp="1675944606865174000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxGuest.sys" value="5.2.8r121009" timestamp="1675944606867976000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxHook.dll" value="5.2.8r121009" timestamp="1675944606860785000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxMRXNP.dll" value="5.2.8r121009" timestamp="1675944606864953000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxMouse.sys" value="5.2.8r121009" timestamp="1675944606868272000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGL.dll" value="-" timestamp="1675944606867110000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLarrayspu.dll" value="-" timestamp="1675944606865828000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLcrutil.dll" value="-" timestamp="1675944606866009000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLerrorspu.dll" value="-" timestamp="1675944606866192000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLfeedbackspu.dll" value="-" timestamp="1675944606866990000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLpackspu.dll" value="-" timestamp="1675944606866751000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxOGLpassthroughspu.dll" value="-" timestamp="1675944606866873000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxSF.sys" value="5.2.8r121009" timestamp="1675944606868545000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxService.exe" value="5.2.8r121009" timestamp="1675944606863304000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxTray.exe" value="5.2.8r121009" timestamp="1675944606863117000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Components/VBoxVideo.sys" value="-" timestamp="1675944606868679000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/HostVerLastChecked" value="5.2.8" timestamp="1524672043041698800" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/InstallDir" value="C:/Program Files/Oracle/VirtualBox Guest Additions" timestamp="1675944606857662000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Revision" value="121009" timestamp="1675944606857509000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Version" value="5.2.8" timestamp="1675944606857329000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/VersionExt" value="5.2.8" timestamp="1675944606857381000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/MAC" value="080027041804" timestamp="1675944606882760000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/Status" value="Up" timestamp="1675944606882660000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Broadcast" value="255.255.255.255" timestamp="1675944606882392000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/IP" value="192.168.1.131" timestamp="1675945978246547000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Netmask" value="255.255.255.0" timestamp="1675944606882528000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/Count" value="1" timestamp="1675945998323021000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/Product" value="Windows 10" timestamp="1675944606856946000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/Release" value="10.0.17134" timestamp="1675944606857041000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/User/IEUser@MSEDGEWIN10/UsageState" value="Idle" timestamp="1675944614578747000" flags=""/>
        <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="en_US" timestamp="1675946003761061000" flags=""/>
      </GuestProperties>
    </Hardware>
    <StorageControllers>
      <StorageController name="IDE Controller" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="true">
        <AttachedDevice passthrough="false" type="DVD" hotpluggable="false" port="1" device="1"/>
      </StorageController>
      <StorageController name="SATA Controller" type="AHCI" PortCount="2" useHostIOCache="false" Bootable="true" IDE0MasterEmulationPort="0" IDE0SlaveEmulationPort="1" IDE1MasterEmulationPort="2" IDE1SlaveEmulationPort="3">
        <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
          <Image uuid="{8f6dce61-fdac-4f0e-be5e-219cafa83e6f}"/>
        </AttachedDevice>
      </StorageController>
    </StorageControllers>
  </Machine>
</VirtualBox>
````

Now we are gonna use the [virtualbox-vm](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/vm) builder that uses a pre-existing VM and check what we can do.

Created a new configuration using the example configuration:

```
source "virtualbox-vm" "basic-example" {
  communicator = "winrm"
  headless = "{{user `headless`}}"
  winrm_username = "vagrant"
  winrm_password = "vagrant"
  winrm_timeout = "2h"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  guest_additions_mode = "disable"
  output_directory = "./builds-vm"
  vm_name = "target-vm"
  attach_snapshot = "Snapshot"
  target_snapshot = "Target-Snapshot"
  force_delete_snapshot = true
  keep_registered = false
  skip_export = false
}

build {
  sources = ["sources.virtualbox-vm.basic-example"]
}
```

We will need to update the username and password, set the `attach_snapshot` to false and update the `vm_name`.

This is using [winrm](https://learn.microsoft.com/en-us/windows/win32/winrm/portal) to communicate, so we must enable that service in our Windows VM first.

According to [How to enable WinRM (Windows Remote Management)](https://www.pdq.com/blog/how-to-enable-winrm-window-remote-management/) to enable WinRM we just need to call `winrm quickconfig` in a PowerShell.

![](assets/images/20230209175746.png)  

But when trying that we got the error:
`WinRM firewall exception will not work since one of the network connection types on this machine is set to Public. Change the network connection type to either Domain or Private and try again`

And the error sums it up we need to change our network from Public to Private. To check you network connection type just call in PowerShell `Get-NetConnectionProfile` and to change it to private call `Set-NetConnectionProfile -NetworkCategory Private`


![](assets/images/20230209180228.png)  


More info on how to setup WinRM - [WinRM+Ansible](https://digitalist.global/article/winrm-ansible/)

Another way to enable winrm is by calling `Enable-PSRemoting` in an elevated PowerShell.

For some reason when rebooting the NetworkCategory is set back to Public. Actually rebooted the Windows VM and it stayed with the settings. So they should persist. Same in the Windows running in one of the Futros through a USB stick.

Now lets try to understand more about this WinRM by using our Ubuntu Host as client and communicate with the Windows machine.

There is this tutorial - [Using WinRM on Linux](https://devblogs.microsoft.com/scripting/using-winrm-on-linux/) - from 2015 that uses a python package [pywinrm](https://github.com/diyan/pywinrm) as the client for WinRM, the guy says:

>Of course, I can’t run PowerShell on Linux. However, there is a module available, written in Python, that wraps WinRM calls and executes them for you.
>
>pywinrm is an open-source module hosted on GitHub. It can easily be installed on your Mac or other Linux system by using this command:
>
>     pip install pywinrm

Back in 2015 you couldn't use PowerShell in Linux but you actually can now! From this article - [Cya Windows. You Can Now Run PowerShell on Linux & macOS](https://www.bleepingcomputer.com/news/microsoft/cya-windows-you-can-now-run-powershell-on-linux-and-macos/) - we can infer that it was about 2018 that this option became available.

There is this example - [Linux: Enable PowerShell Remoting WinRM Client on Ubuntu 20.04](https://kimconnect.com/linux-enable-powershell-remoting-winrm-client-on-ubuntu-20-04/) - thats using powershell in Ubuntu and it also install another package [gss-ntlmssp](https://github.com/gssapi/gss-ntlmssp) that has the following description

>This is a mechglue plugin for the GSSAPI library that implements NTLM authentication.

>So far it has been built and tested only with the libgssapi implementation that comes with MIT Kerberos (Versions 1.11 and above)

And *Kerberos* popped up because in the [Using WinRM on Linux](https://devblogs.microsoft.com/scripting/using-winrm-on-linux/) the guy actually install a package called **kerberos**:

>In Windows, we only need to make sure that WinRM is enabled:
>
>winrm set winrm/config/client/auth @{Basic="true"}
>
>winrm set winrm/config/service/auth @{Basic="true"}
>
>winrm set winrm/config/service @{AllowUnencrypted="true"}
>
>You can also skip the basic authentication if you’re on a domain and want to use Kerberos protocol instead. If that’s the case, you have to also install some Kerberos packages on your Linux machine:
>
>sudo apt-get install python-dev libkrb5-dev
>
>pip install kerberos

If we search about it [Wikipedia](https://en.wikipedia.org/wiki/Kerberos_(protocol)) states:

>Kerberos (/ˈkɜːrbərɒs/) is a computer-network authentication protocol that works on the basis of tickets to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner.

And there is an [MIT page for the project](https://web.mit.edu/kerberos/). So it's basically some type of authentication protocol we can use with WinRM and in the python tutorial you add to install that package while in the PowerShell one you have that Debian package that provides it. At least, this is how I'm reading it.

So lets start by [installing PowerShell on Ubuntu](https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3)

Add the Microsoft Repository for Ubuntu 22.04

````
sudo add-apt-repository https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
````

Run the script provided in the tutorial:

````
# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y powershell
# Start PowerShell
pwsh
````

Ok, so we now have powershell installed on Linux, lets check how we can connect to a WinRM server.

Lets follow the 
There is this example - [Linux: Enable PowerShell Remoting WinRM Client on Ubuntu 20.04](https://kimconnect.com/linux-enable-powershell-remoting-winrm-client-on-ubuntu-20-04/) and start by installing the `gss-ntlmssp` package

    sudo apt install gss-ntlmssp

When trying to call Enter-PSSession go the following error:

````
ee12099@ee12099:~$ pwsh
PowerShell 7.3.2
PS /home/ee12099> Enter-PSSession -ComputerName 192.168.1.86
Enter-PSSession: This parameter set requires WSMan, and no supported WSMan client library was found. WSMan is either not installed or unavailable for this system.
````

After trying to install WS-Man with no success from here - [WSMan remoting is not supported on non-Windows platforms](https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/wsman-unsupported-for-nonwindows?view=powershell-7.3) - we get:

>ince the release of PowerShell 6, support for remoting over WS-Management (WSMan) on non-Windows platforms has only been available to a limited set of Linux distributions. All versions of those distributions that supported WSMan are no longer supported by the Linux vendors that created them.
>
>On non-Windows, WSMan relied on the Open Management Infrastructure (OMI) project, which no longer supports PowerShell remoting. The OMI WSMan client is dependent on OpenSSL 1.0. Most Linux distributions have moved to OpenSSL 2.0, which is not backward-compatible. At this time, there is no supported distribution that has the dependencies needed for the OMI WSMan client to work.

So no luck with PowerShell approach. Gonna try talking from the Windows running in the Fujitsu Futro to the one in the VM and see how this WinRM works.

From the Windows Running in the VM called

    Connect-WSMan -computer 192.168.1.86 -credential $cred -sessionoption $tout

And got the error:

![](assets/images/20230210115434.png)  

After that added the computer we are trying to connect to, 192.168.1.86, to the list of trusted hosts by calling

    Set-Item WSMan:\localhost\Client\TrustedHosts -Force -Concatenate -Value 192.168.1.86

After restarting the service and trying again got a new error `Access is denied.`

![](assets/images/20230210115639.png)  

So lets try also add the VM machine address as a trusted host in the Windows machine we are trying to connect to.

After adding the VM address to the list of trusted hosts and trying to connect again got the same error, but after updating to:

````
Connect-WSMan -computer 192.168.1.86 -credential ee12099
````

it got no error, it opened a dialog for entering the password but nothing happened.

Tried again using the `Enter-PSSession` with success by calling:

    Enter-PSSession -ComputerName 192.168.1.86 -Authentication Negotiate -Credential ee12099

After that we got a PowerShell session on the remote host:

![](assets/images/20230210121209.png)  

And it looks we did not have to add the address of the client computer to the trusted hosts in the server. Removed the trusted hosts from the Futro Windows host and the connection is still possible.

Connecting from the Futro to the VM first failed because we cleared the trusted host entry but after re-adding it it worked.

So we can now go back to Packer and see if we can make it work with the WinRM connection.

When packer starts the VM because we disabled the auto login to the Admin user by setting a password it looks like WinRM server is not available until someone logs in to the VM Windows.. I'm trying to connect using the Windows on the Futro but with no success.

Removed password from admin Account so it will automatically login on boot - [How to Remove Your Windows 10 Password](https://www.howtogeek.com/402283/how-to-remove-your-windows-password/)

Ok, it looks like Packer is changing the VM Network Interface to NAT and thats messing everything, lets try keep it as Bridged Adapter.

So that was one of the issues and the other was that the WinRM (Windows Remote Management) service was set to `Automatic (Delayed Start)` instead of `Automatic`. By changing that the service now start correctly, but now lets see again if it start wihout any user logged in.

Well, we re-added a password to the Admin user so that there is not auto login, rebooted the machine and we're able to connect with WinRM so the automatic startup should work without logging in.

So lets go back to packer, updated the configuration to setup the bridged adapter by adding the `vboxmanage` option.

````
source "virtualbox-vm" "Windows-10-Pro" {
  communicator = "winrm"
  headless = false
  winrm_username = "ee12099"
  winrm_password = "maportofeup2014"
  winrm_timeout = "5m"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  guest_additions_mode = "disable"
  output_directory = "./builds-vm"
  vm_name = "Win10 Pro"
  attach_snapshot = null
  target_snapshot = "Target-Snapshot"
  force_delete_snapshot = true
  keep_registered = false
  skip_export = false

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nic1", "bridged"],
    ["modifyvm", "{{.Name}}", "--bridgeadapter1", "wlp3s0"]
  ]
}
````

So we can connect successfully but packer still hangs with *Waiting for WinRM to become available...* and now that I think of it, we are on a Linux host so maybe this will never work.. Let's try using ssh instead. 

First lets install OpenSSH Server on the VM and configure it to start automatically.

Follow this tutorial to install OpenSSH Server - [Get started with OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell)

Don't forget to set it up to start automatically:

    Set-Service -Name sshd -StartupType 'Automatic'

Rebooted the machine and was able to connect without any user logged in to the service is setup correctly.

Gonna update the Packer configuration to use ssh instead of winrm and see what we can do:

````
source "virtualbox-vm" "Windows-10-Pro" {
  communicator = "ssh"
  headless     = false
  ssh_username          = "ee12099"
  ssh_password          = "maportofeup2014"
  ssh_timeout           = "5m"
  shutdown_command      = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  guest_additions_mode  = "disable"
  output_directory      = "./builds-vm"
  vm_name               = "Win10 Pro"
  attach_snapshot       = null
  target_snapshot       = "Target-Snapshot"
  force_delete_snapshot = true
  keep_registered       = false
  skip_export           = false

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nic1", "bridged"],
    ["modifyvm", "{{.Name}}", "--bridgeadapter1", "wlp3s0"]
  ]
}

build {
  sources = ["sources.virtualbox-vm.Windows-10-Pro"]
}
````

And it still hangs on communication.. It's the same error we always got, we are doing something very stupid I would guess.

Ok, so one thing we didn't do correctly last time was setup the debug logs for Packer.

In the terminal run

    export PACKER_LOG=1
    export PACKER_LOG_PATH=.\packerlog.txt

Ok, so finnaly the logs are working, from checking the log we get:

````
2023/02/10 14:07:30 packer-plugin-virtualbox_v1.0.4_x5.0_linux_amd64 plugin: 2023/02/10 14:07:30 [DEBUG] TCP connection to SSH ip/port failed: dial tcp 192.168.1.133:2339: connect: connection refused
````

So it looks it's trying to connect to port 2339 instead of port 22. Lets try adding the `ssh_port` option value to 22

It did not work it still tries to use another port than 22, besides that we have to provide the machine address in the `ssh_host` if not it would use localhost but this is because we have the adapter set to Bridge, lets try setting it up later to NAT and check if it works without specifying the `ssh_host` option.

We got it! This [stackoverflow post](https://stackoverflow.com/questions/56527682/packer-ssh-communicator-ignores-ssh-port) did the trick:

>This is because of how VirtualBox NAT networks work. From the host you can't reach the guest VM directly. Packer solves this by setting up port forwarding rule. A random port between ssh_host_port_min and ssh_host_port_max is forwarded to the guest VMs ssh_port.
>
>If you want to turn this of set ssh_skip_nat_mapping to true, but then you have to ensure that you have a network setup where Packer can reach the guest.

So adding `ssh_skip_nat_mapping`option with the value set to true worked!
So this config is working!

```
source "virtualbox-vm" "Windows-10-Pro" {
  communicator = "ssh"
  headless     = false
  ssh_username          = "ee12099"
  ssh_password          = "maportofeup2014"
  ssh_timeout           = "5m"
  ssh_host              = "192.168.1.133"
  ssh_skip_nat_mapping      = true
  shutdown_command      = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  guest_additions_mode  = "disable"
  output_directory      = "./builds-vm"
  vm_name               = "Win10 Pro"
  attach_snapshot       = null
  target_snapshot       = "Target-Snapshot"
  force_delete_snapshot = true
  keep_registered       = false
  skip_export           = false

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nic1", "bridged"],
    ["modifyvm", "{{.Name}}", "--bridgeadapter1", "wlp3s0"]
  ]
}

build {
  sources = ["sources.virtualbox-vm.Windows-10-Pro"]
}
````

Let see what we can do with NAT adapter by removing the `vboxmanage` option.

We correctlly connected to SSH using this configuration without Bridged Network Adapter:

````
source "virtualbox-vm" "Windows-10-Pro" {
  communicator = "ssh"
  headless     = false
  ssh_username          = "ee12099"
  ssh_password          = "maportofeup2014"
  ssh_timeout           = "5m"
  shutdown_command      = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  guest_additions_mode  = "disable"
  output_directory      = "./builds-vm"
  vm_name               = "Win10 Pro"
  attach_snapshot       = null
  target_snapshot       = "TargetSnapshot"
  force_delete_snapshot = true
  keep_registered       = false
  skip_export           = false
}

build {
  sources = ["sources.virtualbox-vm.Windows-10-Pro"]
}
````

Not bad, so now we have two options:

- go back to the loose ends we left during this play with Packer 
- try using the golden image created in terraform

______

18 February 2023

Before that, lets go back to trying to connect to Windows VM from Linux using WinRM, we now need this to run the Ansible [windows_config.yml playbook](../ansible/playbooks/windows_config.yml)

Following [How to Connect Ansible on Windows from Ubuntu? ](https://geekflare.com/connecting-windows-ansible-from-ubuntu/) they use the [python3-winrm] package.

    sudo apt install python3-winrm