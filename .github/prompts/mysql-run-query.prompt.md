Title: Run MySQL Query via MCP Server

Goal: Execute a read-focused MySQL query through the MySQL MCP server and return structured, paginated results suitable for display in clients like VS Code.

Preconditions:
- MySQL MCP server is configured and authenticated (connection handled externally by the MCP server).
- The MCP server exposes safe query execution capabilities.

Instructions:
1) Accept input parameters and validate safety:
   - `SQL`: The SQL to execute. If not provided, return an error.
   - `PARAMS`: Optional key-value parameters to bind (if supported by the MCP server).
   - `READ_ONLY`: If `true` (default), reject mutation statements (INSERT/UPDATE/DELETE/TRUNCATE/DROP/ALTER).
   - `LIMIT`: Optional integer to cap returned rows (default: 100).
   - `OFFSET`: Optional integer for pagination (default: 0).
2) If `READ_ONLY=true`, parse the leading keyword of `SQL` and fail fast if it is not a read statement (`SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN`).
3) Execute the query through the MySQL MCP server:
   - Bind `PARAMS` if provided and supported.
   - Apply `LIMIT`/`OFFSET` when possible. If not supported server-side, apply client-side pagination.
4) Collect and normalize results:
   - Return column names and row values as arrays.
   - Preserve numeric, string, boolean types; format dates/timestamps as ISO8601.
   - Include row count and execution timing.
5) On errors, return a clear message including SQL snippet and any server error code.

Validation & Safety:
- Default `READ_ONLY=true`; strong validation prevents destructive operations.
- Consider `SQL` length limits and refuse excessively long statements (e.g., >100k chars).
- Do not echo full result sets in `notes`; use the structured fields.

Parameters:
- `SQL`: required string.
- `PARAMS`: optional object (key-value).
- `READ_ONLY`: optional boolean; default `true`.
- `LIMIT`: optional integer; default `100`.
- `OFFSET`: optional integer; default `0`.

Expected Output:
- `meta`: { columns: [string], rowCount: number, limit: number, offset: number, elapsedMs: number }
- `rows`: [ [value, ...], ... ]
- `notes`: string (warnings, truncation info, or error messages)

Examples:
- List users with pagination:
  - `SQL`: "SELECT id, email, created_at FROM users ORDER BY created_at DESC"
  - `LIMIT`: 50
  - `OFFSET`: 0
- Show table structure:
  - `SQL`: "DESCRIBE orders"
- Explain query plan:
  - `SQL`: "EXPLAIN SELECT * FROM orders WHERE status = 'open'"

Usage Notes:
- For mutation operations (INSERT/UPDATE/DELETE), set `READ_ONLY=false` explicitly and ensure your MCP server allows it; consider adding `CONFIRM_EXECUTE=true` in your client workflow.
- This prompt is intentionally generic; adapt `PARAMS` binding style to your MCP server’s API if it differs.
