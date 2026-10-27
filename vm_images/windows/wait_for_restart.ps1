$ErrorActionPreference = "Stop"

$statePath = Join-Path $env:SystemRoot "Temp\packer-restart.json"
$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
if (-not $state.BootTimeTicks -or -not $state.DeadlineTicks) {
    throw "Invalid Windows restart state in $statePath"
}

Write-Host ">>> Waiting for Windows boot time to change..."
while ([DateTime]::UtcNow.Ticks -lt [long]$state.DeadlineTicks) {
    try {
        $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem -OperationTimeoutSec 10).LastBootUpTime
        if ($bootTime.ToUniversalTime().Ticks -ne [long]$state.BootTimeTicks) {
            Remove-Item -LiteralPath $statePath
            Write-Host "Verified Windows restart; current boot time is $($bootTime.ToString('o'))"
            exit 0
        }
    } catch {
        # CIM may be temporarily unavailable while Windows is starting.
        Write-Warning "Waiting for Windows startup: $_"
    }

    # If this is still the old boot, the reboot will disconnect this command.
    # Packer retries this verification after SSH becomes available again.
    Start-Sleep -Seconds 5
}

throw "Windows boot time did not change before the 15-minute restart deadline"
