Title: Run Application Flow via Playwright MCP (No Test Files)

Goal: Execute a user-provided application flow using the Playwright MCP server and report results, without generating or persisting Playwright test cases.

Preconditions:
- Playwright MCP server is configured and authenticated.
- The flow steps, selectors, and expected outcomes are provided as parameters to this prompt.

Instructions:
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
2) Initialize a browser context via the Playwright MCP server with `HEADLESS` and `VIEWPORT`.
3) Navigate to `BASE_URL` and honor `waitUntil` if provided in the first step.
4) For each step in `STEPS`:
   - Perform the action, honoring `timeoutMs`.
   - For `waitFor`, wait for selector/state (`visible|hidden|attached|detached`).
   - For `assert`, evaluate the assertion and record pass/fail with details.
   - If an action fails, record the error and continue only if `CONTINUE_ON_ERROR=true` (default false).
5) If `TRACE=true`, collect artifacts exposed by the MCP server (screenshots per step, console logs, network events) and include references/paths in output.
6) Close the browser context and return a structured summary.

Validation & Safety:
- No test files are created; this is an ephemeral run.
- Enforce timeouts to prevent hanging flows; default step timeout 10s.
- Sanitize selectors and values length (reject >10k chars).

Parameters:
- `BASE_URL`: required string
- `STEPS`: required array of step objects
- `HEADLESS`: optional boolean; default `true`
- `VIEWPORT`: optional object `{ width: number, height: number }`
- `TRACE`: optional boolean; default `false`
- `CONTINUE_ON_ERROR`: optional boolean; default `false`

Expected Output:
- `summary`: { totalSteps: number, passed: number, failed: number, elapsedMs: number }
- `results`: [ { index, action, selector?, status: `passed|failed`, message?, durationMs, screenshot? } ]
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
- Provide `BASE_URL` and a well-defined `STEPS` array; selectors should match your app.
- Use `TRACE=true` to capture screenshots/logs if supported by your MCP server.
- Set `CONTINUE_ON_ERROR=true` to gather more step results when debugging flows.
