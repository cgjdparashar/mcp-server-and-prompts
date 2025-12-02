# How to Fix Azure Login Authentication Error

## Quick Fix (5 minutes)

### Step 1: Run Updated Setup Script

```powershell
# Navigate to your project
cd "C:\Users\skuma317\OneDrive - Capgemini\Documents\DemoMCP\mcp-server-and-prompts"

# Pull latest changes (includes the fix)
git pull origin devops-build-deploy-code

# Run the enhanced setup script
.\scripts\setup-azure-webapp-secrets.ps1
```

### Step 2: What the Script Will Do

The updated script now:
1. ✅ Creates Resource Group first (prevents scope issues)
2. ✅ Deletes old Service Principal (if exists)
3. ✅ Creates fresh Service Principal with proper JSON
4. ✅ Validates credentials (shows client-id and tenant-id)
5. ✅ Warns to copy ENTIRE JSON

You'll see output like:
```
🔐 Creating Service Principal for GitHub Actions...
✅ Service Principal created successfully
   Client ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   Tenant ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

1️⃣  AZURE_CREDENTIALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Copy the ENTIRE JSON object below (including { and }):

{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "your-secret-value",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Step 3: Update GitHub Secret

**CRITICAL**: Copy the ENTIRE JSON including `{` and `}`

1. Go to: https://github.com/cgjdparashar/mcp-server-and-prompts/settings/secrets/actions

2. Find **AZURE_CREDENTIALS** secret

3. Click **"Update"** (or "New repository secret" if not exists)

4. **Paste the ENTIRE JSON** (from `{` to `}`)

5. Click **"Update secret"**

### Step 4: Verify the Fix

```bash
# Trigger workflow with empty commit
git commit --allow-empty -m "test: Verify Azure login fix"
git push origin devops-build-deploy-code
```

Then check:
1. Go to: https://github.com/cgjdparashar/mcp-server-and-prompts/actions
2. Click on latest workflow run
3. Expand "Deploy to Azure Web App" job
4. Verify "Azure Login" step shows: ✅ **Login successful**

## What Was Fixed

### 1. Workflow Changes
- ⬆️ Upgraded `azure/login@v1` → `azure/login@v2`
- ➕ Added `enable-AzPSSession: false` for reliability

### 2. Script Enhancements
- ✅ Creates Resource Group before Service Principal
- ✅ Deletes old Service Principal to avoid conflicts
- ✅ Validates JSON output
- ✅ Shows client-id and tenant-id for verification

### 3. New Documentation
- 📄 `docs/AZURE-LOGIN-FIX.md` - Complete troubleshooting guide
- 📝 Updated `docs/AZURE-WEBAPP-DEPLOYMENT.md` with error solutions

## Common Mistakes to Avoid

### ❌ Wrong: Partial JSON
```json
"clientId": "xxx",
"clientSecret": "xxx"
```

### ✅ Right: Complete JSON
```json
{
  "clientId": "xxx",
  "clientSecret": "xxx",
  "subscriptionId": "xxx",
  "tenantId": "xxx"
}
```

### ❌ Wrong: Missing braces
Copying without `{` at start and `}` at end

### ✅ Right: Include braces
Always include opening `{` and closing `}`

## Troubleshooting

### If script fails:

1. **Check Azure CLI:**
   ```powershell
   az version
   az login
   ```

2. **Check permissions:**
   - You need Owner or User Access Administrator role
   - Or at minimum: Contributor + User Access Administrator

3. **Check subscription:**
   ```bash
   az account show
   az account list
   ```

### If GitHub workflow still fails:

1. **Verify secret format:**
   - Go to repository secrets
   - Check AZURE_CREDENTIALS has all 4 fields
   - No extra quotes or escape characters

2. **Check saved file:**
   ```powershell
   # View the saved credentials
   Get-Content "azure-secrets-<webapp-name>.txt"
   ```

3. **Re-run setup from scratch:**
   ```powershell
   .\scripts\setup-azure-webapp-secrets.ps1
   ```

## Additional Help

See complete guides:
- **Quick Fix**: This file
- **Detailed Troubleshooting**: `docs/AZURE-LOGIN-FIX.md`
- **Full Deployment Guide**: `docs/AZURE-WEBAPP-DEPLOYMENT.md`

---

**Commit with Fix**: fcd1188  
**Date**: December 2, 2025
