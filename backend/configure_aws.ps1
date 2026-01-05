# Helper script to run AWS Configure
# Right-click -> Run with PowerShell

Write-Host "Launching AWS Configuration..." -ForegroundColor Cyan
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" configure

Write-Host "Configuration check:"
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" sts get-caller-identity

Pause
