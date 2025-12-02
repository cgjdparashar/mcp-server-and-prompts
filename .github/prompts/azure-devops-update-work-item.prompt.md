Title: Update Azure DevOps Work Item Details

Goal: Update fields, status, and add comments to an Azure DevOps work item (User Story, Bug, Task, Issue, Epic, Feature, etc.) based on user requirements.

Preconditions:
- MCP Azure DevOps server is connected and authenticated.
- Environment variables available: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_USER_EMAIL`.
- **Setup Script**: Run `scripts/prompts/set-azure-devops-env.ps1` to automatically configure all required environment variables.
- Input parameter: `WORK_ITEM_ID` (numeric Azure DevOps work item ID).

System/Tool Context:
- Use Azure DevOps REST via MCP server tools.
- Respect org/project/team permissions.
- Support all work item types (User Story, Bug, Task, Issue, Epic, Feature, Test Case, etc.).

Instructions:
1) Validate `WORK_ITEM_ID` is provided and numeric. If missing/invalid, return an explicit error.
2) Fetch current work item details to understand context:
   - Core fields: `System.Id`, `System.Title`, `System.WorkItemType`, `System.State`, `System.AssignedTo`
   - Current values will be displayed to user for reference
3) Determine what updates to apply based on user request:
   - **State change**: Update `System.State` (e.g., To Do, In Progress, Done, Closed, Active, Resolved, New, etc.)
   - **Assignment**: Update `System.AssignedTo` to specific user email
   - **Title**: Update `System.Title` with new title text
   - **Description**: Update `System.Description` with new content (HTML or Markdown format)
   - **Priority**: Update `Microsoft.VSTS.Common.Priority` (1-4, where 1 is highest)
   - **Tags**: Update `System.Tags` (semicolon-separated list)
   - **Iteration**: Update `System.IterationPath` to specific iteration
   - **Area Path**: Update `System.AreaPath` to specific area
   - **History/Comment**: Add entry to `System.History` (appears in discussion/history)
   - **Remaining Work**: Update `Microsoft.VSTS.Scheduling.RemainingWork`
   - **Custom fields**: Support any valid field path
4) If user wants to add a comment (separate from history):
   - Use the add comment tool to create a discussion comment
   - Format in Markdown for better readability
   - Include context, summary, or detailed information as needed
5) Build update operations array:
   - Each operation: `{"op": "add", "path": "/fields/FieldName", "value": "NewValue"}`
   - Use "add" operation for creating/updating field values
   - Use "remove" operation only if explicitly requested to clear a field
6) Apply updates using the work item update tool
7) Verify update was successful and display updated fields
8) If comment was added, confirm comment ID and timestamp

Validation & Safety:
- Read-only check first - fetch work item to ensure it exists
- Validate field values before applying (e.g., valid state transitions, user exists, iteration exists)
- Provide clear error messages if update fails
- Show before/after values for changed fields
- Confirm all updates were applied successfully

Common Update Patterns:
- **Mark as Done**: State → "Done", add completion comment
- **Assign to me**: AssignedTo → `AZDO_USER_EMAIL`
- **Change priority**: Priority → 1, 2, 3, or 4
- **Add progress note**: History → detailed update text
- **Add comment**: Use comment tool with markdown formatting
- **Update estimate**: RemainingWork → hours (numeric)
- **Move to iteration**: IterationPath → "Project\\Iteration\\Sprint X"
- **Close work item**: State → "Closed" or "Done", add closing comment

Parameters:
- `WORK_ITEM_ID`: required (number) - The work item ID to update
- User will specify what fields to update in natural language

Example Invocation Notes (for MCP client):
- Run the setup script first: `. .\scripts\prompts\set-azure-devops-env.ps1`
- Then execute this prompt with work item ID and describe the updates needed
- Examples:
  * "Update work item 299 to Done state"
  * "Add comment to work item 299 about implementation status"
  * "Change priority of work item 299 to 1 (highest)"
  * "Assign work item 299 to me"
  * "Update remaining work for work item 299 to 5 hours"

Expected Output:
- `workItem`: { id, title, type, state, assignedTo, url }
- `updatesApplied`: [{ field, oldValue, newValue }]
- `commentAdded`: { id, text, timestamp } (if comment was added)
- `success`: boolean
- `message`: string (summary of changes)

Field Reference:
Common field paths for updates:
- `System.State` - Work item state
- `System.AssignedTo` - Assigned user (email address)
- `System.Title` - Work item title
- `System.Description` - Description (HTML format)
- `System.History` - Discussion/history entry (appears in activity)
- `System.Tags` - Tags (semicolon-separated)
- `System.IterationPath` - Iteration (format: "Project\\Path\\To\\Iteration")
- `System.AreaPath` - Area path (format: "Project\\Path\\To\\Area")
- `Microsoft.VSTS.Common.Priority` - Priority (1-4)
- `Microsoft.VSTS.Scheduling.RemainingWork` - Remaining hours
- `Microsoft.VSTS.Scheduling.CompletedWork` - Completed hours
- `Microsoft.VSTS.Common.StackRank` - Stack rank (numeric)

State Values (vary by work item type):
- Task: To Do, In Progress, Done
- Bug: New, Active, Resolved, Closed
- User Story: New, Active, Resolved, Closed
- Issue: To Do, Doing, Done
- Epic/Feature: New, Active, Resolved, Closed

Notes:
- History updates appear in the discussion timeline with a system comment icon
- Comments appear in the comments section with user avatar
- For bulk updates, this prompt can be used multiple times or extended to support multiple work items
- Field values must match expected formats (e.g., email for AssignedTo, valid state for State)
- Invalid field paths or values will result in error messages from Azure DevOps API
