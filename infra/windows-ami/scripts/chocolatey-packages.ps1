Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Installing Guest Additions..."
choco install virtualbox-guest-additions-guest.install  -y

Write-Host "Installing Prometheus Exporter..."
choco install prometheus-windows-exporter.install --params '"/EnabledCollectors:cpu,dns,memory,os"' -y