$ErrorActionPreference = "Stop"

$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    throw "vswhere.exe was not found at $vswhere"
}

$installationPath = & $vswhere `
    -latest `
    -products '*' `
    -requires Microsoft.VisualStudio.Workload.NativeDesktop `
    -property installationPath
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($installationPath)) {
    throw "Visual Studio native desktop workload verification failed"
}

$displayVersion = & $vswhere `
    -latest `
    -products '*' `
    -property catalog_productDisplayVersion
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($displayVersion)) {
    throw "Unable to determine the installed Visual Studio version"
}

Write-Host "Verified Visual Studio $displayVersion with the native desktop workload at $installationPath"
