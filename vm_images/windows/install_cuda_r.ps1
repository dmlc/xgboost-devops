$ErrorActionPreference = "Stop"

# CUDA 13.3
Write-Host '>>> Installing CUDA 13.3...'
choco install cuda --version=13.3.0
if ($LASTEXITCODE -ne 0) { throw "Failed to install CUDA" }

# R 4.5
Write-Host '>>> Installing R...'
choco install r.project --version=4.5.3
if ($LASTEXITCODE -ne 0) { throw "Failed to install R" }
choco install rtools --version=4.5.6768
if ($LASTEXITCODE -ne 0) { throw "Failed to install Rtools" }
