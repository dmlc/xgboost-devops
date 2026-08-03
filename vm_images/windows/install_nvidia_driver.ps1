# Modified from:
# https://raw.githubusercontent.com/aws-solutions/edit-in-the-cloud-on-aws/main/source/install-gpu-drivers.ps1
$ErrorActionPreference = "Stop"

# NVIDIA GRID 20.1 for Windows Server 2022. Pin the S3 object instead of using
# "latest" so that AMI builds remain reproducible.
$driverUri = "s3://ec2-windows-nvidia-drivers/grid-20.1/596.36_grid_win10_win11_server2022_64bit_dch_international_aws_swl.exe"
$workDir = Join-Path $env:TEMP "nvidia-driver"
$installer = Join-Path $workDir "nvidia-grid.exe"
$extractDir = Join-Path $workDir "extracted"
$logDir = Join-Path $env:TEMP "nvidia-driver-logs"

New-Item -ItemType Directory -Force -Path $extractDir, $logDir | Out-Null

Write-Host ">>> Downloading NVIDIA GRID driver..."
aws s3 cp $driverUri $installer --no-sign-request
if ($LASTEXITCODE -ne 0) {
    throw "Failed to download NVIDIA GRID driver"
}

$signature = Get-AuthenticodeSignature -FilePath $installer
if (
    $signature.Status -ne "Valid" -or
    $signature.SignerCertificate.Subject -notmatch "NVIDIA"
) {
    throw "NVIDIA GRID driver has an invalid Authenticode signature"
}

# The downloaded executable is a self-extracting archive. Extract it first so
# that the documented setup.exe options are applied to the driver installer.
$sevenZip = Join-Path $env:ChocolateyInstall "tools\7z.exe"
if (-not (Test-Path $sevenZip)) {
    throw "Chocolatey's bundled 7z.exe was not found at $sevenZip"
}

Write-Host ">>> Extracting NVIDIA GRID driver..."
& $sevenZip x $installer -aoa "-o$extractDir"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to extract NVIDIA GRID driver"
}

$setup = Join-Path $extractDir "setup.exe"
if (-not (Test-Path $setup)) {
    throw "NVIDIA setup.exe was not found after extraction"
}

Write-Host ">>> Installing NVIDIA display driver..."
$process = Start-Process `
    -FilePath $setup `
    -ArgumentList @(
        "-s",
        "-n",
        "Display.Driver",
        "-log:$logDir",
        "-loglevel:6"
    ) `
    -Wait `
    -PassThru

# NVIDIA documents 0 as success and 1 as success with reboot required.
if ($process.ExitCode -notin @(0, 1)) {
    throw "NVIDIA driver installation failed with exit code $($process.ExitCode)"
}

Write-Host "NVIDIA driver installation completed with exit code $($process.ExitCode)"
Remove-Item -Recurse -Force $workDir
