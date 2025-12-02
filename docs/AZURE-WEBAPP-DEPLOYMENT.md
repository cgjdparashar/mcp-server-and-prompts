# Azure Web App Deployment Guide

This guide explains how to deploy your application to Azure Web Apps using the automated CI/CD pipeline.

## 🎯 Overview

The CI/CD pipeline automatically:
1. **Detects your tech stack** (Node.js, Python, Java, .NET, PHP, Ruby, or static site)
2. **Creates Azure resources** (Resource Group, App Service Plan, Web App)
3. **Configures the runtime** based on detected stack
4. **Deploys your application** to Azure Web Apps
5. **Provides deployment URL** (https://your-app.azurewebsites.net)

## 🚀 Quick Start

### Prerequisites

1. **Azure Account**: [Sign up for free](https://azure.microsoft.com/free/)
2. **Azure CLI**: [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **GitHub Repository**: Your code repository

### Step 1: Run Setup Script

```powershell
# Navigate to your project directory
cd path\to\mcp-server-and-prompts

# Run the Azure setup script
.\scripts\setup-azure-webapp-secrets.ps1
```

The script will:
- ✅ Login to Azure
- ✅ Create a Service Principal for GitHub Actions
- ✅ Generate all required secrets
- ✅ Save configuration to a file

### Step 2: Add Secrets to GitHub

The script provides 5 secrets to add to your GitHub repository:

#### Required Secrets:

1. **AZURE_CREDENTIALS**: Service Principal credentials (JSON)
2. **AZURE_RESOURCE_GROUP**: Your Azure Resource Group name
3. **AZURE_WEBAPP_NAME**: Your Web App name (must be globally unique)

#### Optional Secrets:

4. **AZURE_LOCATION**: Azure region (default: eastus)
5. **AZURE_SKU**: App Service pricing tier (default: F1 - Free)

**How to add secrets:**
1. Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`
2. Click **"New repository secret"**
3. Add name and value for each secret
4. Click **"Add secret"**

### Step 3: Push Your Code

```bash
git add .
git commit -m "feat: Configure Azure Web App deployment"
git push origin main
```

The pipeline will automatically:
- Run validation and tests
- Create Azure resources (if they don't exist)
- Deploy your application
- Provide the deployment URL

## 🔧 Tech Stack Detection

The pipeline automatically detects your application type:

| Tech Stack | Detection Files | Azure Runtime |
|------------|----------------|---------------|
| **Node.js** | `package.json` | NODE\|18-lts |
| **Python** | `requirements.txt`, `Pipfile`, `pyproject.toml` | PYTHON\|3.11 |
| **Java** | `pom.xml`, `build.gradle` | JAVA\|17-java17 |
| **.NET** | `*.csproj`, `*.fsproj` | DOTNETCORE\|8.0 |
| **PHP** | `composer.json`, `index.php` | PHP\|8.2 |
| **Ruby** | `Gemfile`, `config.ru` | RUBY\|3.2 |
| **Static** | Documentation only | NODE\|18-lts (with Express) |

## 📦 What Gets Created

### Azure Resources

1. **Resource Group**: Container for all resources
2. **App Service Plan**: Compute resources (SKU: F1, B1, S1, P1V2, etc.)
3. **Web App**: Your application hosting environment

### Configuration

The pipeline configures:
- Runtime version based on detected tech stack
- Environment variables:
  - `SCM_DO_BUILD_DURING_DEPLOYMENT=true`
  - `WEBSITE_RUN_FROM_PACKAGE=1`
  - `DEPLOYMENT_BRANCH`: Branch name
  - `DEPLOYMENT_COMMIT`: Commit SHA
  - `BUILD_NUMBER`: Build number

## 🌐 Accessing Your App

After successful deployment:

**URL Format**: `https://<AZURE_WEBAPP_NAME>.azurewebsites.net`

Example: `https://mcp-prompts-app.azurewebsites.net`

## 📊 App Service Plans (SKU)

| SKU | Tier | Price | Features |
|-----|------|-------|----------|
| **F1** | Free | $0/month | 60 min/day, 1 GB RAM, 1 GB storage |
| **B1** | Basic | ~$13/month | Always on, custom domains, SSL |
| **B2** | Basic | ~$26/month | 2 cores, 3.5 GB RAM |
| **S1** | Standard | ~$70/month | Auto-scale, staging slots, backups |
| **P1V2** | Premium | ~$146/month | Better performance, VNet integration |

💡 **Recommendation**: Start with **F1** (Free) for testing, upgrade to **B1** for production.

## 🔒 Security Best Practices

### Service Principal Permissions

The setup script creates a Service Principal with **Contributor** role scoped to the Resource Group:
- ✅ Can create and manage resources in the Resource Group
- ❌ Cannot access other Resource Groups or subscriptions
- ✅ Follows principle of least privilege

### Secret Management

- ✅ Never commit `AZURE_CREDENTIALS` to Git
- ✅ Store secrets in GitHub repository secrets
- ✅ Rotate Service Principal credentials periodically
- ✅ Use separate Service Principals for different environments

### Network Security

For production apps, consider:
- Enable Azure Front Door for DDoS protection
- Configure Private Endpoints for VNet integration
- Enable Azure WAF (Web Application Firewall)
- Restrict access with IP restrictions

## 🔄 CI/CD Workflow

### Workflow Stages

```
┌─────────────┐
│  Validate   │  Check structure, syntax, dependencies
└──────┬──────┘
       │
┌──────▼──────┐
│   Build     │  Install dependencies, build application
└──────┬──────┘
       │
┌──────▼──────┐
│  Security   │  Scan for vulnerabilities, lint markdown
└──────┬──────┘
       │
┌──────▼──────┐
│   Deploy    │  Detect stack → Create Azure resources → Deploy
└──────┬──────┘
       │
┌──────▼──────┐
│   Notify    │  Summary of deployment status
└─────────────┘
```

### Deployment Conditions

Deployment runs when:
- ✅ Push to `main` or `devops-build-deploy-code` branch
- ✅ All validation and security checks pass
- ✅ Azure credentials are configured

## 🛠️ Troubleshooting

### Common Issues

#### 1. "Web app name already taken"

**Error**: `The hostname 'your-app.azurewebsites.net' is already taken`

**Solution**: Web App names must be globally unique. Choose a different name.

```powershell
# Check availability
az webapp list --query "[?name=='your-app-name'].name"
```

#### 2. "Service Principal authentication failed"

**Error**: `AADSTS7000215: Invalid client secret provided`

**Solution**: Regenerate Service Principal credentials

```bash
# Reset credentials
az ad sp credential reset --id <service-principal-id>
```

#### 3. "Deployment timeout"

**Error**: Deployment takes too long or times out

**Solution**: 
- Check App Service Plan SKU (F1 is slower)
- Review build logs for dependency installation issues
- Consider upgrading to B1 or higher

#### 4. "Runtime version mismatch"

**Error**: Application fails to start with runtime error

**Solution**: Check your runtime version in workflow logs
```bash
# For Node.js
node --version

# For Python
python --version
```

### Viewing Logs

#### Azure Portal
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your Web App
3. Select **Log stream** for real-time logs
4. Select **Deployment Center** for deployment history

#### Azure CLI
```bash
# Stream logs
az webapp log tail --name <webapp-name> --resource-group <resource-group>

# Download logs
az webapp log download --name <webapp-name> --resource-group <resource-group>
```

#### GitHub Actions
1. Go to repository **Actions** tab
2. Click on the workflow run
3. Expand each job to view detailed logs

## 🔄 Updating Your Deployment

### Change Runtime Version

Edit `.github/workflows/ci-cd-pipeline.yml`:

```yaml
# For Node.js
echo "runtime_version=NODE|20-lts" >> $GITHUB_OUTPUT

# For Python
echo "runtime_version=PYTHON|3.12" >> $GITHUB_OUTPUT
```

### Scale Your App

```bash
# Scale up (better SKU)
az appservice plan update --name <plan-name> --resource-group <resource-group> --sku B1

# Scale out (more instances)
az appservice plan update --name <plan-name> --resource-group <resource-group> --number-of-workers 2
```

### Configure Custom Domain

```bash
# Add custom domain
az webapp config hostname add --webapp-name <webapp-name> --resource-group <resource-group> --hostname www.example.com

# Enable SSL
az webapp config ssl bind --certificate-thumbprint <thumbprint> --ssl-type SNI --name <webapp-name> --resource-group <resource-group>
```

## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)

## 💡 Tips

1. **Use Free Tier for Development**: F1 SKU is perfect for testing
2. **Enable Application Insights**: Monitor performance and errors
3. **Set up Staging Slots**: Test before production deployment
4. **Configure Auto-scaling**: Handle traffic spikes automatically
5. **Enable Backups**: Regular backups for production apps
6. **Use Azure Front Door**: CDN and DDoS protection

## 🆘 Support

If you encounter issues:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review GitHub Actions logs
3. Check Azure Portal logs
4. Open an issue in the repository

---

**Last Updated**: December 2, 2025  
**Version**: 1.0.0
