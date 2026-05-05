# PowerShell script to deploy backend code to AWS EC2
# Usage: .\deploy_to_ec2_clean.ps1 -EC2_IP "YOUR_EC2_PUBLIC_IP"

param(
    [Parameter(Mandatory=$true)]
    [string]$EC2_IP,
    
    [Parameter(Mandatory=$false)]
    [string]$KEY_FILE = "brick-bhatta-key.pem"
)

$ErrorActionPreference = "Stop"

try {
    Write-Host "Deploying Backend to AWS EC2..." -ForegroundColor Cyan
    Write-Host "Target: ubuntu@$EC2_IP" -ForegroundColor Yellow
    Write-Host ""

    # 1. Verify key file exists
    if (-not (Test-Path $KEY_FILE)) {
        throw "SSH key file not found: $KEY_FILE. Run create_key.ps1 first."
    }

    # 2. Create deployment package
    Write-Host "Creating deployment package..." -ForegroundColor Green
    $TEMP_DIR = "deploy_temp"
    
    if (Test-Path $TEMP_DIR) {
        Remove-Item -Recurse -Force $TEMP_DIR
    }
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    
    Copy-Item -Path "app" -Destination "$TEMP_DIR\app" -Recurse
    Copy-Item -Path "Dockerfile"        -Destination "$TEMP_DIR\"
    Copy-Item -Path "docker-compose.yml" -Destination "$TEMP_DIR\"
    Copy-Item -Path "requirements.txt"  -Destination "$TEMP_DIR\"
    
    if (Test-Path "firebase-key.json") {
        Copy-Item -Path "firebase-key.json" -Destination "$TEMP_DIR\"
        Write-Host "Firebase credentials included" -ForegroundColor Green
    } else {
        Write-Host "WARNING: firebase-key.json not found!" -ForegroundColor Yellow
    }

    # 3. Transfer files to EC2 via SCP
    #    Note: use explicit variable for the remote path to avoid PS colon parsing issue
    Write-Host "Transferring files to EC2..." -ForegroundColor Green
    $REMOTE_DIR = "ubuntu@${EC2_IP}:~/brick-bhatta-backend"
    
    ssh -i $KEY_FILE -o StrictHostKeyChecking=no "ubuntu@$EC2_IP" "mkdir -p ~/brick-bhatta-backend"
    scp -i $KEY_FILE -r -o StrictHostKeyChecking=no "$TEMP_DIR/app"               $REMOTE_DIR/
    scp -i $KEY_FILE    -o StrictHostKeyChecking=no "$TEMP_DIR/Dockerfile"         $REMOTE_DIR/
    scp -i $KEY_FILE    -o StrictHostKeyChecking=no "$TEMP_DIR/docker-compose.yml" $REMOTE_DIR/
    scp -i $KEY_FILE    -o StrictHostKeyChecking=no "$TEMP_DIR/requirements.txt"   $REMOTE_DIR/
    if (Test-Path "$TEMP_DIR\firebase-key.json") {
        scp -i $KEY_FILE -o StrictHostKeyChecking=no "$TEMP_DIR/firebase-key.json" $REMOTE_DIR/
    }
    
    Write-Host "Files transferred successfully" -ForegroundColor Green

    # 4. Deploy on EC2
    Write-Host "Building and starting Docker containers..." -ForegroundColor Green
    
    # Write remote commands to a temp shell script to avoid PS string issues
    $REMOTE_SCRIPT = @'
set -e
cd ~/brick-bhatta-backend
echo "Setting permissions..."
chmod 600 firebase-key.json 2>/dev/null || true
echo "Stopping existing containers..."
docker-compose down 2>/dev/null || true
echo "Building Docker images..."
docker-compose build
echo "Starting services..."
docker-compose up -d
echo "Waiting for startup..."
sleep 10
echo "Container status:"
docker-compose ps
echo "Health check:"
curl -f http://localhost:8000/health || echo "Health check failed - service may still be starting"
'@
    
    $REMOTE_SCRIPT | ssh -i $KEY_FILE -o StrictHostKeyChecking=no "ubuntu@$EC2_IP" "bash -s"

    # 5. Cleanup
    Write-Host "Cleaning up temp files..." -ForegroundColor Green
    Remove-Item -Recurse -Force $TEMP_DIR

    # 6. Done
    Write-Host ""
    Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Backend running at: http://${EC2_IP}:8000" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Update api_config.dart line 18:" -ForegroundColor White
    Write-Host "     defaultValue: `"http://${EC2_IP}:8000`"" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  2. Rebuild Flutter app:" -ForegroundColor White
    Write-Host "     flutter build apk --release" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  3. View logs:" -ForegroundColor White
    Write-Host "     ssh -i $KEY_FILE ubuntu@$EC2_IP" -ForegroundColor Yellow
    Write-Host "     cd ~/brick-bhatta-backend && docker-compose logs -f" -ForegroundColor Yellow

} catch {
    Write-Host ""
    Write-Host "DEPLOYMENT FAILED!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    exit 1
} finally {
    Write-Host "--------------------------------------"
}
