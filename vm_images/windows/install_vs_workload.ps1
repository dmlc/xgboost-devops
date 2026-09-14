$ErrorActionPreference = "Stop"

Write-Host '>>> Installing the Visual Studio native desktop workload...'
choco install visualstudio2022-workload-nativedesktop `
    --package-parameters "--wait --quiet --norestart --includeOptional"

$exitCode = $LASTEXITCODE
$validExitCodes = @(0, 1641, 3010)
if ($exitCode -notin $validExitCodes) {
    throw "Failed to install the Visual Studio native desktop workload (exit code $exitCode)"
}

if ($exitCode -ne 0) {
    Write-Host "The Visual Studio workload installed successfully and requested a restart (exit code $exitCode)."
}

# Packer performs the required restart in the next provisioner.
exit 0
