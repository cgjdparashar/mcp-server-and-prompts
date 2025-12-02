# GitHub CI/CD Pipeline Generator

Automatically detect your repository's technology stack and generate a complete CI/CD pipeline using GitHub Actions.

## 🎯 Overview

This prompt analyzes your GitHub repository to:
- **Detect** programming languages, frameworks, and tools
- **Identify** dependencies, build systems, and test frameworks
- **Generate** a complete GitHub Actions workflow
- **Create** supporting documentation and configuration files
- **Configure** build, test, and deployment stages

## 📋 Prerequisites

1. **GitHub MCP Server** connected and authenticated
2. **Repository access** (read for analysis, write for creating workflows)
3. **GitHub token** with appropriate permissions:
   - `repo` scope for private repositories
   - `workflow` scope for creating/updating workflows
   - `write:packages` if using GitHub Container Registry

## 🚀 Quick Start

### Step 1: Set Environment Variables

Run the setup script to configure required variables:

```powershell
. .\scripts\prompts\set-github-cicd-env.ps1
```

Or manually set them:

```powershell
$env:GITHUB_REPO_OWNER = "your-github-username"
$env:GITHUB_REPO_NAME = "your-repository-name"
$env:GITHUB_BRANCH = "main"
$env:DEPLOYMENT_TARGET = "azure"  # or aws, docker, github-pages, none
```

### Step 2: Execute the Prompt

Invoke the `github-cicd-pipeline-generator.prompt.md` through your MCP client.

### Step 3: Review Generated Files

The prompt will create:
- `.github/workflows/ci-cd-pipeline.yml` - Main workflow file
- `.github/workflows/README.md` - Pipeline documentation
- `.env.example` - Environment variables template
- `DEPLOYMENT.md` - Deployment instructions

### Step 4: Configure Secrets

Add required secrets in GitHub repository settings:
- Navigate to `Settings` > `Secrets and variables` > `Actions`
- Add secrets based on your deployment target (see below)

### Step 5: Trigger First Build

Push code or merge the PR to trigger the first workflow run.

## 🔧 Configuration Options

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_REPO_OWNER` | Repository owner/organization | `microsoft` |
| `GITHUB_REPO_NAME` | Repository name | `vscode` |

### Optional Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `GITHUB_BRANCH` | Target branch | `main` | Any branch name |
| `DEPLOYMENT_TARGET` | Where to deploy | `none` | `azure`, `aws`, `docker`, `github-pages`, `none` |
| `ENABLE_CODE_SCANNING` | Enable CodeQL scanning | `true` | `true`, `false` |
| `ENABLE_DEPENDENCY_REVIEW` | Enable vulnerability scanning | `true` | `true`, `false` |
| `CREATE_PR` | Create PR vs direct commit | `true` | `true`, `false` |
| `RUNNER_OS` | GitHub Actions runner | `ubuntu-latest` | `ubuntu-latest`, `windows-latest`, `macos-latest` |

### Version Overrides

Override auto-detected versions:

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_VERSION` | Node.js version | `18.x`, `20.x` |
| `PYTHON_VERSION` | Python version | `3.11`, `3.12` |
| `JAVA_VERSION` | Java version | `11`, `17`, `21` |
| `DOTNET_VERSION` | .NET version | `6.x`, `7.x`, `8.x` |

## 🔍 Supported Technologies

### Languages & Runtimes
- **Node.js** (JavaScript/TypeScript)
- **Python**
- **Java** (Maven, Gradle)
- **.NET/C#**
- **Go**
- **Ruby**
- **PHP**
- **Rust**

### Frontend Frameworks
- React
- Angular
- Vue.js
- Next.js
- Svelte
- Static HTML/CSS/JS

### Backend Frameworks
- Express.js, Fastify, Nest.js
- Django, Flask, FastAPI
- Spring Boot, Micronaut, Quarkus
- ASP.NET Core

### Testing Frameworks
- Jest, Mocha, Cypress, Playwright
- Pytest, unittest
- JUnit, TestNG
- xUnit, NUnit

### Containerization
- Docker
- Docker Compose

## 🚢 Deployment Targets

### Azure (`DEPLOYMENT_TARGET=azure`)

**Supported Services:**
- Azure Web Apps
- Azure Container Apps
- Azure Functions
- Azure Static Web Apps

**Required Secrets:**
```powershell
# Service Principal (recommended)
AZURE_CREDENTIALS = '{
  "clientId": "<GUID>",
  "clientSecret": "<SECRET>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>"
}'

# Or Web App Publish Profile
AZURE_WEBAPP_PUBLISH_PROFILE = '<publishData>...</publishData>'
```

**Setup:**
```bash
# Create Service Principal
az ad sp create-for-rbac --name "github-actions" --sdk-auth \
  --role contributor \
  --scopes /subscriptions/{subscription-id}
```

### AWS (`DEPLOYMENT_TARGET=aws`)

**Supported Services:**
- Elastic Beanstalk
- ECS (Elastic Container Service)
- Lambda
- S3 (static sites)

**Required Secrets:**
```powershell
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
AWS_REGION = "us-east-1"
```

**Setup:**
```bash
# Create IAM user with programmatic access
aws iam create-user --user-name github-actions
aws iam attach-user-policy --user-name github-actions \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam create-access-key --user-name github-actions
```

### Docker (`DEPLOYMENT_TARGET=docker`)

**Supported Registries:**
- Docker Hub
- GitHub Container Registry (ghcr.io)
- Azure Container Registry (ACR)

**Required Secrets:**
```powershell
# Docker Hub
DOCKER_USERNAME = "your-username"
DOCKER_PASSWORD = "your-password-or-token"

# Or use GitHub Container Registry (automatic)
# Uses built-in GITHUB_TOKEN
```

### GitHub Pages (`DEPLOYMENT_TARGET=github-pages`)

**Configuration:**
1. Enable GitHub Pages in repository settings
2. Set source to "GitHub Actions"
3. No additional secrets required

**Supported:**
- Static HTML/CSS/JS
- Jekyll sites
- Next.js static exports
- React/Vue/Angular builds

### None (`DEPLOYMENT_TARGET=none`)

Build and test only, no deployment stage.

## 📊 Pipeline Features

### Generated Workflow Includes:

1. **Code Checkout** - Fetch repository code
2. **Environment Setup** - Install language runtime and tools
3. **Dependency Caching** - Speed up builds
4. **Dependency Installation** - Install packages
5. **Code Linting** - Run code quality checks
6. **Build** - Compile/bundle application
7. **Unit Tests** - Run test suite
8. **Integration Tests** - Run integration tests (if detected)
9. **Test Coverage** - Generate coverage reports
10. **Security Scanning** - CodeQL and dependency checks
11. **Build Artifacts** - Upload build outputs
12. **Deployment** - Deploy to target platform

### Workflow Triggers:

- **Push** to main/master branch
- **Pull Requests** to main/master
- **Manual** workflow dispatch
- **Optional:** Scheduled builds

## 🔐 Security Best Practices

The generated pipeline includes:

✅ **Dependency Vulnerability Scanning**
- `npm audit`, `pip-audit`, OWASP Dependency-Check
- Automatic PR comments with findings

✅ **Code Security Scanning**
- CodeQL analysis for supported languages
- Custom security queries

✅ **Secrets Management**
- All credentials use GitHub Secrets
- No hardcoded secrets in workflow files

✅ **Pinned Action Versions**
- Actions pinned to specific versions or SHA
- Reduces supply chain risks

✅ **Branch Protection**
- Recommendations for protected branches
- Required status checks

✅ **Dependabot Integration**
- Auto-generated Dependabot configuration
- Automated dependency updates

## 🎨 Example Workflows

### Node.js + React + Azure

```powershell
$env:GITHUB_REPO_OWNER = "mycompany"
$env:GITHUB_REPO_NAME = "react-app"
$env:DEPLOYMENT_TARGET = "azure"
```

**Generated Pipeline:**
- Setup Node.js 18.x
- Install dependencies with npm
- Run ESLint
- Build with webpack/vite
- Run Jest tests
- Deploy to Azure Static Web Apps

### Python + FastAPI + Docker

```powershell
$env:GITHUB_REPO_OWNER = "mycompany"
$env:GITHUB_REPO_NAME = "fastapi-service"
$env:DEPLOYMENT_TARGET = "docker"
```

**Generated Pipeline:**
- Setup Python 3.11
- Install dependencies with pip
- Run pylint and black
- Run pytest with coverage
- Build Docker image
- Push to GitHub Container Registry

### Java + Spring Boot + AWS

```powershell
$env:GITHUB_REPO_OWNER = "mycompany"
$env:GITHUB_REPO_NAME = "spring-service"
$env:DEPLOYMENT_TARGET = "aws"
```

**Generated Pipeline:**
- Setup Java 17
- Build with Maven
- Run JUnit tests
- Package JAR
- Deploy to Elastic Beanstalk

## 📈 Monitoring & Troubleshooting

### View Workflow Runs

Navigate to your repository on GitHub:
- Click **Actions** tab
- View workflow runs and logs

### Common Issues

**Issue: Workflow fails during dependency installation**
```
Solution: Check package manager lockfiles are committed
- package-lock.json (npm)
- yarn.lock (yarn)
- requirements.txt (pip)
```

**Issue: Tests fail in CI but pass locally**
```
Solution: Check for environment differences
- Set required environment variables
- Use consistent Node/Python versions
- Check timezone/locale settings
```

**Issue: Deployment fails with authentication error**
```
Solution: Verify secrets are configured
- Check secret names match workflow
- Verify credentials are valid
- Check permission scopes
```

**Issue: CodeQL scanning fails**
```
Solution: Language may not be supported or needs configuration
- Check supported languages: JavaScript, TypeScript, Python, Java, C#, C++, Go
- Add manual build steps if needed
```

## 🔄 Updating the Pipeline

To regenerate or update the pipeline:

1. Update environment variables with new configuration
2. Re-run the prompt
3. Review changes in the PR
4. Merge to apply updates

## 🤝 Best Practices

1. **Review generated workflows** before merging
2. **Test in a feature branch** first
3. **Configure required secrets** immediately after setup
4. **Enable branch protection** for main/master
5. **Monitor first few builds** closely
6. **Set up notifications** for build failures
7. **Use environment-specific variables** for different stages
8. **Keep dependencies updated** with Dependabot
9. **Review security alerts** promptly
10. **Document custom changes** to workflows

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Workflow Syntax Reference](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions)
- [Security Hardening Guide](https://docs.github.com/actions/security-guides/security-hardening-for-github-actions)
- [Azure Deployment](https://docs.microsoft.com/azure/developer/github/connect-from-azure)
- [AWS Deployment](https://github.com/aws-actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)

## 🐛 Support

For issues or questions:
1. Check the generated `.github/workflows/README.md` in your repository
2. Review GitHub Actions logs for specific errors
3. Consult the [GitHub Actions community forum](https://github.community/c/github-actions)
4. Open an issue in this repository

---

**Happy Building! 🚀**
