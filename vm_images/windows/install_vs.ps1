$ErrorActionPreference = "Stop"

$validExitCodes = @(0, 1641, 3010)

function Install-ChocolateyPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [string[]]$PackageArguments = @()
    )

    choco install $PackageName @PackageArguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -notin $validExitCodes) {
        throw "Failed to install $PackageName (exit code $exitCode)"
    }

    if ($exitCode -ne 0) {
        Write-Host "$PackageName installed successfully and requested a restart (exit code $exitCode)."
    }
}

# Install this workload dependency before the controlled restart.
Write-Host '>>> Installing Visual C++ Redistributable...'
Install-ChocolateyPackage -PackageName "vcredist140"

Write-Host '>>> Installing Visual Studio 2022 Community...'
Install-ChocolateyPackage `
    -PackageName "visualstudio2022community" `
    -PackageArguments @(
        "--package-parameters",
        "--wait --quiet --norestart"
    )

# Packer performs the required restart in the next provisioner.
exit 0
