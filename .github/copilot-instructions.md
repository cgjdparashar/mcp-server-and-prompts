# AI Coding Agent Instructions for `mcp-server-and-prompts`

This repo provides **MCP (Model Context Protocol) prompt definitions** orchestrating three MCP server ecosystems: Azure DevOps, Playwright testing, and MySQL queries. There is no standalone application runtime; instead, prompts are executed by MCP-aware clients (e.g., VS Code with MCP integrations). Focus on understanding prompt structure, environment variables, file location constraints, and how MCP clients bridge your workspace with external services.

## Architecture Overview

**Multi-MCP Design**: `.vscode/mcp.json` configures three independent servers—`microsoft/azure-devops-mcp`, `microsoft/playwright-mcp`, and MySQL. Each prompt targets one or more servers via their exposed tools. Key directories:
- `/.github/prompts/`: All `.prompt.md` files (7 total across Azure DevOps, Playwright, MySQL domains)
- `/.vscode/mcp.json`: MCP server configurations and input dialogs (do not commit live credentials here)
- `/project/`: **Mandatory for Playwright and MySQL prompts**—application code, test flows, and all artifacts must live within this folder

## Prompt Categories & Patterns

### Azure DevOps Prompts (5 total)
- **Core**: `azure-devops-assign-current-sprint-task.prompt.md` — Find unassigned sprint work, rank by Priority/Updated/RemainingWork, assign to user.
- **Variants**: `azure-devops-get-task-details.prompt.md` (fetch single item), `azure-devops-update-work-item.prompt.md` (modify fields), `azure-devops-assign-by-id.prompt.md` (direct assignment).
- **Env Vars**: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_TEAM`, `AZDO_USER_EMAIL` (required); optional: `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES`, `AZDO_PRIORITY_MIN/MAX`, `CONFIRM_ASSIGN`.
- **Safety**: Dry-run by default (`CONFIRM_ASSIGN=false`). Always add assignment comments.
- **Filters**: Explicitly exclude Done/Closed/Removed states. Match iteration paths exactly (no parent-iteration fallback).

### Playwright Prompts (2 total)
- **Flow Execution**: `playwright-run-flow.prompt.md` — Execute ephemeral user-provided flows (no test file persistence).
- **Diagnostic Cycle**: `playwright-diagnose-fix-retest.prompt.md` — Analyze failures, propose fixes, re-run assertions.
- **CRITICAL Constraint**: Application under test MUST exist in `/project/src/`. All artifacts (screenshots, traces, logs) MUST save to `/project/traces/` or `/project/screenshots/`.
- **Input Validation**: Prompts scan `/project/src/` for selectors, templates, routes; cross-reference steps against actual application structure before execution.
- **Steps Parameter**: Each step has `action` (goto|click|fill|select|press|waitFor|assert), `selector`, optional `value`, `waitUntil`, `timeoutMs`, `assert` object.

### MySQL Prompt (1 total)
- **Query Execution**: `mysql-run-query.prompt.md` — Execute arbitrary SQL (INSERT, UPDATE, DELETE, DDL, SELECT).
- **Connection**: Credentials in `mcp.json` (Azure-hosted: `moderswemysql02.mysql.database.azure.com`, database: `dashboard`).
- **File Context**: If query results require file storage, save to `/project/` (e.g., `/project/results.json`).

## Common Patterns

**Parameterization**: All prompts externalize config via environment variables or parameters—no hardcoding org names, project IDs, or credentials.

**Idempotency**: Azure DevOps prompts avoid reassigning already-owned items. Playwright prompts run ephemeral (no state mutation). MySQL queries are explicit (no auto-retry).

**Folder Location Rule**: Playwright and MySQL prompts enforce `/project/` as workspace root for applications/artifacts. If `/project/src/` does not exist, Playwright prompts error immediately.

**Ranked Output**: Azure DevOps queries return results sorted by Priority (desc), Updated Date (desc), Remaining Work (asc)—high-priority, recent, quick wins first.

## Developer Workflow

**Adding a Prompt**:
1. Create `/.github/prompts/<domain>-<action>.prompt.md` (e.g., `azure-devops-custom-query.prompt.md`).
2. Include sections: Title, Goal, Preconditions, System/Tool Context, Instructions (0-N), Validation & Safety, Parameters, Expected Output, Usage Notes.
3. Externalize all config via env vars (Azure DevOps) or parameters (Playwright).
4. Document any new env vars in `README.md`.

**Setup Script**: `scripts/prompts/set-azure-devops-env.ps1` automates environment variable configuration (PowerShell only; reference it in Azure DevOps prompts).

**Testing Prompts**:
- Verify env var presence and correct MCP server configuration before running.
- For Playwright: ensure `/project/src/` exists and contains application code.
- For Azure DevOps: test with `CONFIRM_ASSIGN=false` (dry-run) first.
- Validate output structure matches "Expected Output" schema.

## Integration Points

- **Azure DevOps MCP Server**: Requires iteration lookup by team name, WIQL query filtering, work item updates (AssignedTo, comments), priority/state enumerations.
- **Playwright MCP Server**: Supports goto, click, fill, select, press, waitFor, assert actions; screenshot/trace capture if enabled.
- **MySQL MCP Server**: Direct SQL execution (INSERT/UPDATE/DELETE/DDL supported; read-only mode enforced via env flags).
- **Team Resolution**: Azure DevOps prompts use team names (e.g., `AZDO_TEAM="MyTeam"`) not IDs; iteration paths must be exact matches.