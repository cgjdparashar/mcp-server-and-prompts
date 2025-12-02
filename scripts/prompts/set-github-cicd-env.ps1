# PowerShell script to configure environment variables for GitHub CI/CD Pipeline Generator prompt
# Usage: . .\scripts\prompts\set-github-cicd-env.ps1

Write-Host "🚀 GitHub CI/CD Pipeline Generator - Environment Setup" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Required variables
Write-Host "📋 Required Configuration:" -ForegroundColor Yellow
Write-Host ""

$repoOwner = Read-Host "GitHub Repository Owner/Organization"
$repoName = Read-Host "GitHub Repository Name"

# Optional variables with defaults
Write-Host ""
Write-Host "⚙️  Optional Configuration (press Enter for defaults):" -ForegroundColor Yellow
Write-Host ""

$branch = Read-Host "Target Branch (default: main)"
if ([string]::IsNullOrWhiteSpace($branch)) {
    $branch = "main"
}

Write-Host ""
Write-Host "Deployment Target Options:" -ForegroundColor Gray
Write-Host "  - azure       : Deploy to Azure (Web App, Container Apps, Functions)" -ForegroundColor Gray
Write-Host "  - aws         : Deploy to AWS (Elastic Beanstalk, ECS, Lambda, S3)" -ForegroundColor Gray
Write-Host "  - docker      : Build and push Docker image" -ForegroundColor Gray
Write-Host "  - github-pages: Deploy to GitHub Pages" -ForegroundColor Gray
Write-Host "  - none        : Build and test only, no deployment" -ForegroundColor Gray
Write-Host ""
$deployTarget = Read-Host "Deployment Target (default: none)"
if ([string]::IsNullOrWhiteSpace($deployTarget)) {
    $deployTarget = "none"
}

$enableCodeScanning = Read-Host "Enable CodeQL Security Scanning? (true/false, default: true)"
if ([string]::IsNullOrWhiteSpace($enableCodeScanning)) {
    $enableCodeScanning = "true"
}

$enableDependencyReview = Read-Host "Enable Dependency Vulnerability Scanning? (true/false, default: true)"
if ([string]::IsNullOrWhiteSpace($enableDependencyReview)) {
    $enableDependencyReview = "true"
}

$createPR = Read-Host "Create Pull Request? (true/false, default: true)"
if ([string]::IsNullOrWhiteSpace($createPR)) {
    $createPR = "true"
}

$runnerOS = Read-Host "GitHub Actions Runner OS (ubuntu-latest/windows-latest/macos-latest, default: ubuntu-latest)"
if ([string]::IsNullOrWhiteSpace($runnerOS)) {
    $runnerOS = "ubuntu-latest"
}

# Advanced overrides
Write-Host ""
$advancedConfig = Read-Host "Configure version overrides? (y/N)"
if ($advancedConfig -eq "y" -or $advancedConfig -eq "Y") {
    Write-Host ""
    Write-Host "Version Overrides (press Enter to use auto-detected versions):" -ForegroundColor Gray
    
    $nodeVersion = Read-Host "Node.js Version (e.g., 18.x, 20.x)"
    if (-not [string]::IsNullOrWhiteSpace($nodeVersion)) {
        $env:NODE_VERSION = $nodeVersion
    }
    
    $pythonVersion = Read-Host "Python Version (e.g., 3.11, 3.12)"
    if (-not [string]::IsNullOrWhiteSpace($pythonVersion)) {
        $env:PYTHON_VERSION = $pythonVersion
    }
    
    $javaVersion = Read-Host "Java Version (e.g., 11, 17, 21)"
    if (-not [string]::IsNullOrWhiteSpace($javaVersion)) {
        $env:JAVA_VERSION = $javaVersion
    }
    
    $dotnetVersion = Read-Host ".NET Version (e.g., 6.x, 7.x, 8.x)"
    if (-not [string]::IsNullOrWhiteSpace($dotnetVersion)) {
        $env:DOTNET_VERSION = $dotnetVersion
    }
}

# Set environment variables
$env:GITHUB_REPO_OWNER = $repoOwner
$env:GITHUB_REPO_NAME = $repoName
$env:GITHUB_BRANCH = $branch
$env:DEPLOYMENT_TARGET = $deployTarget
$env:ENABLE_CODE_SCANNING = $enableCodeScanning
$env:ENABLE_DEPENDENCY_REVIEW = $enableDependencyReview
$env:CREATE_PR = $createPR
$env:RUNNER_OS = $runnerOS

# Display configuration summary
Write-Host ""
Write-Host "✅ Environment Variables Configured:" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "GITHUB_REPO_OWNER           = $env:GITHUB_REPO_OWNER" -ForegroundColor White
Write-Host "GITHUB_REPO_NAME            = $env:GITHUB_REPO_NAME" -ForegroundColor White
Write-Host "GITHUB_BRANCH               = $env:GITHUB_BRANCH" -ForegroundColor White
Write-Host "DEPLOYMENT_TARGET           = $env:DEPLOYMENT_TARGET" -ForegroundColor White
Write-Host "ENABLE_CODE_SCANNING        = $env:ENABLE_CODE_SCANNING" -ForegroundColor White
Write-Host "ENABLE_DEPENDENCY_REVIEW    = $env:ENABLE_DEPENDENCY_REVIEW" -ForegroundColor White
Write-Host "CREATE_PR                   = $env:CREATE_PR" -ForegroundColor White
Write-Host "RUNNER_OS                   = $env:RUNNER_OS" -ForegroundColor White

if ($env:NODE_VERSION) {
    Write-Host "NODE_VERSION                = $env:NODE_VERSION" -ForegroundColor Cyan
}
if ($env:PYTHON_VERSION) {
    Write-Host "PYTHON_VERSION              = $env:PYTHON_VERSION" -ForegroundColor Cyan
}
if ($env:JAVA_VERSION) {
    Write-Host "JAVA_VERSION                = $env:JAVA_VERSION" -ForegroundColor Cyan
}
if ($env:DOTNET_VERSION) {
    Write-Host "DOTNET_VERSION              = $env:DOTNET_VERSION" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Execute the GitHub CI/CD Pipeline Generator prompt in your MCP client" -ForegroundColor White
Write-Host "2. Review the generated workflow and documentation" -ForegroundColor White
Write-Host "3. Merge the pull request or push changes" -ForegroundColor White
Write-Host "4. Configure required secrets in GitHub repository settings" -ForegroundColor White
Write-Host "5. Push code to trigger the first build" -ForegroundColor White
Write-Host ""

# Additional deployment-specific guidance
if ($deployTarget -ne "none") {
    Write-Host "📦 Deployment Configuration Required:" -ForegroundColor Magenta
    
    switch ($deployTarget) {
        "azure" {
            Write-Host "  Azure Secrets needed:" -ForegroundColor Gray
            Write-Host "    - AZURE_CREDENTIALS (Service Principal JSON)" -ForegroundColor Gray
            Write-Host "    - AZURE_WEBAPP_PUBLISH_PROFILE (for Web Apps)" -ForegroundColor Gray
            Write-Host "  Docs: https://docs.microsoft.com/azure/developer/github/connect-from-azure" -ForegroundColor Gray
        }
        "aws" {
            Write-Host "  AWS Secrets needed:" -ForegroundColor Gray
            Write-Host "    - AWS_ACCESS_KEY_ID" -ForegroundColor Gray
            Write-Host "    - AWS_SECRET_ACCESS_KEY" -ForegroundColor Gray
            Write-Host "    - AWS_REGION" -ForegroundColor Gray
            Write-Host "  Docs: https://github.com/aws-actions/configure-aws-credentials" -ForegroundColor Gray
        }
        "docker" {
            Write-Host "  Docker Registry Secrets needed:" -ForegroundColor Gray
            Write-Host "    - DOCKER_USERNAME" -ForegroundColor Gray
            Write-Host "    - DOCKER_PASSWORD" -ForegroundColor Gray
            Write-Host "  Or use GitHub Container Registry (ghcr.io) with GITHUB_TOKEN" -ForegroundColor Gray
        }
        "github-pages" {
            Write-Host "  GitHub Pages Configuration:" -ForegroundColor Gray
            Write-Host "    - Enable GitHub Pages in repository settings" -ForegroundColor Gray
            Write-Host "    - Set source to 'GitHub Actions'" -ForegroundColor Gray
            Write-Host "  Docs: https://docs.github.com/pages/getting-started-with-github-pages" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

Write-Host "✨ Ready to generate your CI/CD pipeline!" -ForegroundColor Green
Write-Host ""
