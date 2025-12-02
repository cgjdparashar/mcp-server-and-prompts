Title: Diagnose, Fix, and Retest via Playwright MCP (No Test Files)

Goal: Execute a user-provided application flow using the Playwright MCP server, detect a failure, apply a targeted fix (without creating Playwright tests), and retest the same flow to confirm resolution.

⚠️ **ABSOLUTE REQUIREMENT**: ALL files MUST be within `/project/` folder. Application code in `/project/src/`, all fixes and changes within `/project/`. NO EXCEPTIONS.

Preconditions:
- Playwright MCP server is configured and authenticated.
- **Application code MUST exist in `/project/src/` folder** and is editable by this agent (via MCP client's file ops or provided patch instructions).
- Flow steps, selectors, and expected outcomes are provided as parameters.
- **CRITICAL**: All file operations must stay within `/project/` folder structure.

Instructions:
0) Analyze application context:
   - **MANDATORY**: Check if `/project/src/` folder exists at workspace root
   - If `/project/src/` does NOT exist, return error: "Application code must be in `/project/src/` folder"
   - **Verify**: All application files are within `/project/src/` folder
   - If `/project/src/` exists: Read `/project/src/README.md` to understand application structure, architecture, and features
   - Scan `/project/src/` folder to identify:
     * Application entry point and main modules
     * Route definitions, handlers, and endpoints
     * HTML templates/components with form fields and selectors
     * Static assets, CSS classes, and JavaScript files
     * Database models and API integrations
   - Use this context to understand expected application behavior and identify potential fix locations
   - **Confirm**: All paths analyzed start with `/project/src/`
1) Accept and validate parameters:
   - `BASE_URL`: starting URL (required)
   - `STEPS`: ordered array of actions (same schema as run-flow prompt)
   - `HEADLESS`: boolean (default true)
   - `VIEWPORT`: { width, height } (optional)
   - `TRACE`: boolean (default true) to capture artifacts for diagnosis
   - `CONTINUE_ON_ERROR`: boolean (default false)
2) Run the flow:
   - Initialize Playwright via MCP server with `HEADLESS`, `VIEWPORT`.
   - Navigate to `BASE_URL` and execute `STEPS`, recording per-step results and artifacts if `TRACE=true`.
   - **Artifacts Rule**: If artifacts are saved, they MUST be within `/project/` folder (e.g., `/project/traces/`, `/project/screenshots/`)
   - Cross-reference selectors with code from `/project/src/` folder when available
3) Diagnose failures:
   - If any step fails, collect: screenshot, console logs, network errors, selector state.
   - **Save artifacts within `/project/` folder only** (e.g., `/project/diagnostics/`, `/project/screenshots/`)
   - Classify failure (navigation timeout, selector not found, assertion failed, network error).
   - Analyze `/project/src/` code to understand root cause:
     * Check if selector exists in templates (e.g., `/project/src/templates/*.html`)
     * Review route handlers for missing endpoints or logic errors (e.g., `/project/src/routes.py`, `/project/src/app.py`)
     * Examine database queries for data issues (e.g., `/project/src/models.py`, `/project/src/database.py`)
     * Identify JavaScript errors in static files (e.g., `/project/src/static/*.js`)
   - **All paths referenced must start with `/project/src/`**
4) Apply fix based on `FIX_STRATEGY`:
   - **CRITICAL**: ALL fixes MUST be applied within `/project/` folder only
   - `patch`: Apply file changes in `/project/src/` folder using `PATCH_INSTRUCTIONS` if provided; otherwise propose minimal fix based on `/project/src/` code analysis (e.g., fix selector in template, correct route handler logic, add missing validation, fix database query) and apply via MCP client file ops.
     * ✅ Edit files in `/project/src/` folder only
     * ❌ NO file changes outside `/project/` folder
   - `env`: Adjust environment variables or feature flags in `/project/.env` or `/project/.env.example` (if available) and relaunch.
     * ✅ Modify `/project/.env` or `/project/.env.example` only
     * ❌ NO environment files outside `/project/`
   - `retry`: Add waits or retries for flaky steps (respect `RETRY_POLICY`).
   - `none`: Skip fix and proceed to retest to confirm reproducibility.
5) Retest the flow:
   - Reinitialize context and execute `STEPS` again.
   - Record results and artifacts within `/project/` folder; compare pass/fail counts.
6) Return a structured summary of diagnosis, fix, and retest outcome with all paths starting with `/project/`.y.
   - Record the fix steps performed with specific file paths in `/project/src`
Validation & Safety:
- **No Playwright test files are created**.
- **Application Location**: Application MUST be in `/project/src/` folder.
- **Fix Location**: ALL fixes MUST be applied within `/project/` folder only.
- **Artifacts Rule**: All artifacts (screenshots, traces, logs) MUST be saved within `/project/` folder (e.g., `/project/traces/`, `/project/screenshots/`, `/project/diagnostics/`).
- **PROHIBITED**: 
  * Saving any files outside `/project/` folder
  * Modifying any files outside `/project/` folder
  * Creating environment files outside `/project/` folder
- Limit patches to targeted files within `/project/src/` and keep diffs minimal.
- Require explicit `PATCH_INSTRUCTIONS` for destructive changes.
- Timeouts enforced (default per-step 10s); cap total run time.
- **Before finalizing**: Verify all modified/created files are within `/project/`tcome.

Validation & Safety:
- No Playwright test files are created.
- Limit patches to targeted files and keep diffs minimal.
- Require explicit `PATCH_INSTRUCTIONS` for destructive changes.
- Timeouts enforced (default per-step 10s); cap total run time.

Parameters:
- `BASE_URL`: required string
- `STEPS`: required array of step objects
Expected Output:
- `context`: { srcFolderExists: boolean, filesAnalyzed: [string] (all paths start with `/project/src/`), appType: string }
- `run`: { totalSteps, passed, failed, elapsedMs, artifacts (all paths start with `/project/`) }
- `diagnosis`: { failureType, failingStepIndex, message, rootCause: string, evidence: { screenshot?, logs?, network?, codeLocation?: string (starts with `/project/src/`) } }
- `fix`: { strategy, changes?: [ { file (starts with `/project/`), description } ], envChanges?: [ { key, value, file (starts with `/project/`) } ], notes }
- `retest`: { totalSteps, passed, failed, elapsedMs, artifacts (all paths start with `/project/`) }
- `result`: `fixed|not-fixed|no-failures`
- `notes`: string (include confirmation that all operations stayed within `/project/`)
Expected Output:
- `context`: { srcFolderExists: boolean, filesAnalyzed: [string], appType: string }
- `run`: { totalSteps, passed, failed, elapsedMs, artifacts }
- `diagnosis`: { failureType, failingStepIndex, message, rootCause: string, evidence: { screenshot?, logs?, network?, codeLocation?: string } }
- `fix`: { strategy, changes?: [ { file, description } ], envChanges?: [ { key, value } ], notes }
- `retest`: { totalSteps, passed, failed, elapsedMs, artifacts }
- `result`: `fixed|not-fixed|no-failures`
- `notes`: string

Example `STEPS`:
```json
[
Usage Notes:
- **Application Location**: Application code MUST be in `/project/src/` folder
- Prompt will analyze `/project/src/` folder first to understand application structure and identify fix locations
- Provide `PATCH_INSTRUCTIONS` when you already know the fix; otherwise the agent will analyze `/project/src/` code and propose minimal, safe changes.
- **All fixes are applied within `/project/` folder only**:
  * Code changes in `/project/src/` folder
  * Environment changes in `/project/.env` or `/project/.env.example`
  * Documentation updates in `/project/src/README.md` or `/project/README.md`
- **Artifacts**: If traces/screenshots are saved, they will be in `/project/traces/`, `/project/screenshots/`, or `/project/diagnostics/`
- `/project/src/README.md` is updated if fix changes application behavior
- If your MCP server exposes app-specific patch endpoints, reference them in `PATCH_INSTRUCTIONS` (ensure they target `/project/` folder).
- **Validation**: Prompt will verify all operations stayed within `/project/` before completing
```

Usage Notes:
- Prompt will analyze `/project/src` folder first to understand application structure and identify fix locations
- Provide `PATCH_INSTRUCTIONS` when you already know the fix; otherwise the agent will analyze `/project/src` code and propose minimal, safe changes.
- Fixes are applied directly to files in `/project/src` folder based on code analysis
- `/project/src/README.md` is updated if fix changes application behavior
- If your MCP server exposes app-specific patch endpoints, reference them in `PATCH_INSTRUCTIONS`.
