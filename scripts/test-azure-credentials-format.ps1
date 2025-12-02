# Test Azure Credentials Format
# This script helps verify that your AZURE_CREDENTIALS secret has the correct format

Write-Host "🧪 Azure Credentials Format Tester" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This tool will help you verify your AZURE_CREDENTIALS JSON is correctly formatted." -ForegroundColor White
Write-Host ""

# Ask user to paste their credentials
Write-Host "📋 Paste your AZURE_CREDENTIALS JSON below and press Enter twice:" -ForegroundColor Yellow
Write-Host "(Include the opening { and closing })" -ForegroundColor Gray
Write-Host ""

$lines = @()
$emptyLineCount = 0

do {
    $line = Read-Host
    if ([string]::IsNullOrWhiteSpace($line)) {
        $emptyLineCount++
    } else {
        $emptyLineCount = 0
        $lines += $line
    }
} while ($emptyLineCount -lt 2)

$jsonInput = $lines -join "`n"

Write-Host ""
Write-Host "🔍 Analyzing your JSON..." -ForegroundColor Cyan
Write-Host ""

# Try to parse the JSON
try {
    $creds = $jsonInput | ConvertFrom-Json
    
    # Check for required fields
    $requiredFields = @('clientId', 'clientSecret', 'subscriptionId', 'tenantId')
    $missingFields = @()
    $presentFields = @()
    
    foreach ($field in $requiredFields) {
        if ($creds.$field) {
            $presentFields += $field
            Write-Host "✅ $field : PRESENT" -ForegroundColor Green
        } else {
            $missingFields += $field
            Write-Host "❌ $field : MISSING" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    
    if ($missingFields.Count -eq 0) {
        Write-Host "🎉 SUCCESS! Your JSON has all required fields." -ForegroundColor Green -BackgroundColor DarkGreen
        Write-Host ""
        Write-Host "Your AZURE_CREDENTIALS secret should work correctly." -ForegroundColor White
        Write-Host ""
        
        # Show the values (masked)
        Write-Host "📊 Credential Details:" -ForegroundColor Cyan
        Write-Host "   Client ID      : $($creds.clientId)" -ForegroundColor Gray
        Write-Host "   Client Secret  : $('*' * 20) (hidden)" -ForegroundColor Gray
        Write-Host "   Subscription ID: $($creds.subscriptionId)" -ForegroundColor Gray
        Write-Host "   Tenant ID      : $($creds.tenantId)" -ForegroundColor Gray
        Write-Host ""
        
        # Validate GUID format
        $guidPattern = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        
        Write-Host "🔬 Format Validation:" -ForegroundColor Cyan
        if ($creds.clientId -match $guidPattern) {
            Write-Host "   ✅ Client ID is valid GUID format" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Client ID doesn't look like a valid GUID" -ForegroundColor Yellow
        }
        
        if ($creds.subscriptionId -match $guidPattern) {
            Write-Host "   ✅ Subscription ID is valid GUID format" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Subscription ID doesn't look like a valid GUID" -ForegroundColor Yellow
        }
        
        if ($creds.tenantId -match $guidPattern) {
            Write-Host "   ✅ Tenant ID is valid GUID format" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Tenant ID doesn't look like a valid GUID" -ForegroundColor Yellow
        }
        
        if ($creds.clientSecret.Length -gt 10) {
            Write-Host "   ✅ Client Secret has reasonable length" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Client Secret seems too short" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "✨ Next Steps:" -ForegroundColor Cyan
        Write-Host "1. Copy this JSON to your GitHub repository secret" -ForegroundColor White
        Write-Host "2. Go to: Settings → Secrets and variables → Actions" -ForegroundColor White
        Write-Host "3. Create or update secret named: AZURE_CREDENTIALS" -ForegroundColor White
        Write-Host "4. Paste the ENTIRE JSON (what you just pasted here)" -ForegroundColor White
        
    } else {
        Write-Host "❌ ERROR: Missing required fields!" -ForegroundColor Red -BackgroundColor DarkRed
        Write-Host ""
        Write-Host "Missing fields:" -ForegroundColor Yellow
        foreach ($field in $missingFields) {
            Write-Host "   - $field" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Your JSON must have ALL of these fields:" -ForegroundColor Yellow
        Write-Host '   {' -ForegroundColor Gray
        Write-Host '     "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",' -ForegroundColor Gray
        Write-Host '     "clientSecret": "your-secret-value",' -ForegroundColor Gray
        Write-Host '     "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",' -ForegroundColor Gray
        Write-Host '     "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"' -ForegroundColor Gray
        Write-Host '   }' -ForegroundColor Gray
    }
    
} catch {
    Write-Host "❌ ERROR: Invalid JSON format!" -ForegroundColor Red -BackgroundColor DarkRed
    Write-Host ""
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "   - Missing opening { or closing }" -ForegroundColor Gray
    Write-Host "   - Extra commas at the end" -ForegroundColor Gray
    Write-Host "   - Missing quotes around field names" -ForegroundColor Gray
    Write-Host "   - Unclosed quotes" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Expected format:" -ForegroundColor White
    Write-Host '   {' -ForegroundColor Gray
    Write-Host '     "clientId": "value",' -ForegroundColor Gray
    Write-Host '     "clientSecret": "value",' -ForegroundColor Gray
    Write-Host '     "subscriptionId": "value",' -ForegroundColor Gray
    Write-Host '     "tenantId": "value"' -ForegroundColor Gray
    Write-Host '   }' -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
