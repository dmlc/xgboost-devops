$ErrorActionPreference = "Stop"

Write-Host ">>> Verifying NVIDIA driver and GPU..."
nvidia-smi.exe
if ($LASTEXITCODE -ne 0) {
    throw "nvidia-smi.exe failed with exit code $LASTEXITCODE"
}
