Title: Implement Azure DevOps Work Item by ID

Goal: Fetch details for a specific Azure DevOps work item by ID (User Story, Bug, Task, Issue, Epic, Feature, etc.), analyze its requirements, and implement the complete solution by writing all necessary code, configurations, and documentation.

⚠️ **ABSOLUTE REQUIREMENT**: ALL files MUST be created within `/project/` folder. NOTHING outside `/project/`. NO EXCEPTIONS.

Preconditions:
- MCP Azure DevOps server is configured and authenticated.
- Required environment variables: `AZDO_ORG_URL`, `AZDO_PROJECT`, `AZDO_USER_EMAIL`.
- **Setup Script**: Run `scripts/prompts/set-azure-devops-env.ps1` to automatically configure all required environment variables.
- Input parameter: `WORK_ITEM_ID` (numeric Azure DevOps work item ID).
- Workspace must be ready for code implementation (writable file system).
- **File Location Rule**: Every single file created must be within `/project/` folder structure.

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
   - **REMINDER: All planned files MUST be within `/project/` folder**
   - Check if `/project` folder exists at workspace root
   - If `/project` exists (existing project):
     * Read and analyze `/project/src/README.md` if present to understand existing codebase structure, features, conventions
     * Scan `/project/src` folder structure to identify existing modules, components, patterns
     * Review existing code files to understand architecture, naming conventions, coding style
     * Identify where new feature should integrate with existing code
     * Plan modifications to maintain consistency with existing patterns
   - If `/project` does not exist (new project):
     * Plan fresh project structure within `/project` and `/project/src`
     * **DO NOT plan any files outside `/project/` folder**
   - Break down work into logical steps (project setup, core features, testing, documentation)
   - Determine project structure and file organization within `/project/src`
6) Execute full implementation:
   - ⚠️ **CRITICAL RULE - READ CAREFULLY**: Every single file MUST be within `/project/` folder - ABSOLUTELY NO EXCEPTIONS
   - ⚠️ **PROHIBITED**: Creating files at workspace root, creating files in parent directories, creating files anywhere outside `/project/`
   - ⚠️ **BEFORE CREATING ANY FILE**: Verify the path starts with `/project/`
   - Check if `/project` folder exists at workspace root:
     * If `/project` folder does NOT exist: Create `/project` folder and `/project/src` subfolder FIRST
     * If `/project` folder exists: Check if `/project/src` exists and use existing structure
   - **Absolute folder structure enforcement (NON-NEGOTIABLE):**
     * ✅ ALL application code MUST go in `/project/src/` folder
     * ✅ ALL configuration files MUST go in `/project/` folder (root of project)
     * ❌ NO files created outside `/project/` - not even temporary files, logs, or cache
     * ❌ NO files at workspace root - EVERYTHING inside `/project/`
     * ❌ NO files in parent directories
   - Create project structure (folders within `/project/src`, configuration files in `/project`)
   - Initialize project with specified tools inside `/project` folder only:
     * Run `cd /project` first, then run `uv init`, `npm init`, `pip install`, etc.
     * Ensure tool initialization stays within `/project/` boundary
   - Install and configure dependencies - ALL config files in `/project/`:
     * `/project/requirements.txt`, `/project/package.json`, `/project/pyproject.toml`, etc.
     * ❌ NEVER create these at workspace root
   - Implement all required features and components inside `/project/src/` folder:
     * For existing projects: Follow existing code patterns, naming conventions, and architecture
     * For new projects: Establish clean architecture and best practices
     * All modules, components, utilities, models, views, controllers go in `/project/src/`
     * ❌ NO code files outside `/project/src/`
   - Create database schemas/migrations inside `/project/src/db/` or `/project/src/migrations/` only
   - Write ALL configuration files in `/project/` root:
     * Examples: `/project/.env.example`, `/project/config.json`, `/project/.env`, `/project/.gitignore`
     * ❌ NEVER at workspace root or any other location
   - Add error handling and validation in `/project/src/` code
   - Update or create `/project/src/README.md`:
     * For existing projects: Update `/project/src/README.md` with new features, changes, updated usage instructions
     * For new projects: Create comprehensive `/project/src/README.md` documenting code structure, modules, components
7) Validate implementation:
   - Verify all acceptance criteria are met
   - Ensure code follows specified conventions
   - **MANDATORY VALIDATION - MUST PASS**:
     * ✅ List ALL created files with full paths
     * ✅ Check that EVERY SINGLE file path starts with `/project/`
     * ✅ Verify application code is in `/project/src/`
     * ✅ Verify configuration files are in `/project/` root
     * ✅ Confirm workspace root is empty (no new files created there)
     * ✅ Confirm NO files exist outside `/project/` folder
     * ❌ If ANY file exists outside `/project/`, DELETE it and recreate inside `/project/`
   - Validate configuration completeness
   - **FINAL VERIFICATION**: Scan workspace and confirm `/project/` is the ONLY location with new files
   - Verify all acceptance criteria are met
   - Ensure code follows specified conventions
   - **MANDATORY: Check that ALL files are within `/project/` folder - reject any files outside**
   - Verify application code is in `/project/src/`
   - Verify configuration files are in `/project/`
   - Validate configuration completeness
   - Confirm NO files exist at workspace root or any other location outside `/project/`
9) Provide comprehensive summary:
   - Work item details (ID, title, type)
   - Requirements analysis summary
   - **Files created/modified (with FULL paths starting with `/project/`)**
   - **Confirmation: ALL files are within `/project/` folder ✅**
   - Setup instructions (run from `/project/` directory)
   - Testing/validation steps
   - Next steps or additional notesls
     * Next steps for testing/deployment
   - **ALWAYS** update the work item state to "Done" after successful implementation
   - If git repository detected, include commit information in the comment
   - Comment should be comprehensive enough for other team members to understand what was delivered
   - Use markdown formatting in comments for better readability
9) Provide comprehensive summary:
   - Work item details (ID, title, type)
Validation & Safety:
- **Implementation Mode**: ALWAYS create files and implement the solution (no dry-run mode)
- **Work Item Updates**: ALWAYS update work item with comment and status change to "Done"
- ⚠️ **ABSOLUTE CRITICAL RULE - NON-NEGOTIABLE**: 
  * Create ALL files within `/project/` folder ONLY
  * ZERO exceptions allowed
  * NO files outside `/project/` under ANY circumstances
  * NO files at workspace root
  * NO temporary files outside `/project/`
  * NO log files outside `/project/`
  * NO configuration files outside `/project/`
  * If ANY file is accidentally created outside `/project/`, immediately DELETE it and recreate inside `/project/`
- **Folder Enforcement (STRICT)**: 
  * All code in `/project/src/`
  * All config in `/project/`
Parameters:
- `WORK_ITEM_ID`: required (number) - The Azure DevOps work item ID to implement
- `PROJECT_ROOT`: IGNORED - Always use `/project/` folder at workspace root (this parameter has no effect; all files MUST be in `/project/`)
- Use version control best practices if git repo detected
- Handle errors gracefully and report clearly
- Ensure all deliverables are completed before updating work item status
- **Before finalizing**: Perform complete scan and verify NO files were created outside `/project/` folder
- **If validation fails**: Stop, fix violations, verify againnge to "Done"
- **CRITICAL RULE**: Create ALL files within `/project/` folder ONLY - NO exceptions, NO files outside `/project/`
- **Folder Enforcement**: All code in `/project/src/`, all config in `/project/`, nothing at workspace root
- Use version control best practices if git repo detected
- Handle errors gracefully and report clearly
- Ensure all deliverables are completed before updating work item status
- Before finalizing, verify no files were created outside `/project/` folder

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
Implementation Patterns:
- **Folder Structure (STRICTLY ENFORCED)**: 
  * **ALL files MUST be within `/project/` folder**
  * **ALL application code MUST be in `/project/src/`**
  * **ALL configuration MUST be in `/project/` root**
  * **NO files at workspace root or outside `/project/`**
- **New Project Structure**: 
  * `/project/` (root - contains all config files)
  * `/project/src/` (all application code)
  * `/project/README.md` (user docs)
  * `/project/src/README.md` (technical docs)
  * Example: `/project/pyproject.toml`, `/project/.env.example`, `/project/package.json` (configs in project root)
  * Example: `/project/src/main.py`, `/project/src/models/`, `/project/src/utils/` (code in src)
- **Existing Project Context**: Always read `/project/src/README.md` first to understand existing architecture, then maintain consistency
- **Documentation**: Update `/project/src/README.md` with all new features, changes, and usage instructions
- **Python projects**: 
  * Config files: `/project/pyproject.toml`, `/project/requirements.txt`, `/project/.env.example`
  * All code: `/project/src/` (main.py, modules, packages)
  * Run commands from `/project/` directory
- **Node.js projects**: 
- **FINAL CHECK (MANDATORY)**: 
  * Before completing, list the entire file tree
  * Verify ALL files are within `/project/` folder only
  * Verify NO files exist at workspace root
  * Verify NO files exist outside `/project/`
  * If any violations found, STOP and fix immediately
- **Test Commands**: All commands should be run from `/project/` directory (e.g., `cd /project && npm start`)
- **Prohibited Locations**: Never create files at workspace root, never create files outside `/project/`, never create files in parent directories
- **Web apps**: 
  * All code organized in `/project/src/` (e.g., `/project/src/routes/`, `/project/src/models/`, `/project/src/static/`, `/project/src/templates/`)
  * Configs in `/project/` (e.g., `/project/.env.example`)
- **Databases**: 
  * Schema files, connection utilities, migration scripts in `/project/src/db/` or `/project/src/migrations/`
  * Database config in `/project/.env.example` or `/project/config/`
- **Configuration**: 
  * Use `/project/.env.example`, `/project/config.json`, etc.
  * Document all variables in `/project/README.md`
- **Documentation**: 
  * Clear README in `/project/README.md` with prerequisites, setup, usage, troubleshooting
  * Technical docs in `/project/src/README.md`
- **FINAL CHECK**: Before completing, verify the entire file tree shows ALL files within `/project/` folder only
- Configuration: Use .env.example in `/project`, document all variables
- Documentation: Clear README in `/project` with prerequisites, setup, usage, troubleshooting
