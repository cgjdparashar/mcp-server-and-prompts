# GitHub CI/CD Pipeline Generator - Quick Reference

## 🎯 One-Line Summary
Auto-detect tech stack and generate complete GitHub Actions CI/CD pipeline with build, test, security scanning, and deployment.

## ⚡ Quick Start

```powershell
# 1. Set environment variables
. .\scripts\prompts\set-github-cicd-env.ps1

# 2. Execute prompt through your MCP client
# .github/prompts/github-cicd-pipeline-generator.prompt.md

# 3. Configure secrets in GitHub repository settings

# 4. Merge PR and push to trigger first build
```

## 📋 Required Environment Variables

| Variable | Required | Example |
|----------|----------|---------|
| `GITHUB_REPO_OWNER` | ✅ Yes | `microsoft` |
| `GITHUB_REPO_NAME` | ✅ Yes | `vscode` |
| `DEPLOYMENT_TARGET` | ⚠️ Optional | `azure`, `aws`, `docker`, `github-pages`, `none` |

## 🔧 Supported Tech Stacks

| Category | Technologies |
|----------|-------------|
| **Languages** | Node.js, Python, Java, .NET, Go, Ruby, PHP, Rust |
| **Frontend** | React, Angular, Vue, Next.js, Svelte |
| **Backend** | Express, Django, Flask, FastAPI, Spring Boot, ASP.NET Core |
| **Testing** | Jest, Pytest, JUnit, xUnit, Cypress, Playwright |
| **Containers** | Docker, Docker Compose |

## 🚢 Deployment Options

| Target | Services | Required Secrets |
|--------|----------|------------------|
| **Azure** | Web Apps, Container Apps, Functions | `AZURE_CREDENTIALS` |
| **AWS** | Elastic Beanstalk, ECS, Lambda, S3 | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| **Docker** | Docker Hub, GitHub Container Registry | `DOCKER_USERNAME`, `DOCKER_PASSWORD` |
| **GitHub Pages** | Static hosting | None (uses `GITHUB_TOKEN`) |
| **None** | Build and test only | None |

## 📁 Generated Files

```
.github/
└── workflows/
    ├── ci-cd-pipeline.yml    # Main workflow
    └── README.md             # Pipeline docs

.env.example                  # Environment template
DEPLOYMENT.md                 # Deployment guide
```

## 🔐 Security Features

- ✅ CodeQL security scanning
- ✅ Dependency vulnerability audits
- ✅ Secrets management
- ✅ Pinned action versions
- ✅ Branch protection recommendations

## 📊 Pipeline Stages

```
┌─────────────┐
│  Checkout   │
└──────┬──────┘
       │
┌──────▼──────┐
│ Setup & Cache│
└──────┬──────┘
       │
┌──────▼──────┐
│   Install   │
└──────┬──────┘
       │
┌──────▼──────┐
│  Lint/Build │
└──────┬──────┘
       │
┌──────▼──────┐
│    Test     │
└──────┬──────┘
       │
┌──────▼──────┐
│  Security   │
└──────┬──────┘
       │
┌──────▼──────┐
│   Deploy    │ (if configured)
└─────────────┘
```

## 🎛️ Configuration Examples

### Node.js + React + Azure
```powershell
$env:GITHUB_REPO_OWNER = "myorg"
$env:GITHUB_REPO_NAME = "react-app"
$env:DEPLOYMENT_TARGET = "azure"
```

### Python + FastAPI + Docker
```powershell
$env:GITHUB_REPO_OWNER = "myorg"
$env:GITHUB_REPO_NAME = "fastapi-service"
$env:DEPLOYMENT_TARGET = "docker"
```

### Java + Spring Boot + AWS
```powershell
$env:GITHUB_REPO_OWNER = "myorg"
$env:GITHUB_REPO_NAME = "spring-service"
$env:DEPLOYMENT_TARGET = "aws"
```

## 🔍 Workflow Triggers

| Event | When |
|-------|------|
| **Push** | Code pushed to main/master |
| **Pull Request** | PR opened/updated to main/master |
| **Manual** | Triggered via Actions tab |
| **Schedule** | Optional: Cron-based builds |

## 📈 Expected Output

```json
{
  "analysis": {
    "techStack": {
      "languages": ["JavaScript", "TypeScript"],
      "runtime": "Node.js 18.x",
      "framework": "Next.js"
    }
  },
  "generatedFiles": [
    ".github/workflows/ci-cd-pipeline.yml",
    ".github/workflows/README.md",
    ".env.example",
    "DEPLOYMENT.md"
  ],
  "pullRequest": {
    "url": "https://github.com/owner/repo/pull/42"
  }
}
```

## 🆘 Common Issues

| Issue | Solution |
|-------|----------|
| Build fails | Check `package-lock.json` committed |
| Tests fail in CI | Verify env variables set |
| Deployment fails | Validate secrets configured |
| CodeQL fails | Check language support |

## 📚 Documentation Links

| Resource | Location |
|----------|----------|
| **Full Documentation** | `docs/github-cicd-pipeline-generator.md` |
| **Example Output** | `docs/examples/github-cicd-example-output.md` |
| **Setup Script** | `scripts/prompts/set-github-cicd-env.ps1` |
| **Prompt File** | `.github/prompts/github-cicd-pipeline-generator.prompt.md` |

## 💡 Pro Tips

1. ✅ Test in a feature branch first
2. ✅ Review generated workflow before merging
3. ✅ Configure secrets immediately after setup
4. ✅ Monitor first build closely
5. ✅ Enable branch protection rules
6. ✅ Set up build notifications
7. ✅ Use Dependabot for updates

## 🎯 Next Steps Checklist

- [ ] Run setup script to configure environment
- [ ] Execute prompt through MCP client
- [ ] Review generated workflow and documentation
- [ ] Configure required secrets in GitHub
- [ ] Merge pull request
- [ ] Push code to trigger first build
- [ ] Monitor workflow execution
- [ ] Set up notifications and monitoring
- [ ] Enable branch protection
- [ ] Configure Dependabot

## 📞 Need Help?

1. Check `docs/github-cicd-pipeline-generator.md`
2. Review `docs/examples/github-cicd-example-output.md`
3. Consult GitHub Actions documentation
4. Check workflow logs in Actions tab

---

**Version**: 1.0.0 | **Created**: December 2, 2025 | **Status**: ✅ Production Ready
