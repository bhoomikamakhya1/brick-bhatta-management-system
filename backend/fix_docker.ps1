# Fix Docker/WSL Issues Script
# RIGHT CLICK -> RUN WITH POWERSHELL

Write-Host "Setting up Windows Features for Docker..." -ForegroundColor Cyan

# 1. Enable Virtual Machine Platform
Write-Host "Enabling Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. Enable Windows Subsystem for Linux
Write-Host "Enabling Windows Subsystem for Linux..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 3. Ensure Hypervisor is set to auto launch
Write-Host "Setting Hypervisor launch type..."
bcdedit /set hypervisorlaunchtype auto

# 4. Update WSL
Write-Host "Updating WSL..."
wsl --update

Write-Host "---------------------------------------------------"
Write-Host "DONE! Please RESTART your computer now." -ForegroundColor Green
Write-Host "After restart, open Docker Desktop again."
Write-Host "---------------------------------------------------"
Pause
