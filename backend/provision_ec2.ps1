$ErrorActionPreference = "Stop"

try {
    $AWS_PATH = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
    $SG_NAME = "brick-bhatta-sg"
    $INSTANCE_TYPE = "t2.micro"

    Write-Host "🚀 Starting AWS Deployment..." -ForegroundColor Cyan

    # 0. Check AWS CLI
    if (-not (Test-Path $AWS_PATH)) {
        throw "AWS CLI not found at $AWS_PATH"
    }

    # 1. Check AWS identity
    Write-Host "Checking AWS identity..."
    & $AWS_PATH sts get-caller-identity | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "AWS credentials not configured"
    }

    # 2. Key pair
    $KEY_NAME = Read-Host "Enter key pair name (default: brick-bhatta-key)"
    if ([string]::IsNullOrWhiteSpace($KEY_NAME)) {
        $KEY_NAME = "brick-bhatta-key"
    }

    if (-not (Test-Path "$KEY_NAME.pem")) {
        Write-Host "Creating key pair $KEY_NAME..."
        & $AWS_PATH ec2 create-key-pair `
            --key-name $KEY_NAME `
            --query "KeyMaterial" `
            --output text > "$KEY_NAME.pem"
    }

    # 3. VPC + SG
    $vpc_id = & $AWS_PATH ec2 describe-vpcs `
        --filters "Name=isDefault,Values=true" `
        --query "Vpcs[0].VpcId" `
        --output text

    $sg_id = & $AWS_PATH ec2 describe-security-groups `
        --filters "Name=group-name,Values=$SG_NAME" `
        --query "SecurityGroups[0].GroupId" `
        --output text

    if ($sg_id -eq "None") {
        Write-Host "Creating security group..."
        $sg_id = & $AWS_PATH ec2 create-security-group `
            --group-name $SG_NAME `
            --description "Brick Bhatta Backend" `
            --vpc-id $vpc_id `
            --query "GroupId" `
            --output text

        & $AWS_PATH ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0
        & $AWS_PATH ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 8000 --cidr 0.0.0.0/0
    }

    # 4. AMI
    $ami_id = & $AWS_PATH ec2 describe-images `
        --owners 099720109477 `
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" `
        --query "sort_by(Images, &CreationDate)[-1].ImageId" `
        --output text

    # 5. User data (NO PowerShell interpolation)
$userData = @'
#!/bin/bash
set -e
apt-get update -y
apt-get install -y docker.io docker-compose
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
'@

    Set-Content -Encoding ASCII user_data.sh $userData

    # 6. Launch EC2
    Write-Host "Launching EC2..."
    $instance_id = & $AWS_PATH ec2 run-instances `
        --image-id $ami_id `
        --instance-type $INSTANCE_TYPE `
        --key-name $KEY_NAME `
        --security-group-ids $sg_id `
        --user-data file://user_data.sh `
        --query "Instances[0].InstanceId" `
        --output text

    & $AWS_PATH ec2 wait instance-running --instance-ids $instance_id

    $ip = & $AWS_PATH ec2 describe-instances `
        --instance-ids $instance_id `
        --query "Reservations[0].Instances[0].PublicIpAddress" `
        --output text

    Write-Host "✅ EC2 READY: $ip" -ForegroundColor Green
    Write-Host "SSH:"
    Write-Host "ssh -i $KEY_NAME.pem ubuntu@$ip"

}
catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
finally {
    Write-Host "--------------------------------------"
    Read-Host "Press Enter to exit"
}
