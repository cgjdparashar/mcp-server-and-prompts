Title: Diagnose, Fix, and Retest via Playwright MCP (No Test Files)

Goal: Execute a user-provided application flow using the Playwright MCP server, detect a failure, apply a targeted fix (without creating Playwright tests), and retest the same flow to confirm resolution.

Preconditions:
- Playwright MCP server is configured and authenticated.
- The application code is editable by this agent (via MCP client’s file ops or provided patch instructions).
- Flow steps, selectors, and expected outcomes are provided as parameters.

Instructions:
1) Accept and validate parameters:
   - `BASE_URL`: starting URL (required)
   - `STEPS`: ordered array of actions (same schema as run-flow prompt)
   - `HEADLESS`: boolean (default true)
   - `VIEWPORT`: { width, height } (optional)
   - `TRACE`: boolean (default true) to capture artifacts for diagnosis
   - `CONTINUE_ON_ERROR`: boolean (default false)
   - `FIX_STRATEGY`: one of `patch|env|retry|none` (default `patch`)
   - `PATCH_INSTRUCTIONS`: optional string describing code changes (file paths + diffs) if known
   - `RETRY_POLICY`: optional { maxAttempts: number, backoffMs: number } (default {1, 0})
2) Run the flow:
   - Initialize Playwright via MCP server with `HEADLESS`, `VIEWPORT`.
   - Navigate to `BASE_URL` and execute `STEPS`, recording per-step results and artifacts if `TRACE=true`.
3) Diagnose failures:
   - If any step fails, collect: screenshot, console logs, network errors, selector state.
   - Classify failure (navigation timeout, selector not found, assertion failed, network error).
4) Apply fix based on `FIX_STRATEGY`:
   - `patch`: Apply file changes using `PATCH_INSTRUCTIONS` if provided; otherwise propose minimal fix (e.g., adjust selector, add await/waitFor, handle null states) and apply via MCP client file ops.
   - `env`: Adjust environment variables or feature flags exposed to the app (if available) and relaunch.
   - `retry`: Add waits or retries for flaky steps (respect `RETRY_POLICY`).
   - `none`: Skip fix and proceed to retest to confirm reproducibility.
   - Record the fix steps performed.
5) Retest the flow:
   - Reinitialize context and execute `STEPS` again.
   - Record results and artifacts; compare pass/fail counts.
6) Return a structured summary of diagnosis, fix, and retest outcome.

Validation & Safety:
- No Playwright test files are created.
- Limit patches to targeted files and keep diffs minimal.
- Require explicit `PATCH_INSTRUCTIONS` for destructive changes.
- Timeouts enforced (default per-step 10s); cap total run time.

Parameters:
- `BASE_URL`: required string
- `STEPS`: required array of step objects
- `HEADLESS`: optional boolean; default `true`
- `VIEWPORT`: optional object `{ width: number, height: number }`
- `TRACE`: optional boolean; default `true`
- `CONTINUE_ON_ERROR`: optional boolean; default `false`
- `FIX_STRATEGY`: optional enum; default `patch`
- `PATCH_INSTRUCTIONS`: optional string
- `RETRY_POLICY`: optional object

Expected Output:
- `run`: { totalSteps, passed, failed, elapsedMs, artifacts }
- `diagnosis`: { failureType, failingStepIndex, message, evidence: { screenshot?, logs?, network? } }
- `fix`: { strategy, changes?: [ { file, description } ], envChanges?: [ { key, value } ], notes }
- `retest`: { totalSteps, passed, failed, elapsedMs, artifacts }
- `result`: `fixed|not-fixed|no-failures`
- `notes`: string

Example `STEPS`:
```json
[
  { "action": "goto", "waitUntil": "networkidle" },
  { "action": "fill", "selector": "#username", "value": "alice" },
  { "action": "fill", "selector": "#password", "value": "secret" },
  { "action": "click", "selector": "button[type=submit]" },
  { "action": "assert", "assert": { "type": "visible", "selector": "#dashboard" } }
]
```

Usage Notes:
- Provide `PATCH_INSTRUCTIONS` when you already know the fix; otherwise the agent will propose minimal, safe changes.
- If your MCP server exposes app-specific patch endpoints, reference them in `PATCH_INSTRUCTIONS`.
