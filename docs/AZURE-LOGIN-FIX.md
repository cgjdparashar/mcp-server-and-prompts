# Azure Login Authentication Fix

## Issue

```
Error: Login failed with Error: Using auth-type: SERVICE_PRINCIPAL. 
Not all values are present. Ensure 'client-id' and 'tenant-id' are supplied.
```

## Root Cause

The `azure/login` action requires a properly formatted Service Principal JSON with all required fields:
- `clientId` (Application/Client ID)
- `clientSecret` (Client Secret/Password)
- `subscriptionId` (Azure Subscription ID)
- `tenantId` (Azure AD Tenant ID)

## Solution Applied

### 1. Updated Workflow File

**File**: `.github/workflows/ci-cd-pipeline.yml`

**Changed:**
```yaml
# Old (v1)
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
```

**To:**
```yaml
# New (v2) - More reliable
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
    enable-AzPSSession: false
```

### 2. Updated Setup Script

**File**: `scripts/setup-azure-webapp-secrets.ps1`

**Changes:**
- ✅ Creates Resource Group before Service Principal
- ✅ Deletes existing SP to avoid conflicts
- ✅ Validates JSON output before displaying
- ✅ Shows client-id and tenant-id for verification
- ✅ Warns user to copy ENTIRE JSON including braces

**Key improvements:**
```powershell
# Create Resource Group first
az group create --name $resourceGroup --location $location

# Delete existing SP if present
az ad sp delete --id $existingSp

# Create with --sdk-auth (generates proper JSON format)
$spJson = az ad sp create-for-rbac `
    --name $spName `
    --role contributor `
    --scopes /subscriptions/$subscription/resourceGroups/$resourceGroup `
    --sdk-auth

# Validate the JSON
$spObject = $spJson | ConvertFrom-Json
Write-Host "Client ID: $($spObject.clientId)"
Write-Host "Tenant ID: $($spObject.tenantId)"
```

## Required JSON Format

The `AZURE_CREDENTIALS` secret MUST contain ALL of these fields:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "your-secret-value",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## How to Fix Existing Setup

### Option 1: Re-run Setup Script (Recommended)

```powershell
# This will create fresh credentials
.\scripts\setup-azure-webapp-secrets.ps1
```

The script will:
1. Delete old Service Principal (if exists)
2. Create new Service Principal with proper credentials
3. Display properly formatted JSON
4. Save to file for reference

### Option 2: Manual Fix

If you want to fix manually:

1. **Delete old Service Principal:**
   ```bash
   az ad sp delete --display-name "sp-github-YOUR-WEBAPP-NAME"
   ```

2. **Create new Service Principal:**
   ```bash
   az ad sp create-for-rbac \
     --name "sp-github-YOUR-WEBAPP-NAME" \
     --role contributor \
     --scopes /subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/YOUR-RESOURCE-GROUP \
     --sdk-auth
   ```

3. **Copy the ENTIRE output** (including `{` and `}`)

4. **Update GitHub Secret:**
   - Go to: `https://github.com/YOUR-USERNAME/YOUR-REPO/settings/secrets/actions`
   - Find `AZURE_CREDENTIALS`
   - Click "Update"
   - Paste the ENTIRE JSON
   - Click "Update secret"

## Verification Checklist

After updating credentials, verify:

- [ ] JSON contains all 4 fields: clientId, clientSecret, subscriptionId, tenantId
- [ ] No extra quotes or escape characters
- [ ] Includes opening `{` and closing `}`
- [ ] No line breaks or formatting issues
- [ ] Secret name is exactly `AZURE_CREDENTIALS` (case-sensitive)

## Testing

After fixing, test the deployment:

```bash
# Push a change to trigger workflow
git commit --allow-empty -m "test: Verify Azure login fix"
git push origin main
```

Check workflow logs:
1. Go to repository → Actions tab
2. Click on the latest workflow run
3. Expand "Deploy to Azure Web App" job
4. Verify "Azure Login" step succeeds

**Expected output:**
```
✅ Azure Login
Login successful
```

## Common Mistakes

### ❌ Missing Braces
```json
"clientId": "xxx",
"clientSecret": "xxx",
...
```
**Fix**: Add `{` at start and `}` at end

### ❌ Using Old --sdk-auth Format
Some older tutorials suggest using `--json-auth` or omitting `--sdk-auth`.

**Fix**: Always use `--sdk-auth` flag:
```bash
az ad sp create-for-rbac --sdk-auth ...
```

### ❌ Scope Issues
Service Principal without proper scope:
```bash
# ❌ Wrong - no scope
az ad sp create-for-rbac --name "sp-test"

# ✅ Right - scoped to resource group
az ad sp create-for-rbac --name "sp-test" \
  --scopes /subscriptions/XXX/resourceGroups/YYY
```

### ❌ Copying Partial JSON
Only copying part of the credentials.

**Fix**: Copy from `{` to `}` including all fields

### ❌ Extra Escape Characters
Windows PowerShell sometimes adds extra escaping when copying.

**Fix**: Copy from the saved file instead of terminal:
```powershell
Get-Content "azure-secrets-YOUR-WEBAPP-NAME.txt"
```

## Additional Resources

- [Azure Login Action Documentation](https://github.com/Azure/login#readme)
- [Azure CLI SP Creation](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## Support

If the issue persists:

1. **Check Azure Portal:**
   - Azure Active Directory → App registrations
   - Find your Service Principal
   - Verify it has Contributor role on Resource Group

2. **Check GitHub Secret:**
   - Repository → Settings → Secrets → Actions
   - Verify `AZURE_CREDENTIALS` exists
   - Check secret was updated recently

3. **Check Workflow Logs:**
   - Actions tab → Latest run → Deploy job
   - Look for specific error message
   - Verify all 4 fields are detected

4. **Re-create from Scratch:**
   ```powershell
   # Start fresh
   .\scripts\setup-azure-webapp-secrets.ps1
   
   # Follow the prompts
   # Copy ALL secrets to GitHub
   # Push code to trigger workflow
   ```

---

**Fixed in Commit**: [To be committed]  
**Date**: December 2, 2025  
**Files Changed**:
- `.github/workflows/ci-cd-pipeline.yml`
- `scripts/setup-azure-webapp-secrets.ps1`
