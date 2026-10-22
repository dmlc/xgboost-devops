$ErrorActionPreference = "Stop"

# Persist the boot time and deadline across the SSH disconnect caused by reboot.
$statePath = Join-Path $env:SystemRoot "Temp\packer-restart.json"
$bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
@{
    BootTimeTicks = $bootTime.ToUniversalTime().Ticks
    DeadlineTicks = [DateTime]::UtcNow.AddMinutes(15).Ticks
} | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding ASCII

# Give this provisioner time to return before Windows closes the SSH connection.
Write-Host ">>> Requesting Windows restart..."
& "$env:SystemRoot\System32\shutdown.exe" /r /f /t 10 /c "packer restart"
$exitCode = $LASTEXITCODE
if ($exitCode -notin @(0, 1115, 1190)) {
    throw "Failed to request Windows restart (exit code $exitCode)"
}

exit 0
