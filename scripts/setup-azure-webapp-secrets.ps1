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

# Create Resource Group first (if it doesn't exist)
Write-Host ""
Write-Host "📦 Creating Resource Group (if needed)..." -ForegroundColor Cyan
az group create --name $resourceGroup --location $location --output none 2>&1
Write-Host "✅ Resource Group ready" -ForegroundColor Green

# Create Service Principal for GitHub Actions
Write-Host ""
Write-Host "🔐 Creating Service Principal for GitHub Actions..." -ForegroundColor Cyan

$spName = "sp-github-$webappName"

# Check if SP already exists and delete it to create fresh credentials
$existingSp = az ad sp list --display-name $spName --query "[0].appId" -o tsv 2>$null
if ($existingSp) {
    Write-Host "⚠️  Deleting existing Service Principal to create fresh credentials..." -ForegroundColor Yellow
    az ad sp delete --id $existingSp 2>$null
}

# Create new Service Principal with proper JSON format
Write-Host "Creating new Service Principal..." -ForegroundColor Cyan

# Try with --sdk-auth first (older Azure CLI versions)
$spJson = az ad sp create-for-rbac `
    --name $spName `
    --role contributor `
    --scopes /subscriptions/$subscription/resourceGroups/$resourceGroup `
    --sdk-auth 2>&1

# Check if --sdk-auth failed (newer Azure CLI versions)
if ($LASTEXITCODE -ne 0 -or $spJson -like "*--sdk-auth*deprecated*" -or $spJson -like "*unrecognized arguments*") {
    Write-Host "⚠️  --sdk-auth flag not supported, using standard format..." -ForegroundColor Yellow
    
    # Create without --sdk-auth and manually format the JSON
    $spOutput = az ad sp create-for-rbac `
        --name $spName `
        --role contributor `
        --scopes /subscriptions/$subscription/resourceGroups/$resourceGroup `
        --output json 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create Service Principal!" -ForegroundColor Red
        Write-Host "Output: $spOutput" -ForegroundColor Yellow
        Write-Host "Please check your Azure permissions and try again." -ForegroundColor Yellow
        exit 1
    }
    
    # Parse the output and create the required format
    try {
        $sp = $spOutput | ConvertFrom-Json
        
        # Create the JSON format required by azure/login action
        $spJson = @{
            clientId = $sp.appId
            clientSecret = $sp.password
            subscriptionId = $subscription
            tenantId = $sp.tenant
        } | ConvertTo-Json -Compress
        
        Write-Host "✅ Service Principal created successfully" -ForegroundColor Green
        Write-Host "   Client ID: $($sp.appId)" -ForegroundColor Gray
        Write-Host "   Tenant ID: $($sp.tenant)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to parse Service Principal output!" -ForegroundColor Red
        Write-Host "Output: $spOutput" -ForegroundColor Yellow
        exit 1
    }
} else {
    # --sdk-auth worked, validate the JSON
    try {
        $spObject = $spJson | ConvertFrom-Json
        
        # Validate all required fields are present
        if (-not $spObject.clientId -or -not $spObject.clientSecret -or -not $spObject.subscriptionId -or -not $spObject.tenantId) {
            throw "Missing required fields in Service Principal JSON"
        }
        
        Write-Host "✅ Service Principal created successfully" -ForegroundColor Green
        Write-Host "   Client ID: $($spObject.clientId)" -ForegroundColor Gray
        Write-Host "   Tenant ID: $($spObject.tenantId)" -ForegroundColor Gray
        Write-Host "   Subscription ID: $($spObject.subscriptionId)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Invalid Service Principal JSON!" -ForegroundColor Red
        Write-Host "Output: $spJson" -ForegroundColor Yellow
        exit 1
    }
}

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
Write-Host ""
Write-Host "⚠️  CRITICAL: Copy the ENTIRE JSON below (from { to } including both braces):" -ForegroundColor Yellow -BackgroundColor DarkRed
Write-Host ""

# Pretty print the JSON for better readability
$spJsonPretty = $spJson | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host $spJsonPretty -ForegroundColor White

Write-Host ""
Write-Host "✅ Verify the JSON has ALL 4 fields:" -ForegroundColor Green
$spObj = $spJson | ConvertFrom-Json
Write-Host "   ✓ clientId: $($spObj.clientId)" -ForegroundColor Gray
Write-Host "   ✓ clientSecret: $(if($spObj.clientSecret){'[PRESENT]'}else{'[MISSING]'})" -ForegroundColor Gray
Write-Host "   ✓ subscriptionId: $($spObj.subscriptionId)" -ForegroundColor Gray
Write-Host "   ✓ tenantId: $($spObj.tenantId)" -ForegroundColor Gray
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

AZURE_CREDENTIALS (Copy the ENTIRE JSON including { and }):
$spJson

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
Write-Host ""

# Test the Service Principal credentials
Write-Host "🧪 Testing Service Principal credentials..." -ForegroundColor Cyan
$spTestObj = $spJson | ConvertFrom-Json
$testLogin = az login --service-principal `
    --username $spTestObj.clientId `
    --password $spTestObj.clientSecret `
    --tenant $spTestObj.tenantId 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Service Principal credentials are valid and working!" -ForegroundColor Green
    # Switch back to user account
    az logout 2>$null
    az login --output none 2>&1 | Out-Null
} else {
    Write-Host "⚠️  Warning: Could not verify Service Principal credentials" -ForegroundColor Yellow
    Write-Host "   This might be a temporary issue. The credentials should still work in GitHub Actions." -ForegroundColor Gray
}
Write-Host ""

# Prompt to open GitHub
$openGithub = Read-Host "Open GitHub secrets page in browser? (Y/n)"
if ($openGithub -ne 'n' -and $openGithub -ne 'N') {
    Start-Process "https://github.com/$githubRepo/settings/secrets/actions"
}

Write-Host ""
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host ("=" * 78) -ForegroundColor Cyan
Write-Host "⚠️  REMINDER: Copy the ENTIRE JSON for AZURE_CREDENTIALS (including { and })" -ForegroundColor Yellow -BackgroundColor DarkRed
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host ("=" * 78) -ForegroundColor Cyan
