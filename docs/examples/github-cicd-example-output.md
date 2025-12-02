# Example: Generated CI/CD Workflow

This is an example of what the GitHub CI/CD Pipeline Generator prompt creates for a Node.js + React application deploying to Azure.

## Generated File: `.github/workflows/ci-cd-pipeline.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

env:
  NODE_VERSION: '18.x'
  AZURE_WEBAPP_NAME: 'my-react-app'
  AZURE_WEBAPP_PACKAGE_PATH: './build'

jobs:
  build-and-test:
    name: Build and Test
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js ${{ env.NODE_VERSION }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run ESLint
      run: npm run lint
      continue-on-error: true
      
    - name: Build application
      run: npm run build
      
    - name: Run tests
      run: npm test -- --coverage --watchAll=false
      
    - name: Upload test coverage
      uses: actions/upload-artifact@v4
      with:
        name: coverage-report
        path: coverage/
        
    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      with:
        name: build-artifacts
        path: build/

  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    needs: build-and-test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: javascript
        
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      
    - name: Run npm audit
      run: npm audit --audit-level=moderate
      continue-on-error: true

  deploy-to-azure:
    name: Deploy to Azure Web App
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment:
      name: production
      url: ${{ steps.deploy.outputs.webapp-url }}
    
    steps:
    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: build-artifacts
        path: build/
        
    - name: Azure Login
      uses: azure/login@v2
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
        
    - name: Deploy to Azure Web App
      id: deploy
      uses: azure/webapps-deploy@v3
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
        
    - name: Logout from Azure
      run: az logout
```

## Generated File: `.github/workflows/README.md`

```markdown
# CI/CD Pipeline Documentation

## Overview

This workflow automatically builds, tests, and deploys the React application to Azure Web App whenever code is pushed to the main branch.

## Workflow Structure

### Jobs

1. **build-and-test**
   - Checks out code
   - Sets up Node.js 18.x with npm caching
   - Installs dependencies
   - Runs ESLint for code quality
   - Builds the React application
   - Runs Jest tests with coverage
   - Uploads artifacts

2. **security-scan**
   - Runs CodeQL security analysis
   - Performs npm audit for vulnerability scanning

3. **deploy-to-azure**
   - Downloads build artifacts
   - Authenticates with Azure
   - Deploys to Azure Web App
   - Only runs on main branch pushes

## Required Secrets

Configure these secrets in GitHub repository settings:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CREDENTIALS` | Azure Service Principal credentials | Run `az ad sp create-for-rbac --sdk-auth` |

## Triggering the Workflow

The workflow runs automatically on:
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual trigger via Actions tab

## Environment Variables

Update these in the workflow file as needed:

- `NODE_VERSION`: Node.js version (default: 18.x)
- `AZURE_WEBAPP_NAME`: Your Azure Web App name
- `AZURE_WEBAPP_PACKAGE_PATH`: Path to deployment package

## Monitoring

View workflow runs at: `https://github.com/OWNER/REPO/actions`

## Troubleshooting

### Build fails with dependency errors
- Ensure `package-lock.json` is committed
- Check Node.js version compatibility

### Tests fail in CI
- Verify all test dependencies are in `package.json`
- Check for environment-specific issues

### Deployment fails
- Verify `AZURE_CREDENTIALS` secret is configured correctly
- Check Azure Web App name and resource group
- Ensure service principal has deployment permissions

## Local Testing

Test the build locally:
```bash
npm ci
npm run lint
npm run build
npm test
```
```

## Generated File: `.env.example`

```env
# Azure Configuration
AZURE_WEBAPP_NAME=my-react-app
AZURE_RESOURCE_GROUP=my-resource-group
AZURE_SUBSCRIPTION_ID=00000000-0000-0000-0000-000000000000

# Application Configuration
NODE_ENV=production
REACT_APP_API_URL=https://api.example.com
REACT_APP_VERSION=1.0.0

# Optional: Feature Flags
REACT_APP_ENABLE_ANALYTICS=true
REACT_APP_ENABLE_DEBUG=false
```

## Generated File: `DEPLOYMENT.md`

```markdown
# Deployment Guide

## Prerequisites

1. **Azure Resources**
   - Azure subscription
   - Azure Web App created
   - Resource group configured

2. **GitHub Configuration**
   - Repository secrets configured
   - GitHub Actions enabled
   - Branch protection rules (recommended)

## Initial Setup

### 1. Create Azure Resources

```bash
# Login to Azure
az login

# Create resource group
az group create --name my-resource-group --location eastus

# Create App Service plan
az appservice plan create \
  --name my-app-service-plan \
  --resource-group my-resource-group \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --name my-react-app \
  --resource-group my-resource-group \
  --plan my-app-service-plan \
  --runtime "NODE|18-lts"
```

### 2. Configure GitHub Secrets

```bash
# Create Service Principal
az ad sp create-for-rbac \
  --name "github-actions-my-react-app" \
  --sdk-auth \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/my-resource-group

# Copy the JSON output and add as AZURE_CREDENTIALS secret in GitHub
```

### 3. Configure Web App

```bash
# Set Node.js version
az webapp config appsettings set \
  --name my-react-app \
  --resource-group my-resource-group \
  --settings WEBSITE_NODE_DEFAULT_VERSION="~18"

# Enable detailed logging
az webapp log config \
  --name my-react-app \
  --resource-group my-resource-group \
  --application-logging filesystem \
  --detailed-error-messages true \
  --web-server-logging filesystem
```

## Deployment Process

1. **Push to main branch** triggers automatic deployment
2. **Monitor workflow** in GitHub Actions tab
3. **Verify deployment** at https://my-react-app.azurewebsites.net

## Manual Deployment

Trigger manual deployment via GitHub Actions:
1. Go to Actions tab
2. Select "CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Select branch and run

## Rollback

To rollback to a previous version:

```bash
# List deployment slots
az webapp deployment slot list \
  --name my-react-app \
  --resource-group my-resource-group

# Swap to previous slot
az webapp deployment slot swap \
  --name my-react-app \
  --resource-group my-resource-group \
  --slot staging \
  --target-slot production
```

## Monitoring

### Application Insights

```bash
# Enable Application Insights
az monitor app-insights component create \
  --app my-react-app-insights \
  --location eastus \
  --resource-group my-resource-group \
  --application-type web

# Link to Web App
az webapp config appsettings set \
  --name my-react-app \
  --resource-group my-resource-group \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY="{instrumentation-key}"
```

### Log Streaming

```bash
# Stream logs in real-time
az webapp log tail \
  --name my-react-app \
  --resource-group my-resource-group
```

## Troubleshooting

### Issue: Deployment succeeds but app doesn't start

**Check:**
- Web App logs: `az webapp log tail`
- Application settings: Verify NODE_ENV and paths
- Build output: Ensure `build/` directory contains all files

**Solution:**
```bash
# Restart Web App
az webapp restart \
  --name my-react-app \
  --resource-group my-resource-group
```

### Issue: 403/404 errors after deployment

**Check:**
- Static file routing configuration
- Web.config or .htaccess for SPA routing

**Solution:**
Add `web.config` for Azure:
```xml
<?xml version="1.0"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="React Routes" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

## Production Checklist

- [ ] Environment variables configured
- [ ] Secrets properly set in GitHub
- [ ] Azure resources provisioned
- [ ] Service Principal permissions verified
- [ ] Application Insights enabled
- [ ] Custom domain configured (optional)
- [ ] SSL certificate configured
- [ ] Branch protection rules enabled
- [ ] Monitoring alerts configured
- [ ] Backup strategy defined

## Support

For issues:
1. Check workflow logs in GitHub Actions
2. Review Azure Web App logs
3. Consult [Azure Web Apps documentation](https://docs.microsoft.com/azure/app-service/)
```

---

## Summary

The GitHub CI/CD Pipeline Generator prompt creates:

1. **Complete workflow file** with build, test, security scanning, and deployment
2. **Comprehensive documentation** explaining the pipeline and how to use it
3. **Environment template** for required variables
4. **Deployment guide** with step-by-step Azure setup instructions

All generated files are tailored to your specific tech stack with appropriate:
- Language/framework versions
- Package managers and commands
- Testing frameworks
- Security scanning tools
- Deployment targets and configurations
