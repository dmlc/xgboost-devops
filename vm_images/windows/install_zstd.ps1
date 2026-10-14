# Install zstd in the AMI so the Windows cache action can use it without
# downloading the utility on every CI job.
$ErrorActionPreference = "Stop"
$Version = "1.5.7"
$ArchiveDirectory = "zstd-v$Version-win64"
$Archive = Join-Path $env:TEMP "$ArchiveDirectory.zip"
$DownloadUrl = "https://github.com/facebook/zstd/releases/download/v$Version/$ArchiveDirectory.zip"
$ExtractDirectory = Join-Path $env:TEMP $ArchiveDirectory
$InstallDirectory = "C:\tools\zstd"

Invoke-WebRequest -Uri $DownloadUrl -OutFile $Archive
Expand-Archive -Path $Archive -DestinationPath $env:TEMP -Force
New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null
Copy-Item -Path (Join-Path $ExtractDirectory "zstd.exe") `
  -Destination (Join-Path $InstallDirectory "zstd.exe") -Force

$MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$PathEntries = $MachinePath -split ';' | ForEach-Object { $_.TrimEnd('\') }
if ($PathEntries -notcontains $InstallDirectory) {
  [Environment]::SetEnvironmentVariable("Path", "$MachinePath;$InstallDirectory", "Machine")
}
$env:Path = "$InstallDirectory;$env:Path"

& (Join-Path $InstallDirectory "zstd.exe") --version
if ($LASTEXITCODE -ne 0) { throw "Zstandard installation failed" }

Remove-Item $Archive, $ExtractDirectory -Recurse -Force
