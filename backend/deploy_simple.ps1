# PowerShell script to deploy backend code to AWS EC2
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
        throw "SSH key file not found: $KEY_FILE"
    }

    # 2. Create deployment package
    Write-Host "Creating deployment package..." -ForegroundColor Green
    $TEMP_DIR = "deploy_temp"
    
    if (Test-Path $TEMP_DIR) {
        Remove-Item -Recurse -Force $TEMP_DIR
    }
    
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    
    # Copy necessary files
    Copy-Item -Path "app" -Destination "$TEMP_DIR/app" -Recurse
    Copy-Item -Path "Dockerfile" -Destination "$TEMP_DIR/"
    Copy-Item -Path "docker-compose.yml" -Destination "$TEMP_DIR/"
    Copy-Item -Path "requirements.txt" -Destination "$TEMP_DIR/"
    
    # Copy Firebase credentials if exists
    if (Test-Path "firebase-key.json") {
        Copy-Item -Path "firebase-key.json" -Destination "$TEMP_DIR/"
        Write-Host "Firebase credentials included" -ForegroundColor Green
    } else {
        Write-Host "WARNING: firebase-key.json not found!" -ForegroundColor Yellow
    }

    # 3. Transfer files to EC2
    Write-Host "Transferring files to EC2..." -ForegroundColor Green
    
    # Create remote directory
    ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$EC2_IP "mkdir -p ~/brick-bhatta-backend"
    
    # Copy files using SCP
    scp -i $KEY_FILE -r -o StrictHostKeyChecking=no "$TEMP_DIR/*" ubuntu@${EC2_IP}:~/brick-bhatta-backend/
    
    Write-Host "Files transferred successfully" -ForegroundColor Green

    # 4. Deploy on EC2
    Write-Host "Building and starting Docker containers..." -ForegroundColor Green
    
    ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$EC2_IP 'cd ~/brick-bhatta-backend && echo "Setting up permissions..." && chmod 600 firebase-key.json 2>/dev/null || true && echo "Stopping existing containers..." && docker-compose down 2>/dev/null || true && echo "Building Docker images..." && docker-compose build && echo "Starting services..." && docker-compose up -d && echo "Waiting for services to start..." && sleep 10 && echo "Checking service health..." && docker-compose ps && curl -f http://localhost:8000/health || echo "Health check failed"'

    # 5. Cleanup
    Write-Host "Cleaning up temporary files..." -ForegroundColor Green
    Remove-Item -Recurse -Force $TEMP_DIR

    # 6. Test deployment
    Write-Host ""
    Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend is now running at:" -ForegroundColor Cyan
    Write-Host "   http://$EC2_IP:8000" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Testing health endpoint..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "http://${EC2_IP}:8000/health" -TimeoutSec 10
        Write-Host "Health check passed: $($response.message)" -ForegroundColor Green
    } catch {
        Write-Host "Health check failed. The service might still be starting up." -ForegroundColor Yellow
        Write-Host "Try again in a minute: curl http://$EC2_IP:8000/health" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Update your Flutter app's api_config.dart with: http://$EC2_IP:8000" -ForegroundColor White
    Write-Host "2. Or build with: flutter build apk --dart-define=BASE_URL=http://$EC2_IP:8000" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "DEPLOYMENT FAILED!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    exit 1
}
