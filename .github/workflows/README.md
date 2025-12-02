# CI/CD Pipeline Documentation

## Overview

This GitHub Actions workflow provides automated build, validation, security scanning, and deployment for the MCP Server & Prompts repository.

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Trigger (Push/PR/Manual)                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 1: Validate and Build                       │
│  • Validate repository structure                             │
│  • Validate prompt files (.prompt.md)                        │
│  • Validate PowerShell scripts (.ps1)                        │
│  • Validate documentation (.md)                              │
│  • Generate build report                                     │
│  • Create deployment package                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 2: Security Scan                            │
│  • Markdown linting                                          │
│  • Check for sensitive data                                  │
│  • Validate file permissions                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 3: Deploy (main/devops branch only)         │
│  • Download build artifacts                                  │
│  • Prepare documentation site                                │
│  • Deploy to GitHub Pages                                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Job 4: Notify                                   │
│  • Build status summary                                      │
│  • Pipeline completion notification                          │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Jobs

### 1. Validate and Build

**Purpose**: Validate repository structure and create deployment artifacts

**Steps**:
- ✅ Checkout code from repository
- ✅ Setup Node.js 18.x environment
- ✅ Validate directory structure (.github/prompts, docs, scripts)
- ✅ Validate all `.prompt.md` files for required sections
- ✅ Validate PowerShell scripts (`.ps1` files)
- ✅ Validate documentation files (`.md` files)
- ✅ Generate comprehensive build report
- ✅ Create deployment package with all artifacts
- ✅ Upload build report (30 days retention)
- ✅ Upload deployment package (90 days retention)

**Validations Performed**:
- Prompt files must have: Title, Goal/Purpose, Preconditions
- PowerShell scripts must contain environment variable usage
- README.md must exist and have content
- Documentation files must be present in docs/

**Artifacts**:
- `build-report/BUILD_REPORT.md` - Detailed validation results
- `deployment-package/` - Ready-to-deploy files

### 2. Security Scan

**Purpose**: Perform security and quality checks

**Steps**:
- 🔐 Markdown linting with markdownlint-cli2
- 🔐 Scan for sensitive data patterns (API keys, tokens, passwords)
- 🔐 Validate file permissions

**Security Checks**:
- Password patterns
- API key patterns
- Token patterns
- Secret patterns
- Bearer tokens
- AWS access keys

### 3. Deploy

**Purpose**: Deploy documentation to GitHub Pages

**Conditions**:
- Only runs on `main` or `devops-build-deploy-code` branches
- Requires successful completion of build and security jobs

**Steps**:
- 📦 Download deployment package
- 📦 Configure GitHub Pages
- 📦 Prepare documentation site with HTML interface
- 📦 Upload pages artifact
- 📦 Deploy to GitHub Pages
- 📦 Generate deployment summary

**Deployed Site Includes**:
- Documentation landing page
- All markdown documentation
- Build reports
- Deployment metadata (JSON)
- Links to prompts and scripts

### 4. Notify

**Purpose**: Provide pipeline status summary

**Steps**:
- 📬 Summarize all job results
- 📬 Display overall pipeline status
- 📬 Provide workflow run link

## Triggers

The workflow runs on:

1. **Push Events**
   - Branch: `main`
   - Branch: `devops-build-deploy-code`

2. **Pull Request Events**
   - Target: `main`
   - Target: `devops-build-deploy-code`

3. **Manual Trigger**
   - Via GitHub Actions UI (workflow_dispatch)

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `NODE_VERSION` | `18.x` | Node.js runtime version |

## Permissions

### Default Jobs
- `contents: read` - Read repository contents

### Deploy Job
- `contents: read` - Read repository contents
- `pages: write` - Write to GitHub Pages
- `id-token: write` - OIDC token for authentication

## Artifacts

### Build Report
- **Name**: `build-report`
- **Retention**: 30 days
- **Contents**: BUILD_REPORT.md with validation results

### Deployment Package
- **Name**: `deployment-package`
- **Retention**: 90 days
- **Contents**:
  - `.github/` - Workflow and prompt files
  - `docs/` - Documentation
  - `scripts/` - PowerShell scripts
  - `README.md` - Main readme
  - `DEPLOYMENT_INFO.json` - Deployment metadata

## GitHub Pages Deployment

### URL Structure
- **Production**: `https://<username>.github.io/<repository>/`
- **Current**: `https://cgjdparashar.github.io/mcp-server-and-prompts/`

### Site Contents
- 📄 **index.html** - Landing page with navigation
- 📚 **docs/** - All documentation files
- 📦 **deployment/** - Deployment package and metadata
- 🔗 **Links** - Repository, Actions, and artifact links

## Monitoring

### View Workflow Runs
1. Navigate to repository on GitHub
2. Click **Actions** tab
3. Select **CI/CD Pipeline - Build and Deploy**
4. View individual runs and logs

### Check Deployment Status
1. Go to **Actions** tab
2. Find the workflow run
3. Check **Deploy** job status
4. Visit the Pages URL shown in deployment summary

### Download Artifacts
1. Open workflow run
2. Scroll to **Artifacts** section
3. Download `build-report` or `deployment-package`

## Troubleshooting

### Build Fails - Missing Files

**Error**: "❌ .github/prompts directory missing"

**Solution**:
```bash
mkdir -p .github/prompts
# Add your .prompt.md files
```

### Build Fails - Invalid Prompt Files

**Error**: "⚠️ Missing title" or "⚠️ Missing goal/purpose"

**Solution**: Ensure your `.prompt.md` files include:
```markdown
Title: Your Prompt Title

Goal: What this prompt does

Preconditions:
- Requirement 1
- Requirement 2
```

### Security Scan Warnings

**Error**: "⚠️ Potential sensitive data found"

**Solution**: 
- Review flagged files
- Remove actual secrets/credentials
- If false positive (documentation), it's safe to proceed

### Deployment Fails - Pages Not Enabled

**Error**: Pages deployment fails

**Solution**:
1. Go to repository **Settings**
2. Click **Pages** in sidebar
3. Under **Source**, select **GitHub Actions**
4. Re-run workflow

### Workflow Not Triggering

**Solution**:
1. Check branch name matches `main` or `devops-build-deploy-code`
2. Ensure workflow file is in `.github/workflows/`
3. Verify YAML syntax is correct
4. Check Actions is enabled in repository settings

## Local Testing

### Validate Prompt Files Locally

```bash
# Check prompt structure
for file in .github/prompts/*.prompt.md; do
  echo "Checking: $file"
  grep -q "^Title:" "$file" && echo "  ✅ Has title" || echo "  ❌ Missing title"
  grep -q -i "goal" "$file" && echo "  ✅ Has goal" || echo "  ❌ Missing goal"
done
```

### Validate PowerShell Scripts

```powershell
# Test script syntax
Get-ChildItem -Path scripts -Filter *.ps1 -Recurse | ForEach-Object {
    Write-Host "Checking: $($_.Name)"
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errors)
    if ($errors) {
        Write-Host "  ❌ Syntax errors found" -ForegroundColor Red
        $errors
    } else {
        Write-Host "  ✅ Syntax OK" -ForegroundColor Green
    }
}
```

### Test Markdown Linting

```bash
# Install markdownlint-cli2
npm install -g markdownlint-cli2

# Run linting
markdownlint-cli2 "**/*.md" "#node_modules"
```

## Manual Deployment

To manually trigger deployment:

1. Go to **Actions** tab
2. Select **CI/CD Pipeline - Build and Deploy**
3. Click **Run workflow** button
4. Select branch (`main` or `devops-build-deploy-code`)
5. Click **Run workflow**

## Customization

### Change Node.js Version

Edit `.github/workflows/ci-cd-pipeline.yml`:

```yaml
env:
  NODE_VERSION: '20.x'  # Change to desired version
```

### Add More Validations

Add steps to `validate-and-build` job:

```yaml
- name: Custom Validation
  run: |
    echo "Running custom validation..."
    # Your validation commands
```

### Modify Deployment Target

To deploy elsewhere instead of GitHub Pages:

1. Replace `deploy` job with your target (Azure, AWS, etc.)
2. Update permissions and environment accordingly
3. Add required secrets in repository settings

## Best Practices

1. ✅ **Keep prompts standardized** - Use consistent Title/Goal/Preconditions format
2. ✅ **Document everything** - Add README files for each directory
3. ✅ **Test locally first** - Run validations before pushing
4. ✅ **Use semantic commits** - `feat:`, `fix:`, `docs:`, etc.
5. ✅ **Review security warnings** - Always check flagged sensitive data
6. ✅ **Monitor workflow runs** - Check Actions tab regularly
7. ✅ **Keep artifacts clean** - Old artifacts are auto-deleted after retention period

## Workflow Status Badge

Add to your README.md:

```markdown
[![CI/CD Pipeline](https://github.com/cgjdparashar/mcp-server-and-prompts/actions/workflows/ci-cd-pipeline.yml/badge.svg)](https://github.com/cgjdparashar/mcp-server-and-prompts/actions/workflows/ci-cd-pipeline.yml)
```

## Support

For issues with the CI/CD pipeline:

1. Check workflow run logs in Actions tab
2. Review this documentation
3. Test validations locally
4. Check GitHub Actions status page
5. Open an issue in the repository

---

**Last Updated**: December 2, 2025  
**Workflow Version**: 1.0.0  
**Status**: ✅ Production Ready
