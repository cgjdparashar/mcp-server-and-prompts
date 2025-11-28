Title: Assign Azure DevOps Work Item by ID

Goal: Fetch details for a specific Azure DevOps work item by ID and assign it to the authenticated user, with dry-run safety and clear output.

Preconditions:
- MCP Azure DevOps server is configured and authenticated.
- Required environment variables: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_USER_EMAIL`.
- Input parameter: `WORK_ITEM_ID` (numeric Azure DevOps work item ID).

Instructions:
1) Validate `WORK_ITEM_ID` is provided and numeric. If invalid, return an error and stop.
2) Fetch the work item by ID with fields:
   - Core: `System.Id`, `System.Title`, `System.WorkItemType`, `System.State`, `System.AssignedTo`, `System.AreaPath`, `System.IterationPath`
   - Planning: `Microsoft.VSTS.Common.Priority`, `Microsoft.VSTS.Common.StackRank`
   - Effort: `Microsoft.VSTS.Scheduling.RemainingWork`, `Microsoft.VSTS.Scheduling.OriginalEstimate`
   - Timestamps: `System.CreatedDate`, `System.ChangedDate`
   - Include `relations` to surface parent/child/related links
3) Validate assignment eligibility:
   - Reject if state is Done/Closed/Removed
   - If already assigned to `AZDO_USER_EMAIL`, report and stop
4) Safety check (dry-run by default):
   - If `CONFIRM_ASSIGN` is not `true`, return a preview including current assignee and the intended change; do not modify.
5) Perform assignment when confirmed:
   - Update `Assigned To` to `AZDO_USER_EMAIL`
   - Add comment: "Auto-assigned via MCP by ID"
6) Return a concise summary including:
   - Work item ID, title, type, state, priority
   - Area/Iteration paths
   - Azure DevOps web URL
   - Action performed (`dry-run` or `assigned`), and whether a comment was added

Validation & Safety:
- Dry-run unless `CONFIRM_ASSIGN=true`.
- Handle permission errors or conflicts clearly with the work item ID and reason.

Parameters:
- `WORK_ITEM_ID`: required (number)
- `CONFIRM_ASSIGN`: optional; default `false`

Expected Output:
- `workItem`: { id, title, type, state, priority, assignedTo, areaPath, iterationPath, url }
- `action`: "dry-run" | "assigned"
- `assignee`: `AZDO_USER_EMAIL`
- `comment_added`: boolean
- `notes`: string

Example Usage Notes:
- Set required env vars; trigger this prompt in your MCP-aware client, provide `WORK_ITEM_ID`, and set `CONFIRM_ASSIGN=true` to perform the change.
