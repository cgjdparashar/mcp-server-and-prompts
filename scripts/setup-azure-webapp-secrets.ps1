# Setup Azure Web App Secrets for GitHub Actions
# This script helps configure Azure credentials and settings for CI/CD deployment

Write-Host "🔐 Azure Web App Secrets Setup for GitHub Actions" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
$azVersion = az version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure CLI is not installed!" -ForegroundColor Red
    Write-Host "Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Azure CLI detected" -ForegroundColor Green
Write-Host ""

# Login to Azure
Write-Host "🔑 Logging in to Azure..." -ForegroundColor Cyan
az login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure login failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Successfully logged in to Azure" -ForegroundColor Green
Write-Host ""

# Get subscription
$subscription = az account show --query id -o tsv
$subscriptionName = az account show --query name -o tsv

Write-Host "📋 Current Subscription:" -ForegroundColor Cyan
Write-Host "   Name: $subscriptionName" -ForegroundColor White
Write-Host "   ID: $subscription" -ForegroundColor White
Write-Host ""

$confirmSub = Read-Host "Use this subscription? (Y/n)"
if ($confirmSub -eq 'n' -or $confirmSub -eq 'N') {
    Write-Host "Please run 'az account set --subscription <subscription-id>' to change subscription" -ForegroundColor Yellow
    exit 0
}

# Collect required information
Write-Host "📝 Please provide the following information:" -ForegroundColor Cyan
Write-Host ""

$githubRepo = Read-Host "GitHub Repository (format: owner/repo)"
if ([string]::IsNullOrWhiteSpace($githubRepo) -or $githubRepo -notmatch '^[\w-]+/[\w-]+$') {
    Write-Host "❌ Invalid repository format. Expected: owner/repo" -ForegroundColor Red
    exit 1
}

$resourceGroup = Read-Host "Azure Resource Group name (will be created if doesn't exist)"
if ([string]::IsNullOrWhiteSpace($resourceGroup)) {
    Write-Host "❌ Resource Group name is required" -ForegroundColor Red
    exit 1
}

$webappName = Read-Host "Web App name (must be globally unique)"
if ([string]::IsNullOrWhiteSpace($webappName)) {
    Write-Host "❌ Web App name is required" -ForegroundColor Red
    exit 1
}

$location = Read-Host "Azure Location (default: eastus)"
if ([string]::IsNullOrWhiteSpace($location)) {
    $location = "eastus"
}

$sku = Read-Host "App Service SKU (default: F1 - Free tier)"
if ([string]::IsNullOrWhiteSpace($sku)) {
    $sku = "F1"
}

Write-Host ""
Write-Host "📊 Configuration Summary:" -ForegroundColor Cyan
Write-Host "   GitHub Repo: $githubRepo" -ForegroundColor White
Write-Host "   Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "   Web App Name: $webappName" -ForegroundColor White
Write-Host "   Location: $location" -ForegroundColor White
Write-Host "   SKU: $sku" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Proceed with setup? (Y/n)"
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-Host "Setup cancelled" -ForegroundColor Yellow
    exit 0
}

# Create Service Principal for GitHub Actions
Write-Host ""
Write-Host "🔐 Creating Service Principal for GitHub Actions..." -ForegroundColor Cyan

$spName = "sp-github-$webappName"
$sp = az ad sp create-for-rbac --name $spName --role contributor --scopes /subscriptions/$subscription/resourceGroups/$resourceGroup --sdk-auth 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Service principal already exists or creation failed. Attempting to use existing..." -ForegroundColor Yellow
    $sp = az ad sp list --display-name $spName --query "[0]" 2>&1
}

Write-Host "✅ Service Principal configured" -ForegroundColor Green

# Output GitHub Secrets
Write-Host ""
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host ("=" * 78) -ForegroundColor Cyan
Write-Host "🔑 GitHub Secrets Configuration" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host ("=" * 78) -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these secrets to your GitHub repository:" -ForegroundColor White
Write-Host "Repository → Settings → Secrets and variables → Actions → New repository secret" -ForegroundColor Gray
Write-Host ""

Write-Host "1️⃣  AZURE_CREDENTIALS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $sp -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  AZURE_RESOURCE_GROUP" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $resourceGroup -ForegroundColor White
Write-Host ""

Write-Host "3️⃣  AZURE_WEBAPP_NAME" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $webappName -ForegroundColor White
Write-Host ""

Write-Host "4️⃣  AZURE_LOCATION (optional)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $location -ForegroundColor White
Write-Host ""

Write-Host "5️⃣  AZURE_SKU (optional)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $sku -ForegroundColor White
Write-Host ""

Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host ("=" * 78) -ForegroundColor Cyan
Write-Host ""

# Save to file
$outputFile = "azure-secrets-$webappName.txt"
@"
GitHub Secrets for $githubRepo
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

AZURE_CREDENTIALS:
$sp

AZURE_RESOURCE_GROUP:
$resourceGroup

AZURE_WEBAPP_NAME:
$webappName

AZURE_LOCATION:
$location

AZURE_SKU:
$sku

Deployment URL (after first deployment):
https://$webappName.azurewebsites.net
"@ | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "💾 Secrets saved to: $outputFile" -ForegroundColor Green
Write-Host ""

# Instructions
Write-Host "📖 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to https://github.com/$githubRepo/settings/secrets/actions" -ForegroundColor White
Write-Host "2. Click 'New repository secret' for each secret above" -ForegroundColor White
Write-Host "3. Copy the values from above or from $outputFile" -ForegroundColor White
Write-Host "4. Commit and push your code to trigger the CI/CD pipeline" -ForegroundColor White
Write-Host "5. Monitor deployment at https://github.com/$githubRepo/actions" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Your app will be available at:" -ForegroundColor Cyan
Write-Host "   https://$webappName.azurewebsites.net" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ Setup complete!" -ForegroundColor Green

# Prompt to open GitHub
$openGithub = Read-Host "Open GitHub secrets page in browser? (Y/n)"
if ($openGithub -ne 'n' -and $openGithub -ne 'N') {
    Start-Process "https://github.com/$githubRepo/settings/secrets/actions"
}
