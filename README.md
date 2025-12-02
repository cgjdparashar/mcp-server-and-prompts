# MCP Server & Prompts

This repository provides **MCP (Model Context Protocol) prompt definitions** for orchestrating three MCP server ecosystems: Azure DevOps, Playwright testing, and MySQL queries. The prompts enable automation of common development workflows including work item management, end-to-end testing, and database operations.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Available Prompts](#available-prompts)
- [How to Use Prompts - Step by Step](#how-to-use-prompts---step-by-step)
- [Troubleshooting](#troubleshooting)

---

## Architecture Overview

This repository uses **Model Context Protocol (MCP)** to connect AI assistants (like GitHub Copilot) with external services through three MCP servers:

```
┌─────────────────────────────────────────────────────┐
│          AI Assistant (VS Code + MCP Client)        │
└────────────┬────────────────────────────────────────┘
             │
             ├──► Azure DevOps MCP Server
             │    (Work items, sprints, assignments)
             │
             ├──► Playwright MCP Server
             │    (Browser automation, testing)
             │
             └──► MySQL MCP Server
                  (Database queries, CRUD operations)
```

**Key Concepts:**
- **MCP Servers**: Backend services that expose tools/capabilities
- **Prompts**: Reusable automation scripts in `.github/prompts/`
- **Parameters**: Environment variables or prompt parameters that configure behavior
- **Tools**: Individual actions exposed by MCP servers

---

## Prerequisites

### 1. MCP-Enabled Client
You need an AI assistant or IDE that supports MCP:
- **VS Code** with GitHub Copilot and MCP extension
- Other MCP-compatible clients (Claude Desktop, etc.)

### 2. MCP Server Configuration
The `.vscode/mcp.json` file configures three servers (Azure DevOps, Playwright, MySQL).

### 3. Environment Variables (Azure DevOps)
Required for Azure DevOps prompts:
- `AZDO_ORG_URL`: e.g., `https://dev.azure.com/your-org`
- `AZDO_PROJECT`: Project name
- `AZDO_TEAM`: Team name
- `AZDO_USER_EMAIL`: Your email

Optional:
- `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES`, `AZDO_PRIORITY_MIN/MAX`, `CONFIRM_ASSIGN`

### 4. Application Structure (Playwright/MySQL)
For Playwright and MySQL prompts:
- **Application MUST be in `/project/` folder**
- Test application code: `/project/src/`
- Artifacts (screenshots, traces): `/project/traces/`, `/project/screenshots/`

---

## Initial Setup

### Step 1: Configure MCP Servers

1. **Open VS Code** in this repository
2. **Install MCP extension** if not already installed
3. **Verify `.vscode/mcp.json`** exists and is properly configured
4. **Restart VS Code** to load MCP servers

When prompted, provide:
- **Azure DevOps Org**: Your organization name (e.g., `contoso`)
- **Azure DevOps Domains**: Space-separated domains to enable (e.g., `core work repositories`)

### Step 2: Set Azure DevOps Environment Variables (PowerShell)

Use the provided setup script:

```powershell
# Navigate to repository root
cd "c:\VickyJD\CG\Project\SWE-Project Gen AI\repo\mcp-server-and-prompts"

# Run the setup script
. .\scripts\prompts\set-azure-devops-env.ps1
```

Or set manually:
```powershell
$env:AZDO_ORG_URL = "https://dev.azure.com/your-org"
$env:AZDO_PROJECT = "YourProject"
$env:AZDO_TEAM = "YourTeam"
$env:AZDO_USER_EMAIL = "you@example.com"
$env:CONFIRM_ASSIGN = "false"  # Dry-run mode
```

### Step 3: Verify Application Structure (Playwright/MySQL)

Ensure your test application exists:
```
/project/
├── src/              # Application source code (REQUIRED)
│   ├── app.py        # Example: Flask application
│   ├── templates/    # HTML templates
│   └── README.md     # Application documentation
├── traces/           # Playwright traces (auto-created)
├── screenshots/      # Test screenshots (auto-created)
└── requirements.txt  # Dependencies
```

---

## Available Prompts

### Azure DevOps Prompts

Located in `.github/prompts/`, these prompts automate Azure DevOps work item management:

| Prompt File | Purpose | Use Case |
|------------|---------|----------|
| `azure-devops-assign-current-sprint-task.prompt.md` | Find and assign unassigned sprint work items | Auto-assign next task to yourself |
| `azure-devops-get-task-details.prompt.md` | Fetch detailed information about a work item | View task details before starting work |
| `azure-devops-update-work-item.prompt.md` | Update work item fields (status, priority, etc.) | Change task status, add comments |
| `implement-work-azure-devops-assign-by-id.prompt.md` | Assign a specific work item by ID | Directly assign a known task |

### Playwright Testing Prompts

| Prompt File | Purpose | Use Case |
|------------|---------|----------|
| `playwright-run-flow.prompt.md` | Execute ephemeral test flows without saving test files | Quick validation of user flows |
| `playwright-diagnose-fix-retest.prompt.md` | Analyze test failures, propose fixes, and re-run | Debug and fix failing tests |

### MySQL Database Prompts

| Prompt File | Purpose | Use Case |
|------------|---------|----------|
| `mysql-run-query.prompt.md` | Execute SQL queries (SELECT, INSERT, UPDATE, DELETE, DDL) | Query database, modify data |

---

## How to Use Prompts - Step by Step

### 🎯 Scenario 1: Assign Next Sprint Task (Azure DevOps)

**Goal**: Find and assign the highest-priority unassigned task from the current sprint.

#### Step 1: Set Environment Variables
```powershell
# Run the setup script
. .\scripts\prompts\set-azure-devops-env.ps1

# Or set manually
$env:AZDO_ORG_URL = "https://dev.azure.com/your-org"
$env:AZDO_PROJECT = "MyProject"
$env:AZDO_TEAM = "MyTeam"
$env:AZDO_USER_EMAIL = "you@example.com"
$env:CONFIRM_ASSIGN = "false"  # Start with dry-run
```

#### Step 2: Open the Prompt
1. In VS Code, open `.github/prompts/azure-devops-assign-current-sprint-task.prompt.md`
2. Or invoke via GitHub Copilot: Type `@workspace` and reference the prompt

#### Step 3: Execute the Prompt
- **In VS Code Chat**: Ask "Use the azure-devops-assign-current-sprint-task prompt to find my next task"
- The AI will:
  1. Query the current sprint iteration
  2. Find unassigned work items
  3. Rank by priority, recent updates, and remaining work
  4. Return the top candidate

#### Step 4: Review Dry-Run Results
The output will show:
```json
{
  "workItem": {
    "id": 12345,
    "title": "Implement login feature",
    "type": "Task",
    "priority": 1,
    "remainingWork": 4,
    "url": "https://dev.azure.com/..."
  },
  "action": "DRY_RUN - Would assign to you@example.com"
}
```

#### Step 5: Confirm Assignment
If the task looks good:
```powershell
$env:CONFIRM_ASSIGN = "true"
```
Then re-run the prompt to actually assign the task.

#### Step 6: Verify
Check Azure DevOps to confirm:
- Task is assigned to you
- A comment was added: "Auto-assigned via MCP prompt"

---

### 🎭 Scenario 2: Test Application Flow (Playwright)

**Goal**: Validate the order creation flow in the dashboard application.

#### Step 1: Ensure Application is Running
```powershell
# Navigate to project folder
cd project

# Start the application
python src/app.py
# Application runs at http://localhost:5000
```

#### Step 2: Verify Folder Structure
Confirm `/project/src/` exists with your application code:
```
/project/src/
├── app.py
├── templates/
│   └── index.html
└── database.py
```

#### Step 3: Open the Prompt
Open `.github/prompts/playwright-run-flow.prompt.md`

#### Step 4: Define Test Steps
In VS Code Chat, provide parameters:
```
Use playwright-run-flow prompt with these parameters:

BASE_URL: http://localhost:5000
HEADLESS: false
TRACE: true
STEPS:
[
  { "action": "goto", "waitUntil": "networkidle" },
  { "action": "fill", "selector": "#customer_name", "value": "John Doe" },
  { "action": "fill", "selector": "#product", "value": "Laptop" },
  { "action": "fill", "selector": "#quantity", "value": "2" },
  { "action": "click", "selector": "button[type=submit]" },
  { "action": "assert", "assert": { "type": "textContains", "selector": "body", "value": "Order created successfully" } }
]
```

#### Step 5: Execute the Test
The AI will:
1. Analyze `/project/src/` to understand application structure
2. Validate selectors against actual HTML templates
3. Launch browser and execute each step
4. Capture screenshots if `TRACE: true`
5. Return detailed results

#### Step 6: Review Results
```json
{
  "summary": { "totalSteps": 6, "passed": 6, "failed": 0, "elapsedMs": 3245 },
  "results": [
    { "index": 0, "action": "goto", "status": "passed", "durationMs": 1200 },
    { "index": 1, "action": "fill", "status": "passed", "durationMs": 150 }
  ],
  "artifacts": {
    "screenshots": ["/project/screenshots/step-0.png"]
  },
  "finalUrl": "http://localhost:5000/"
}
```

#### Step 7: Check Artifacts
If `TRACE: true`, screenshots are saved to `/project/screenshots/`

---

### 🎭 Scenario 3: Diagnose and Fix Failing Test (Playwright)

**Goal**: A test is failing, find the root cause and fix it.

#### Step 1: Run Initial Test
First run the test flow using `playwright-run-flow.prompt.md` (see Scenario 2)

#### Step 2: Capture Failure Details
Note the failure:
```json
{
  "index": 4,
  "action": "click",
  "selector": "button[type=submit]",
  "status": "failed",
  "message": "Element not found: button[type=submit]"
}
```

#### Step 3: Open Diagnose Prompt
Open `.github/prompts/playwright-diagnose-fix-retest.prompt.md`

#### Step 4: Provide Failure Context
In VS Code Chat:
```
Use playwright-diagnose-fix-retest prompt to analyze this failure:

FAILED_STEP: { "action": "click", "selector": "button[type=submit]" }
ERROR: "Element not found: button[type=submit]"
BASE_URL: http://localhost:5000
```

#### Step 5: AI Analysis
The AI will:
1. Analyze `/project/src/templates/` for form structure
2. Identify the correct selector
3. Propose fix: "Use `button.btn-primary` instead"
4. Automatically re-run the test with corrected selector

#### Step 6: Apply Fix
If test passes with corrected selector:
- Update your test definition
- Or update application HTML for consistency

---

### 🗄️ Scenario 4: Query Database (MySQL)

**Goal**: Retrieve orders from the database with pagination.

#### Step 1: Verify MySQL MCP Server
Confirm `.vscode/mcp.json` has MySQL configuration with correct credentials.

#### Step 2: Open the Prompt
Open `.github/prompts/mysql-run-query.prompt.md`

#### Step 3: Define Query
In VS Code Chat:
```
Use mysql-run-query prompt to execute:

SQL: SELECT id, customer_name, product, quantity, status, order_date FROM orders WHERE status = 'pending' ORDER BY order_date DESC
LIMIT: 20
OFFSET: 0
READ_ONLY: true
```

#### Step 4: Execute Query
The AI will:
1. Validate query is read-only (SELECT)
2. Execute via MySQL MCP server
3. Apply pagination
4. Return structured results

#### Step 5: Review Results
```json
{
  "meta": {
    "columns": ["id", "customer_name", "product", "quantity", "status", "order_date"],
    "rowCount": 15,
    "limit": 20,
    "offset": 0,
    "elapsedMs": 45
  },
  "rows": [
    [1, "John Doe", "Laptop", 2, "pending", "2025-12-02T10:30:00Z"],
    [2, "Jane Smith", "Mouse", 5, "pending", "2025-12-02T09:15:00Z"]
  ]
}
```

#### Step 6: Perform Write Operations (Optional)
For INSERT/UPDATE/DELETE:
```
Use mysql-run-query prompt:

SQL: UPDATE orders SET status = 'processing' WHERE id = 1
READ_ONLY: false
```

---

### 🔧 Scenario 5: Update Work Item Status (Azure DevOps)

**Goal**: Mark a task as "In Progress" and add a comment.

#### Step 1: Get Work Item ID
First, find the work item using `azure-devops-assign-current-sprint-task.prompt.md` or manually from Azure DevOps.

#### Step 2: Open Update Prompt
Open `.github/prompts/azure-devops-update-work-item.prompt.md`

#### Step 3: Define Updates
In VS Code Chat:
```
Use azure-devops-update-work-item prompt:

WORK_ITEM_ID: 12345
FIELDS: {
  "System.State": "Active",
  "Microsoft.VSTS.Scheduling.RemainingWork": "6"
}
COMMENT: "Started implementation. Estimating 6 hours remaining."
```

#### Step 4: Execute Update
The AI will:
1. Validate field names and values
2. Update the work item via Azure DevOps MCP server
3. Add the comment
4. Return updated work item details

#### Step 5: Verify
Check Azure DevOps:
- State changed to "Active"
- Remaining Work updated to 6
- Comment added with timestamp

---

## Troubleshooting

### Azure DevOps Issues

**Problem**: "No work items found in current sprint"
- **Solution**: 
  - Verify `AZDO_TEAM` matches your Azure DevOps team name exactly
  - Check sprint dates (is there an active sprint?)
  - Confirm iteration path: Run `set-azure-devops-env.ps1` and verify settings

**Problem**: "Authentication failed"
- **Solution**: 
  - Re-run `.vscode/mcp.json` setup
  - Provide correct organization name when prompted
  - Ensure you have Azure DevOps access

**Problem**: "Assignment failed - work item already assigned"
- **Solution**: The item is already assigned to someone else. Use `azure-devops-update-work-item` to reassign if needed.

### Playwright Issues

**Problem**: "Application code must be in /project/src/ folder"
- **Solution**: 
  - Move your application to `/project/src/`
  - Ensure `/project/src/app.py` or equivalent exists
  - Check folder structure matches requirements

**Problem**: "Element not found" errors
- **Solution**: 
  - Use `playwright-diagnose-fix-retest` prompt to auto-fix
  - Verify selectors match your HTML structure
  - Check if application is running at correct URL

**Problem**: "Screenshots not saving"
- **Solution**: 
  - Ensure `/project/screenshots/` directory exists (create if needed)
  - Check `TRACE: true` is set in parameters
  - Verify write permissions

### MySQL Issues

**Problem**: "Connection refused"
- **Solution**: 
  - Check `.vscode/mcp.json` MySQL credentials
  - Verify database server is accessible
  - Test connection: `mysql -h HOST -u USER -p`

**Problem**: "Query rejected - mutation not allowed"
- **Solution**: 
  - Set `READ_ONLY: false` for INSERT/UPDATE/DELETE
  - Verify MySQL MCP server allows write operations
  - Check `ALLOW_INSERT_OPERATION`, `ALLOW_UPDATE_OPERATION` flags in `mcp.json`

### General MCP Issues

**Problem**: "MCP server not responding"
- **Solution**: 
  - Restart VS Code
  - Check terminal output for MCP server errors
  - Verify `npx` and Node.js are installed

**Problem**: "Prompt not found"
- **Solution**: 
  - Ensure prompt file exists in `.github/prompts/`
  - Use full prompt name when referencing
  - Reload VS Code window

---

## Additional Resources

- **MCP Documentation**: https://modelcontextprotocol.io
- **Azure DevOps MCP Server**: https://github.com/microsoft/azure-devops-mcp
- **Playwright MCP Server**: https://github.com/microsoft/playwright-mcp
- **MySQL MCP Server**: https://github.com/benborla29/mcp-server-mysql

---

## Contributing

To add a new prompt:

1. Create `.github/prompts/<domain>-<action>.prompt.md`
2. Follow existing prompt structure (Title, Goal, Preconditions, Instructions, etc.)
3. Document all parameters and expected outputs
4. Test thoroughly with MCP client
5. Update this README with usage instructions

---

## License

See LICENSE file for details.
