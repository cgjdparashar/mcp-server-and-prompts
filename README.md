# MCP Server & Prompts

[![CI/CD Pipeline](https://github.com/cgjdparashar/mcp-server-and-prompts/actions/workflows/ci-cd-pipeline.yml/badge.svg)](https://github.com/cgjdparashar/mcp-server-and-prompts/actions/workflows/ci-cd-pipeline.yml)

**Automated Build & Deployment**: This repository includes a complete CI/CD pipeline that validates prompts, runs security checks, and deploys documentation automatically.

## Available Prompts

### 1. Azure DevOps: Assign Current Sprint Task

- **Purpose**: A reusable prompt for the Azure DevOps MCP server to find an unassigned work item in the current sprint and assign it to you.
- **Prompt file**: `.github/prompts/azure-devops-assign-current-sprint-task.prompt.md`

### 2. GitHub CI/CD Pipeline Generator

- **Purpose**: Automatically detect your repository's technology stack and generate a complete CI/CD pipeline using GitHub Actions with build, test, and deployment stages.
- **Prompt file**: `.github/prompts/github-cicd-pipeline-generator.prompt.md`
- **Documentation**: [`docs/github-cicd-pipeline-generator.md`](docs/github-cicd-pipeline-generator.md)
- **Setup script**: `scripts/prompts/set-github-cicd-env.ps1`
- **Features**:
  - Detects tech stack (Node.js, Python, Java, .NET, Go, Ruby, PHP, Rust)
  - Identifies frameworks (React, Angular, Vue, Next.js, Django, Spring Boot, etc.)
  - Generates complete GitHub Actions workflow with build, test, security scanning
  - Supports deployment to Azure, AWS, Docker, GitHub Pages
  - Creates documentation and configuration templates

---

## Azure DevOps: Assign Current Sprint Task

Prerequisites
- Azure DevOps MCP server configured and connected in your MCP client.
- Set these environment variables in your client/session:
	- `AZDO_ORG_URL`: e.g., https://dev.azure.com/your-org
	- `AZDO_PROJECT`: Azure DevOps project name
	- `AZDO_TEAM`: Team name (for iteration lookup)
	- `AZDO_USER_EMAIL`: Your Azure DevOps user email
	- Optional: `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES` (comma-separated), `AZDO_PRIORITY_MIN`, `AZDO_PRIORITY_MAX`, `CONFIRM_ASSIGN`

What the prompt does
- Finds the current active iteration for your team
- Queries in-sprint, not-done work items, unassigned, optionally filtered by area/priority/types
- Ranks by priority, recent update, and smaller remaining work
- Dry-runs by default; assigns to you when `CONFIRM_ASSIGN=true`
- Adds a comment on assignment and returns a concise summary

Quick Start (PowerShell)
```powershell
# Set environment
$env:AZDO_ORG_URL = "https://dev.azure.com/your-org"
$env:AZDO_PROJECT = "YourProject"
$env:AZDO_TEAM = "YourTeam"
$env:AZDO_USER_EMAIL = "you@org.com"
$env:CONFIRM_ASSIGN = "true"  # set to "false" for dry-run

# Open the prompt in your MCP-aware client (instructions vary by client)
# For VS Code MCP clients, add/trigger the prompt from `prompts/azure-devops-assign-current-sprint-task.prompt.md`.
```

Notes
- If no suitable work item is found, the prompt reports why (e.g., none unassigned in current sprint).
- If assignment fails due to permissions or conflicts, you’ll get an error with the work item ID and reason.
# mcp-server-and-prompts