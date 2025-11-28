Title: Assign me a task from the current sprint

Goal: Find an unassigned, in-sprint work item that matches my criteria and reassign it to me.

Preconditions:
- MCP Azure DevOps server is connected and authenticated.
- Environment variables available: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_TEAM`, `AZDO_USER_EMAIL`.
- Optional variables: `AZDO_AREA_PATH`, `AZDO_WORK_ITEM_TYPES` (comma-separated; default: User Story,Bug,Task), `AZDO_PRIORITY_MIN` (default: 0), `AZDO_PRIORITY_MAX` (default: 4).

System/Tool Context:
- Use Azure DevOps REST via MCP server tools.
- Respect org/project/team permissions.

Instructions:
1) Identify the current active iteration for `AZDO_TEAM` in project `AZDO_PROJECT`.
2) Query work items within that iteration that are:
   - Type in `AZDO_WORK_ITEM_TYPES` (default: User Story, Bug, Task)
   - State not in Done/Closed/Removed
   - Assigned To is empty or not set
   - Optional: `Area Path` equals `AZDO_AREA_PATH` if provided
   - Optional: `Priority` between `AZDO_PRIORITY_MIN` and `AZDO_PRIORITY_MAX`
3) Rank candidates by:
   - Highest `Priority`
   - Most recent `Updated Date`
   - Smallest `Remaining Work` (prefer quick wins)
4) Select the top candidate. If none found, explain clearly and stop.
5) Assign `Assigned To` to `AZDO_USER_EMAIL` and add a comment:
   - "Auto-assigned via MCP: picking up from current sprint"
6) Return a concise summary including:
   - Work item ID, title, type, state, priority
   - Iteration path, area path
   - URL to the item
   - The change performed (assignment + comment)

Validation & Safety:
- Dry-run first: show selected candidate and ask for confirmation unless `CONFIRM_ASSIGN=true`.
- If confirmation is required and not given, do not modify.
- If assignment fails due to permissions or conflicts, report the error with the work item ID and reason.

Parameters (defaults):
- `CONFIRM_ASSIGN`: false
- `AZDO_WORK_ITEM_TYPES`: "User Story,Bug,Task"
- `AZDO_PRIORITY_MIN`: 0
- `AZDO_PRIORITY_MAX`: 4

Example Invocation Notes (for MCP client):
- Ensure env vars are set; then run the prompt as a single action.
- If your MCP client supports variables, pass overrides where needed.

Expected Output (JSON-like fields):
- `selected`: { id, title, type, state, priority, url }
- `action`: "assigned" | "dry-run"
- `assignee`: `AZDO_USER_EMAIL`
- `comment_added`: boolean
- `notes`: string
