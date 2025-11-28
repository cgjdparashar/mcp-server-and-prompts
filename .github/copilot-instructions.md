# AI Coding Agent Instructions for `mcp-server-and-prompts`

This repo provides MCP (Model Context Protocol) prompt definitions for Azure DevOps workflows. There is no application runtime; productivity comes from knowing the prompt structure, required environment variables, and how MCP clients execute prompts.

## Big Picture
- Prompts live under `prompts/` and are executed by an MCP-aware client (e.g., VS Code with an Azure DevOps MCP server).
- Core prompt: `prompts/azure-devops-assign-current-sprint-task.prompt.md` — finds an unassigned in-sprint work item and assigns it to the authenticated user.
- `README.md` is the source of truth for setup, env vars, and quick start.

## Key Files & Conventions
- Use `.prompt.md` for prompt sources; keep them parameterized and deterministic.
- `prompts/azure-devops-assign-current-sprint-task.prompt.md`: stepwise flow with dry-run safety by default.
- `.vscode/mcp.json` (if present locally) may define MCP client configuration; do not commit secrets.
- Keep org/project/team values externalized via env vars rather than hardcoding.

## Prompt Flow Pattern
- Title/Goal: clear action and outcome.
- Preconditions: MCP Azure DevOps server connected; env vars set.
- Steps: identify current team iteration → query candidate work items → rank → select first unassigned → optionally assign → summarize.
- Ranking: Priority desc, Updated Date desc, Remaining Work asc.
- Safety: Dry-run unless `CONFIRM_ASSIGN=true`; add an assignment comment when applying changes.

## Required Env Vars (per README)
- `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_TEAM`, `AZDO_USER_EMAIL`.
- Optional filters: `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES` (comma-separated), `AZDO_PRIORITY_MIN`, `AZDO_PRIORITY_MAX`.
- Control: `CONFIRM_ASSIGN` ("false" default dry-run; set "true" to assign).

## Developer Workflow
- Add or update prompts under `prompts/` following the flow and env var pattern.
- When changing required vars or behavior, update `README.md` accordingly.
- Keep prompts idempotent and avoid reassigning items already owned.
- Explicitly filter out Done/Closed/Removed states.

## Integration Points
- External MCP Azure DevOps server must support: current iteration lookup, WIQL queries/filtering, work item updates (AssignedTo, comments).
- Team lookup uses `AZDO_TEAM` by name; avoid hardcoded iteration paths.

## Examples
- Quick start (PowerShell):
  ```powershell
  $env:AZDO_ORG_URL = "https://dev.azure.com/your-org"
  $env:AZDO_PROJECT = "YourProject"
  $env:AZDO_TEAM = "YourTeam"
  $env:AZDO_USER_EMAIL = "you@org.com"
  $env:CONFIRM_ASSIGN = "true"  # set to "false" for dry-run
  ```
- Typical ranking and selection: prioritize highest `Priority`, most recently `Updated`, then smallest `Remaining Work`.

## Extending
- New prompts: follow `.prompt.md` naming; include Title, Goal, Preconditions, Steps, Validation, Parameters, Expected Output.
- Consider separate read-only (report) variants vs assignment flows.
- Keep outputs concise and structured for MCP client parsing.

Feedback: If anything is unclear (e.g., team name resolution vs IDs, state filters, expected output fields), open an issue or request a refinement to the prompt and `README.md`.