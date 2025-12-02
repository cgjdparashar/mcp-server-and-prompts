# Azure DevOps Environment Variables for MCP Prompts
# This script sets up the required environment variables for Azure DevOps MCP prompts
powershell -ExecutionPolicy Bypass -File .\scripts\prompts\set-azure-devops-env.ps1
# Required Variables
$env:AZDO_ORG_URL = "https://dev.azure.com/Modern-SWE-on-Agentic-Platforms"
$env:AZDO_PROJECT = "Modern-SWE"
$env:AZDO_TEAM = "Modern-SWE Team"
$env:AZDO_USER_EMAIL = "jankidas.parashar@CapgeminiCTCL.onmicrosoft.com"

# Optional Variables - Uncomment and modify as needed
# $env:AZDO_AREA_PATH = ""
# $env:AZDO_WORK_ITEM_TYPES = "User Story,Bug,Task"
# $env:AZDO_PRIORITY_MIN = "0"
# $env:AZDO_PRIORITY_MAX = "4"

# Control Variables
$env:CONFIRM_ASSIGN = "false"  # Set to "true" to actually assign work items (default is dry-run)

Write-Host "✓ Azure DevOps environment variables set successfully" -ForegroundColor Green
Write-Host "  Organization: $env:AZDO_ORG_URL" -ForegroundColor Cyan
Write-Host "  Project: $env:AZDO_PROJECT" -ForegroundColor Cyan
Write-Host "  Team: $env:AZDO_TEAM" -ForegroundColor Cyan
Write-Host "  User: $env:AZDO_USER_EMAIL" -ForegroundColor Cyan
Write-Host "  Confirm Assign: $env:CONFIRM_ASSIGN" -ForegroundColor $(if ($env:CONFIRM_ASSIGN -eq "true") { "Yellow" } else { "Gray" })
