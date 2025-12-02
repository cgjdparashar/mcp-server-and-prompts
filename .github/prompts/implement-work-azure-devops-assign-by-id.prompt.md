Title: Implement Azure DevOps Work Item by ID

Goal: Fetch details for a specific Azure DevOps work item by ID (User Story, Bug, Task, Issue, Epic, Feature, etc.), analyze its requirements, and implement the complete solution by writing all necessary code, configurations, and documentation.

Preconditions:
- MCP Azure DevOps server is configured and authenticated.
- Required environment variables: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_USER_EMAIL`.
- **Setup Script**: Run `scripts/prompts/set-azure-devops-env.ps1` to automatically configure all required environment variables.
- Input parameter: `WORK_ITEM_ID` (numeric Azure DevOps work item ID).
- Workspace must be ready for code implementation (writable file system).

Instructions:
1) Validate `WORK_ITEM_ID` is provided and numeric. If invalid, return an error and stop.
2) Fetch the work item by ID (supports all work item types: User Story, Bug, Task, Issue, Epic, Feature, Test Case, etc.) with all details:
   - Core: `System.Id`, `System.Title`, `System.WorkItemType`, `System.State`, `System.AssignedTo`, `System.AreaPath`, `System.IterationPath`
   - Planning: `Microsoft.VSTS.Common.Priority`, `Microsoft.VSTS.Common.StackRank`
   - Description: `System.Description` (contains technical requirements and specifications)
   - Effort: `Microsoft.VSTS.Scheduling.RemainingWork`, `Microsoft.VSTS.Scheduling.OriginalEstimate`
   - Timestamps: `System.CreatedDate`, `System.ChangedDate`
   - Include `relations` to check for parent/child/related links and dependencies
3) Validate implementation eligibility:
   - Reject if state is Done/Closed/Removed
   - Warn if not assigned to `AZDO_USER_EMAIL` but allow continuation
   - Check if already has linked commits/PRs (potential duplicate work)
4) Analyze requirements from description:
   - Parse technical stack (languages, frameworks, tools)
   - Identify deliverables (features, components, files)
   - Extract constraints (folder structure, naming conventions, dependencies)
   - Note data requirements (database, APIs, mock data policies)
   - Identify acceptance criteria and validation rules
5) Plan implementation approach:
   - Check if `/src` folder exists at workspace root
   - If `/src` exists (existing project):
     * Read and analyze `/src/README.md` if present to understand existing codebase structure, features, conventions
     * Scan `/src` folder structure to identify existing modules, components, patterns
     * Review existing code files to understand architecture, naming conventions, coding style
     * Identify where new feature should integrate with existing code
     * Plan modifications to maintain consistency with existing patterns
   - If `/src` does not exist (new project):
     * Plan fresh project structure within `/src`
   - Break down work into logical steps (project setup, core features, testing, documentation)
   - Determine project structure and file organization within `/src`
   - Identify required dependencies and configurations
   - Create a todo list for tracking progress
6) Execute full implementation:
   - Check if `/src` folder exists at workspace root:
     * If `/src` folder does NOT exist: Create `/src` folder for all implementation code
     * If `/src` folder exists: Use existing `/src` folder (existing code is present, add/modify files there)
   - All application code, modules, and components MUST be implemented inside `/src` folder
   - Create project structure (folders within `/src`, configuration files at root)
   - Initialize project with specified tools (e.g., `uv init`, `npm init`, etc.)
   - Install and configure dependencies (requirements.txt, package.json, etc. at root)
   - Implement all required features and components inside `/src` folder:
     * For existing projects: Follow existing code patterns, naming conventions, and architecture
     * For new projects: Establish clean architecture and best practices
   - Create database schemas/migrations inside `/src` if needed
   - Write configuration files at root (.env.example, config files)
   - Add error handling and validation in `/src` code
   - Update or create `/src/README.md`:
     * For existing projects: Update `/src/README.md` with new features, changes, updated usage instructions
     * For new projects: Create comprehensive `/src/README.md` documenting code structure, modules, components
   - Create README.md at root with setup and usage instructions (if not exists)
   - Add inline code comments for clarity
7) Validate implementation:
   - Verify all acceptance criteria are met
   - Ensure code follows specified conventions
   - Check that all files are in correct locations
   - Validate configuration completeness
8) Update work item status:
   - If `CONFIRM_UPDATE_STATUS=true`, update state to appropriate status (e.g., "In Progress" during work, "Done" after completion)
   - Add detailed comment documenting implementation details, files created, setup steps
   - Link commit if working in a git repository
9) Provide comprehensive summary:
   - Work item details (ID, title, type)
   - Requirements analysis summary
   - Files created/modified (with paths)
   - Setup instructions
   - Testing/validation steps
   - Next steps or additional notes

Validation & Safety:
- Read-only analysis by default; set `CONFIRM_IMPLEMENTATION=true` to create files
- Update work item status only if `CONFIRM_UPDATE_STATUS=true`
- Create all files in appropriate workspace location
- Use version control best practices if git repo detected
- Handle errors gracefully and report clearly

Parameters:
- `WORK_ITEM_ID`: required (number)
- `CONFIRM_IMPLEMENTATION`: optional; default `false` (dry-run analysis only)
- `CONFIRM_UPDATE_STATUS`: optional; default `false` (don't update work item)
- `PROJECT_ROOT`: optional; custom root directory for implementation (default: workspace root or new subfolder)

Expected Output:
- `workItem`: { id, title, type, state, priority, assignedTo, description, url }
- `requirements`: { stack: [], features: [], constraints: [], acceptanceCriteria: [] }
- `implementation`: { 
    filesCreated: [{ path, purpose }], 
    filesModified: [{ path, changes }],
    setupSteps: [],
    validationSteps: []
  }
- `action`: "analysis-only" | "implemented" | "partial-implementation"
- `workItemUpdated`: boolean
- `nextSteps`: string[]
- `notes`: string

Example Usage Notes:
- Run the setup script first: `. .\scripts\prompts\set-azure-devops-env.ps1`
- For analysis only: provide `WORK_ITEM_ID`
- To implement: `$env:CONFIRM_IMPLEMENTATION = "true"`
- To update status: `$env:CONFIRM_UPDATE_STATUS = "true"`
- Example: 
  ```powershell
  $env:CONFIRM_IMPLEMENTATION = "true"
  $env:CONFIRM_UPDATE_STATUS = "true"
  # Then trigger this prompt with WORK_ITEM_ID
  ```

Implementation Patterns:
- **Folder Structure**: All application code goes in `/src` folder (create if not exists, use existing if present)
- **Existing Project Context**: Always read `/src/README.md` first to understand existing architecture, then maintain consistency
- **Documentation**: Update `/src/README.md` with all new features, changes, and usage instructions
- Python projects: Use specified tools (uv, pip, poetry), follow PEP standards, code in `/src`
- Node.js: Use npm/yarn, follow package.json conventions, code in `/src`
- Web apps: Organize within `/src` (e.g., `/src/routes`, `/src/models`, `/src/static`, `/src/templates`)
- Databases: Create schema files, connection utilities, migration scripts in `/src`
- Configuration: Use .env.example at root, document all variables
- Documentation: Clear README at root with prerequisites, setup, usage, troubleshooting
