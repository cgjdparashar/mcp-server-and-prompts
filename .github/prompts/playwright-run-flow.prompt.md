Title: Run Application Flow via Playwright MCP (No Test Files)

Goal: Execute a user-provided application flow using the Playwright MCP server and report results, without generating or persisting Playwright test cases.

⚠️ **FILE LOCATION RULE**: This prompt does NOT create any files. All operations are ephemeral. If the application being tested requires file access, ALL files MUST be within `/project/` folder only.

Preconditions:
- Playwright MCP server is configured and authenticated.
- **Application code MUST exist in `/project/src/` folder** for context and analysis.
- The flow steps, selectors, and expected outcomes are provided as parameters to this prompt.
- **CRITICAL**: Application under test must be located in `/project/` folder structure.

Instructions:
0) Analyze application context:
   - **MANDATORY**: Check if `/project/src/` folder exists at workspace root
   - If `/project/src/` does NOT exist, return error: "Application code must be in `/project/src/` folder"
   - If `/project/src/` exists: Read `/project/src/README.md` to understand application structure, routes, and features
   - Scan `/project/src/` folder to identify:
     * Application entry point (e.g., `/project/src/app.py`, `/project/src/index.js`, `/project/src/main.ts`)
     * Route definitions and endpoints
     * HTML templates/components (e.g., `/project/src/templates/`, `/project/src/components/`)
     * Form fields, input names, button selectors from code
     * Static assets and CSS classes from `/project/src/static/`
   - **Verify**: All application files are within `/project/src/` folder
   - Use this context to validate selectors and understand expected application behavior
1) Accept and validate parameters:
   - `BASE_URL`: starting URL (required)
   - `STEPS`: ordered array of actions; each step includes:
     - `action`: one of `goto|click|fill|select|press|waitFor|assert`
     - `selector`: CSS/XPath/test-id (required for interactive actions)
     - `value`: text/option/key for `fill|select|press` (optional as per action)
     - `waitUntil`: one of `load|networkidle|domcontentloaded` (optional)
     - `timeoutMs`: per-step timeout override (optional)
     - `assert`: { type: `visible|textContains|urlContains|hasValue`, selector?, value? } (for `assert` steps)
   - `HEADLESS`: boolean (default true)
   - `VIEWPORT`: { width, height } (optional)
   - `TRACE`: boolean (default false) to enable tracing/screenshot capture via MCP server capabilities
4) For each step in `STEPS`:
   - Cross-reference selectors with code from `/project/src/` folder when available to ensure accuracy
   - Perform the action, honoring `timeoutMs`.
   - For `waitFor`, wait for selector/state (`visible|hidden|attached|detached`).
   - For `assert`, evaluate the assertion and record pass/fail with details.
   - If an action fails, record the error and continue only if `CONTINUE_ON_ERROR=true` (default false).
5) If `TRACE=true`, collect artifacts exposed by the MCP server (screenshots per step, console logs, network events):
   - **CRITICAL**: If artifacts are saved, they MUST be saved within `/project/` folder (e.g., `/project/traces/`, `/project/screenshots/`)
   - Include references/paths in output (all paths must start with `/project/`)
6) Close the browser context and return a structured summary.
7) Include context from `/project/src/` analysis in notes (e.g., "Based on /project/src/templates/login.html, validated selector #username")/paths in output.
6) Close the browser context and return a structured summary.
Validation & Safety:
- **No test files are created**; this is an ephemeral run with no file generation.
- **Application Location**: Application under test MUST be in `/project/src/` folder.
- **Artifacts Rule**: If any artifacts (screenshots, traces, logs) are saved, they MUST be within `/project/` folder (e.g., `/project/traces/`, `/project/screenshots/`).
- **PROHIBITED**: Saving any files outside `/project/` folder.
- Enforce timeouts to prevent hanging flows; default step timeout 10s.
- Sanitize selectors and values length (reject >10k chars).
- Enforce timeouts to prevent hanging flows; default step timeout 10s.
- Sanitize selectors and values length (reject >10k chars).

Parameters:
- `BASE_URL`: required string
- `STEPS`: required array of step objects
- `HEADLESS`: optional boolean; default `true`
- `VIEWPORT`: optional object `{ width: number, height: number }`
Expected Output:
- `summary`: { totalSteps: number, passed: number, failed: number, elapsedMs: number }
- `results`: [ { index, action, selector?, status: `passed|failed`, message?, durationMs, screenshot? } ]
- `artifacts`: { traceEnabled: boolean, screenshots: [string], logs?: [string] } (all paths must start with `/project/` if saved)
- `finalUrl`: string
- `notes`: string (warnings, errors, or environment info; include confirmation that application is in `/project/src/`)d|failed`, message?, durationMs, screenshot? } ]
- `artifacts`: { traceEnabled: boolean, screenshots: [string], logs?: [string] }
- `finalUrl`: string
- `notes`: string (warnings, errors, or environment info)

Example `STEPS`:
- Goto + login + assert dashboard visible:
```json
[
  { "action": "goto", "selector": "", "waitUntil": "networkidle" },
  { "action": "fill", "selector": "#username", "value": "alice" },
  { "action": "fill", "selector": "#password", "value": "secret" },
  { "action": "click", "selector": "button[type=submit]" },
  { "action": "assert", "assert": { "type": "visible", "selector": "#dashboard" } }
]
```

Usage Notes:
- **Application Location**: Application code MUST be in `/project/src/` folder
- Prompt will analyze `/project/src/` folder first to understand application structure and validate selectors
- Provide `BASE_URL` and a well-defined `STEPS` array; selectors should match your app.
- If `/project/src/` folder exists, selectors will be cross-referenced with application code for accuracy
- Use `TRACE=true` to capture screenshots/logs if supported by your MCP server.
- **Artifacts**: If traces/screenshots are saved, they will be in `/project/traces/` or `/project/screenshots/`
- Set `CONTINUE_ON_ERROR=true` to gather more step results when debugging flows.
- **Validation**: Prompt will verify application is in `/project/` before running tests
