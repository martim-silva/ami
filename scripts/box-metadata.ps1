param (
    [string]$BoxFile,
    [string]$BoxName,
    [string]$BoxVersion,
    [string]$Provider,
    [string]$RegistryRoot,
    [string]$BoxUrlBase
)

$destFolder = Join-Path -Path $RegistryRoot -ChildPath "$BoxName\$BoxVersion"
New-Item -ItemType Directory -Force -Path $destFolder | Out-Null

$destBoxPath = Join-Path -Path $destFolder -ChildPath "$Provider.box"

Write-Host "Copying $BoxFile to $destBoxPath..."
Copy-Item -Path $BoxFile -Destination $destBoxPath -Force -Verbose

$metadataPath = Join-Path -Path $RegistryRoot -ChildPath "$BoxName\metadata.json"

$metadata = @{
    name = "local/$BoxName"
    versions = @(
        @{
            version = $BoxVersion
            providers = @(
                @{
                    name = $Provider
                    url = "$BoxUrlBase/$BoxName/$BoxVersion/$Provider.box"
                }
            )
        }
    )
}

$metadata | ConvertTo-Json -Depth 5 | Set-Content -Path $metadataPath -Encoding UTF8
Write-Host "Metadata URL: $BoxUrlBase/$BoxName/metadata.json"

Write-Host "Box published to $destFolder"
