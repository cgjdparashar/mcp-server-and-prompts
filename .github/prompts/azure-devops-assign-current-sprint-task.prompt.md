Title: Show my tasks from the current sprint

Goal: Fetch all work items assigned to me in the current sprint.

Preconditions:
- MCP Azure DevOps server is connected and authenticated.
- Environment variables available: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_TEAM`, `AZDO_USER_EMAIL`.
- Optional variables: `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES` (comma-separated; default: User Story,Bug,Task,Issue), `AZDO_PRIORITY_MIN` (default: 0), `AZDO_PRIORITY_MAX` (default: 4).
- **Setup Script**: Run `scripts/prompts/set-azure-devops-env.ps1` to automatically configure all required environment variables.

System/Tool Context:
- Use Azure DevOps REST via MCP server tools.
- Respect org/project/team permissions.

Instructions:
0) First, execute the PowerShell script to set environment variables: `. .\scripts\prompts\set-azure-devops-env.ps1`
1) Identify the current active iteration for `AZDO_TEAM` in project `AZDO_PROJECT`.
2) Get all work items for that specific iteration using the iteration ID.
3) Filter the work items to only include those that are:
   - Assigned To equals `AZDO_USER_EMAIL`
   - Type in `AZDO_WORK_ITEM_TYPES` (default: User Story, Bug, Task, Issue)
   - State not in Done/Closed/Removed
   - Iteration Path matches the current sprint iteration path (must be exact match, not parent iteration)
   - Optional: `Area Path` equals `AZDO_AREA_PATH` if provided
   - Optional: `Priority` between `AZDO_PRIORITY_MIN` and `AZDO_PRIORITY_MAX`
4) Sort results by:
   - Highest `Priority`
   - Most recent `Updated Date`
   - Smallest `Remaining Work` (show quick wins first)
5) If no items found, explain clearly that there are no work items assigned to you in the current sprint.
6) Return a comprehensive list including for each work item:
   - Work item ID, title, type, state, priority
   - Iteration path, area path
   - Remaining work (if available)
   - Last updated date
   - URL to the item

Parameters (defaults):
- `AZDO_WORK_ITEM_TYPES`: "User Story,Bug,Task,Issue"
- `AZDO_PRIORITY_MIN`: 0
- `AZDO_PRIORITY_MAX`: 4

Example Invocation Notes (for MCP client):
- Run the setup script first: `. .\scripts\prompts\set-azure-devops-env.ps1`
- Then execute the prompt as a single action.
- If your MCP client supports variables, pass overrides where needed.

Expected Output (JSON-like fields):
- `sprint`: { name, path, id }
- `workItems`: [{ id, title, type, state, priority, remainingWork, lastUpdated, url }]
- `totalCount`: number

Note: Only show work items from the current sprint. Do not mention or reference work items from other iterations or explain what was excluded.
