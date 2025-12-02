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
   - Check if `/project` folder exists at workspace root
   - If `/project` exists (existing project):
     * Read and analyze `/project/src/README.md` if present to understand existing codebase structure, features, conventions
     * Scan `/project/src` folder structure to identify existing modules, components, patterns
     * Review existing code files to understand architecture, naming conventions, coding style
     * Identify where new feature should integrate with existing code
     * Plan modifications to maintain consistency with existing patterns
   - If `/project` does not exist (new project):
     * Plan fresh project structure within `/project` and `/project/src`
   - Break down work into logical steps (project setup, core features, testing, documentation)
   - Determine project structure and file organization within `/project/src`
   - Identify required dependencies and configurations
   - Create a todo list for tracking progress
6) Execute full implementation:
   - Check if `/project` folder exists at workspace root:
     * If `/project` folder does NOT exist: Create `/project` folder and `/project/src` subfolder
     * If `/project` folder exists: Check if `/project/src` exists and use existing structure
   - All application code, modules, and components MUST be implemented inside `/project/src` folder
   - Create project structure (folders within `/project/src`, configuration files in `/project`)
   - Initialize project with specified tools (e.g., `uv init`, `npm init`, etc.) in `/project`
   - Install and configure dependencies (requirements.txt, package.json, etc. in `/project`)
   - Implement all required features and components inside `/project/src` folder:
     * For existing projects: Follow existing code patterns, naming conventions, and architecture
     * For new projects: Establish clean architecture and best practices
   - Create database schemas/migrations inside `/project/src` if needed
   - Write configuration files in `/project` (.env.example, config files)
   - Add error handling and validation in `/project/src` code
   - Update or create `/project/src/README.md`:
     * For existing projects: Update `/project/src/README.md` with new features, changes, updated usage instructions
     * For new projects: Create comprehensive `/project/src/README.md` documenting code structure, modules, components
   - Create `/project/README.md` with setup and usage instructions (if not exists)
   - Add inline code comments for clarity
7) Validate implementation:
   - Verify all acceptance criteria are met
   - Ensure code follows specified conventions
   - Check that all files are in correct locations
   - Validate configuration completeness
8) Update work item status:
   - **ALWAYS** add a detailed comment to the work item documenting:
     * Implementation summary
     * All files created with paths
     * Setup and run instructions
     * Features delivered
     * Database configuration details
     * Next steps for testing/deployment
   - **ALWAYS** update the work item state to "Done" after successful implementation
   - If git repository detected, include commit information in the comment
   - Comment should be comprehensive enough for other team members to understand what was delivered
   - Use markdown formatting in comments for better readability
9) Provide comprehensive summary:
   - Work item details (ID, title, type)
   - Requirements analysis summary
   - Files created/modified (with paths)
   - Setup instructions
   - Testing/validation steps
   - Next steps or additional notes

Validation & Safety:
- **Implementation Mode**: ALWAYS create files and implement the solution (no dry-run mode)
- **Work Item Updates**: ALWAYS update work item with comment and status change to "Done"
- Create all files in appropriate workspace location
- Use version control best practices if git repo detected
- Handle errors gracefully and report clearly
- Ensure all deliverables are completed before updating work item status

Parameters:
- `WORK_ITEM_ID`: required (number) - The Azure DevOps work item ID to implement
- `PROJECT_ROOT`: optional; custom root directory for implementation (default: workspace root or new subfolder)

Note: This prompt ALWAYS implements the solution and updates the work item. No confirmation flags needed.

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
- Execute the prompt with the work item ID (e.g., Issue #299)
- The prompt will automatically:
  1. Fetch work item details
  2. Analyze requirements
  3. Implement complete solution
  4. Add comprehensive comment to work item
  5. Update work item status to "Done"
- Example:
  ```powershell
  # Set up environment
  . .\scripts\prompts\set-azure-devops-env.ps1
  
  # Then trigger this prompt with work item ID
  # The prompt handles everything automatically
  ```

Implementation Patterns:
- **Folder Structure**: All projects created in `/project` folder, all application code in `/project/src`
- **New Project Structure**: `/project` (root), `/project/src` (code), `/project/README.md` (user docs), `/project/src/README.md` (technical docs)
- **Existing Project Context**: Always read `/project/src/README.md` first to understand existing architecture, then maintain consistency
- **Documentation**: Update `/project/src/README.md` with all new features, changes, and usage instructions
- Python projects: Use specified tools (uv, pip, poetry), follow PEP standards, code in `/project/src`
- Node.js: Use npm/yarn, follow package.json conventions, code in `/project/src`
- Web apps: Organize within `/project/src` (e.g., `/project/src/routes`, `/project/src/models`, `/project/src/static`, `/project/src/templates`)
- Databases: Create schema files, connection utilities, migration scripts in `/project/src`
- Configuration: Use .env.example in `/project`, document all variables
- Documentation: Clear README in `/project` with prerequisites, setup, usage, troubleshooting
