## Install packages from Chocolatey

# jq & yq
Write-Output "Installing jq and yq..."
choco install jq --version=1.8.1
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
choco install yq --version=4.50.1
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# AWS CLI
Write-Output "Installing AWS CLI..."
choco install awscli --version=2.32.34
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Git
Write-Host '>>> Installing Git...'
choco install git --version=2.52.0
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Gzip
Write-Host '>>> Installing gzip...'
choco install gzip
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# CMake
Write-Host '>>> Installing CMake...'
choco install cmake --version 4.2.1 --installargs "ADD_CMAKE_TO_PATH=System"
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Notepad++
Write-Host '>>> Installing Notepad++...'
choco install notepadplusplus
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Miniforge3
Write-Host '>>> Installing Miniforge3...'
choco install miniforge3 --params="'/InstallationType:AllUsers /RegisterPython:1 /D:C:\tools\miniforge3'"
C:\tools\miniforge3\Scripts\conda.exe init --user --system
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
. "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
conda config --set auto_activate_base false
conda install -n base 'pip>=23' 'wheel>=0.42' pydistcheck
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Java 11
Write-Host '>>> Installing Java 11...'
choco install openjdk11
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Maven
Write-Host '>>> Installing Maven...'
choco install maven
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# GraphViz
Write-Host '>>> Installing GraphViz...'
choco install graphviz
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# Visual Studio 2022 Community
Write-Host '>>> Installing Visual Studio 2022 Community...'
choco install visualstudio2022community `
    --params "--wait --passive --norestart"
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
choco install visualstudio2022-workload-nativedesktop --params `
    "--wait --passive --norestart --includeOptional"
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# CUDA 12.5
Write-Host '>>> Installing CUDA 12.9...'
choco install cuda --version=12.9.1.576
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }

# R 4.3
Write-Host '>>> Installing R...'
choco install r.project --version=4.5.2
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
choco install rtools --version=4.5.6691
if ($LASTEXITCODE -ne 0) { throw "Last command failed" }
