# Recreate key pair in ap-south-1 cleanly
$keyFile = "brick-bhatta-key.pem"
$keyName = "brick-bhatta-key"
$region  = "ap-south-1"

Write-Host "Deleting old key pair from AWS (if exists)..." -ForegroundColor Yellow
aws ec2 delete-key-pair --key-name $keyName --region $region 2>$null

Write-Host "Creating fresh key pair in $region..." -ForegroundColor Cyan
$keyMaterial = aws ec2 create-key-pair `
    --key-name $keyName `
    --query "KeyMaterial" `
    --output text `
    --region $region

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create key pair." -ForegroundColor Red
    exit 1
}

# Remove old read-only file if present
if (Test-Path $keyFile) {
    attrib -R $keyFile 2>$null
    Remove-Item -Force $keyFile
}

# Save new key
[System.IO.File]::WriteAllText("$PSScriptRoot\$keyFile", $keyMaterial + "`n")
Write-Host "Key pair created and saved to $keyFile" -ForegroundColor Green

# Verify it exists in AWS
Write-Host "Verifying key pair in AWS..." -ForegroundColor Cyan
aws ec2 describe-key-pairs --key-names $keyName --region $region --query "KeyPairs[0].KeyName" --output text
Write-Host "All done! Now run:" -ForegroundColor Green
Write-Host "  .\deploy_to_ec2_clean.ps1 -EC2_IP 15.207.111.174" -ForegroundColor Yellow
