Title: Get Azure DevOps Task Details by ID

Goal: Retrieve comprehensive details for a single Azure DevOps work item (task) by its ID, formatted for quick review and MCP client display.

Preconditions:
- MCP Azure DevOps server is configured and authenticated.
- Required environment variables: `AZDO_ORG_URL`, `AZDO_PROJECT`.
- Input parameter: `WORK_ITEM_ID` (numeric Azure DevOps work item ID).

Instructions:
1) Validate `WORK_ITEM_ID` is provided and numeric. If missing/invalid, return an explicit error.
2) Fetch the work item by ID with these fields:
   - Core: `System.Id`, `System.Title`, `System.WorkItemType`, `System.State`, `System.AssignedTo`, `System.AreaPath`, `System.IterationPath`
   - Planning: `Microsoft.VSTS.Common.Priority`, `Microsoft.VSTS.Common.StackRank`
   - Effort: `Microsoft.VSTS.Scheduling.RemainingWork`, `Microsoft.VSTS.Scheduling.OriginalEstimate`
   - Links: Include `relations` to show parent/child, related, commits, PRs (if available)
   - Timestamps: `System.CreatedDate`, `System.ChangedDate`
3) Optionally expand details if `EXPAND=all` (or `true`) is set:
   - Include latest 10 `System.History` entries (comments/activity)
   - Include attachments metadata (name, size, URL)
4) Return a structured summary including URLs:
   - Azure DevOps web URL to the work item
   - If parent link exists, include parent ID and URL
5) If the item is not found or access is denied, return a clear error with the requested ID.

Validation & Safety:
- Read-only operation; does not modify the work item.
- Validate params and handle missing permissions gracefully.

Parameters:
- `WORK_ITEM_ID`: required (number)
- `EXPAND`: optional; one of `none|true|all` (default: `none`)

Expected Output:
- `workItem`: { id, title, type, state, assignedTo, areaPath, iterationPath, priority, remainingWork, originalEstimate, changedDate, createdDate, url }
- `links`: { parent?: { id, url }, children?: [{ id, url }], related?: [{ id, url }] }
- `history`: [ { revisedDate, author, text } ]  // present only if expanded
- `attachments`: [ { name, size, url } ]        // present only if expanded
- `notes`: string  // additional context or errors

Example Usage Notes:
- Set `AZDO_ORG_URL` and `AZDO_PROJECT`, then run this prompt in your MCP client providing `WORK_ITEM_ID`.
- For VS Code MCP clients, trigger this file directly and pass variables per client UX.
