```prompt
Title: Detect Tech Stack and Generate CI/CD Pipeline for GitHub Repository

Goal: Analyze a GitHub repository to detect its technology stack, then automatically generate and configure a complete CI/CD pipeline (GitHub Actions workflow) that builds, tests, and deploys the application with all required dependencies.

Preconditions:
- GitHub MCP server is connected and authenticated with appropriate repository permissions.
- Repository access (read for analysis, write for creating workflow files).
- Target repository specified via `GITHUB_REPO_OWNER` and `GITHUB_REPO_NAME`.
- Optional: `GITHUB_BRANCH` (default: "main"), `DEPLOYMENT_TARGET` (e.g., "azure", "aws", "docker", "none").

System/Tool Context:
- Use GitHub REST API via MCP server tools to read repository contents.
- Analyze package managers, configuration files, and project structure.
- Generate GitHub Actions workflow YAML with appropriate runners and actions.
- Respect repository permissions and branch protection rules.

Instructions:

## Phase 1: Tech Stack Detection
1) Clone or fetch the repository structure for `GITHUB_REPO_OWNER/GITHUB_REPO_NAME`.

2) Scan the root directory and key subdirectories for technology indicators:
   
   **Languages & Frameworks:**
   - **Node.js/JavaScript/TypeScript**: Check for `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `tsconfig.json`, `.npmrc`
   - **Python**: Check for `requirements.txt`, `setup.py`, `pyproject.toml`, `Pipfile`, `poetry.lock`, `.python-version`
   - **Java**: Check for `pom.xml` (Maven), `build.gradle`/`settings.gradle` (Gradle), `build.xml` (Ant)
   - **.NET/C#**: Check for `*.csproj`, `*.sln`, `global.json`, `nuget.config`
   - **Go**: Check for `go.mod`, `go.sum`
   - **Ruby**: Check for `Gemfile`, `Gemfile.lock`, `.ruby-version`
   - **PHP**: Check for `composer.json`, `composer.lock`
   - **Rust**: Check for `Cargo.toml`, `Cargo.lock`
   - **Docker**: Check for `Dockerfile`, `docker-compose.yml`, `.dockerignore`
   
   **Frontend Frameworks:**
   - React: `package.json` with "react" dependency
   - Angular: `angular.json`, `package.json` with "@angular/core"
   - Vue: `package.json` with "vue" dependency, `vue.config.js`
   - Next.js: `next.config.js`, `package.json` with "next"
   - Svelte: `svelte.config.js`, `package.json` with "svelte"
   
   **Backend Frameworks:**
   - Express.js, Fastify, Nest.js (Node.js)
   - Django, Flask, FastAPI (Python)
   - Spring Boot, Micronaut, Quarkus (Java)
   - ASP.NET Core (.NET)
   
   **Testing Frameworks:**
   - Jest, Mocha, Cypress, Playwright (JavaScript/TypeScript)
   - Pytest, unittest (Python)
   - JUnit, TestNG (Java)
   - xUnit, NUnit (C#)
   
   **Build Tools:**
   - Webpack, Vite, Rollup, Parcel (JavaScript)
   - Maven, Gradle (Java)
   - MSBuild, dotnet CLI (.NET)

3) Parse dependency files to extract:
   - Runtime dependencies and versions
   - Development dependencies
   - Build scripts and commands
   - Test commands
   - Environment variables required

4) Identify database requirements:
   - PostgreSQL, MySQL, MongoDB, Redis, SQL Server
   - Check for ORM configurations (Sequelize, TypeORM, Entity Framework, SQLAlchemy, Hibernate)

5) Detect deployment artifacts:
   - Static sites (build output to `dist/`, `build/`, `public/`)
   - Container images (Dockerfile present)
   - Serverless functions (functions directory, serverless.yml)
   - Native executables

## Phase 2: CI/CD Pipeline Design
6) Based on detected tech stack, design a GitHub Actions workflow with:
   
   **Build Stage:**
   - Select appropriate runner (ubuntu-latest, windows-latest, macos-latest)
   - Set up language runtime (actions/setup-node, actions/setup-python, actions/setup-java, actions/setup-dotnet)
   - Specify correct versions from detected configuration
   - Cache dependencies (npm, pip, maven, gradle, nuget)
   
   **Automatic Dependency Installation (CRITICAL - Must Include):**
   Install ALL required dependencies based on detected tech stack:
   
   - **Node.js/JavaScript/TypeScript:**
     - If `package-lock.json` exists: `npm ci` (clean install, faster, reproducible)
     - If `yarn.lock` exists: `yarn install --frozen-lockfile`
     - If `pnpm-lock.yaml` exists: `pnpm install --frozen-lockfile`
     - If only `package.json`: `npm install` (create lockfile if missing)
     - Install global tools if needed: `npm install -g typescript eslint prettier`
   
   - **Python:**
     - If `requirements.txt`: `pip install -r requirements.txt`
     - If `pyproject.toml` with Poetry: `poetry install --no-root`
     - If `Pipfile` with Pipenv: `pipenv install --dev`
     - If `setup.py`: `pip install -e .` (editable install)
     - Upgrade pip first: `python -m pip install --upgrade pip`
     - Install build tools: `pip install build wheel setuptools`
   
   - **Java:**
     - If Maven (`pom.xml`): `mvn clean install -DskipTests` (install dependencies)
     - If Gradle (`build.gradle`): `./gradlew build --no-daemon` (includes dependency download)
     - Use dependency caching for faster builds
     - Install Maven/Gradle wrappers if present
   
   - **.NET/C#:**
     - Restore NuGet packages: `dotnet restore`
     - If multiple projects: `dotnet restore YourSolution.sln`
     - Install workload if needed: `dotnet workload restore`
     - Install global tools: `dotnet tool restore`
   
   - **Go:**
     - Download dependencies: `go mod download`
     - Verify dependencies: `go mod verify`
     - Tidy dependencies: `go mod tidy`
   
   - **Ruby:**
     - Install Bundler: `gem install bundler`
     - Install gems: `bundle install --jobs=4 --retry=3`
     - Use specific Bundler version if in Gemfile.lock
   
   - **PHP:**
     - Install Composer dependencies: `composer install --no-interaction --prefer-dist --optimize-autoloader`
     - For production: `composer install --no-dev --no-interaction`
   
   - **Rust:**
     - Dependencies auto-installed with: `cargo build`
     - Update dependencies: `cargo update`
     - Check dependencies: `cargo check`
   
   **Additional Dependencies (Install as needed):**
   - **System packages** (via apt/yum): Database clients, libraries, tools
     - Example: `sudo apt-get update && sudo apt-get install -y libpq-dev`
   - **Docker**: If Dockerfile exists, ensure Docker is available
   - **Database drivers**: Install specific database client libraries
   - **Build tools**: Make, CMake, GCC, etc. if native compilation needed
   - **Testing tools**: Install test runners, browsers for E2E tests
   
   **Conditional Dependency Installation:**
   ```yaml
   - name: Check for package.json
     id: check-nodejs
     run: |
       if [ -f "package.json" ]; then
         echo "has_nodejs=true" >> $GITHUB_OUTPUT
       else
         echo "has_nodejs=false" >> $GITHUB_OUTPUT
       fi
   
   - name: Install Node.js dependencies
     if: steps.check-nodejs.outputs.has_nodejs == 'true'
     run: |
       if [ -f "package-lock.json" ]; then
         npm ci
       elif [ -f "yarn.lock" ]; then
         yarn install --frozen-lockfile
       elif [ -f "pnpm-lock.yaml" ]; then
         pnpm install --frozen-lockfile
       else
         npm install
       fi
   ```
   
   **Post-Dependency Installation:**
   - Verify installations: Check key binaries/packages are available
   - Display installed versions for debugging
   - Run build commands
   - Run linting/code quality checks if configured
   
   **Test Stage:**
   - Run unit tests
   - Run integration tests if detected
   - Generate test coverage reports
   - Upload test artifacts
   
   **Security Checks:**
   - Dependency vulnerability scanning (npm audit, pip-audit, OWASP Dependency-Check)
   - Code scanning (CodeQL for supported languages)
   
   **Deployment Stage (DEFAULT: Azure Web Apps - auto-create based on tech stack):**
   - **Azure Web Apps** (PRIMARY): Automatically create/update Web App based on detected runtime
     - Node.js → Azure Web App with Node.js runtime
     - Python → Azure Web App with Python runtime
     - Java → Azure Web App with Java runtime
     - .NET → Azure Web App with .NET Core runtime
     - PHP → Azure Web App with PHP runtime
     - Ruby → Azure Web App with Ruby runtime
     - Static sites → Azure Web App with Node.js + Express server
   - **Azure Container Apps**: Containerized deployments
   - **Azure Functions**: Serverless applications
   - **AWS**: Elastic Beanstalk, ECS, Lambda, S3 (alternative)
   - **Docker**: Build and push to Docker Hub, GitHub Container Registry, or Azure Container Registry
   - **None**: Skip deployment, only build and test

7) Configure workflow triggers:
   - Push to main/master branch
   - Pull requests to main/master
   - Manual workflow dispatch
   - Optional: scheduled builds

8) Add environment-specific configurations:
   - Development, staging, production environments
   - Required secrets documentation
   - Environment variables template

## Phase 3: Pipeline Generation and Creation
9) Generate the complete GitHub Actions workflow YAML file:
   - Path: `.github/workflows/ci-cd-pipeline.yml`
   - Include comprehensive comments explaining each step
   - Use matrix strategies for multi-version testing if appropriate
   - Add status badges configuration

10) Generate supporting files:
    - `.github/workflows/README.md` - Documentation for the CI/CD pipeline
    - `.env.example` - Template for required environment variables
    - `DEPLOYMENT.md` - Deployment instructions and prerequisites

11) Create a pull request or commit directly (based on permissions):
    - Branch name: `ci-cd-pipeline-setup`
    - Commit message: "feat: Add automated CI/CD pipeline for [detected tech stack]"
    - PR title: "🚀 Add CI/CD Pipeline with Auto-Detection"
    - PR description with:
      - Detected tech stack summary
      - Pipeline capabilities
      - Required secrets to configure
      - Next steps for team

12) Validate the generated workflow:
    - Check YAML syntax
    - Verify all actions use pinned versions or major version tags
    - Ensure secrets are referenced correctly
    - Validate matrix configurations
    - Verify dependency installation commands are correct for detected package managers
    - Ensure all lockfiles are checked in (package-lock.json, yarn.lock, etc.)

## Phase 3.5: Dependency Installation Examples in Generated Workflow

**Example 1: Node.js with npm (Most Common)**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18.x'
    cache: 'npm'  # Enable caching

- name: Install dependencies
  run: npm ci  # Clean install using lockfile
  
- name: Build application
  run: npm run build
```

**Example 2: Python with requirements.txt**
```yaml
- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'

- name: Upgrade pip
  run: python -m pip install --upgrade pip

- name: Install dependencies
  run: |
    pip install -r requirements.txt
    pip install pytest pytest-cov  # Additional test dependencies
```

**Example 3: Java with Maven**
```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    java-version: '17'
    distribution: 'temurin'
    cache: 'maven'

- name: Build with Maven
  run: mvn clean install -DskipTests  # Install dependencies and build
```

**Example 4: Multi-Language Project (Node.js + Python)**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18.x'

- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'

- name: Install Node.js dependencies
  working-directory: ./frontend
  run: npm ci

- name: Install Python dependencies
  working-directory: ./backend
  run: pip install -r requirements.txt
```

**Example 5: Conditional Installation (No Dependencies)**
```yaml
- name: Check for dependencies
  id: check-deps
  run: |
    if [ -f "package.json" ]; then
      echo "has_nodejs=true" >> $GITHUB_OUTPUT
    fi
    if [ -f "requirements.txt" ]; then
      echo "has_python=true" >> $GITHUB_OUTPUT
    fi

- name: Setup Node.js
  if: steps.check-deps.outputs.has_nodejs == 'true'
  uses: actions/setup-node@v4
  with:
    node-version: '18.x'
    cache: 'npm'

- name: Install Node.js dependencies
  if: steps.check-deps.outputs.has_nodejs == 'true'
  run: npm ci

- name: Setup Python
  if: steps.check-deps.outputs.has_python == 'true'
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'

- name: Install Python dependencies
  if: steps.check-deps.outputs.has_python == 'true'
  run: pip install -r requirements.txt
```

**Example 6: System Dependencies**
```yaml
- name: Install system dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y \
      libpq-dev \
      postgresql-client \
      build-essential

- name: Install application dependencies
  run: npm ci
```

## Phase 4: Output and Summary
13) Provide a comprehensive summary including:
    - **Detected Technologies**: Languages, frameworks, tools with versions
    - **Dependencies**: Runtime and dev dependencies count
    - **Build Configuration**: Commands, scripts, environment requirements
    - **Test Setup**: Test frameworks, coverage tools
    - **Pipeline Features**: Stages included, deployment target
    - **Generated Files**: List with descriptions
    - **Required Actions**: Secrets to configure, repository settings to enable
    - **Workflow URL**: Direct link to the workflow file in GitHub
    - **Next Steps**: How to trigger first build, monitoring instructions

Parameters:
- `GITHUB_REPO_OWNER` (required): GitHub repository owner/organization
- `GITHUB_REPO_NAME` (required): Repository name
- `GITHUB_BRANCH` (optional, default: "main"): Target branch for analysis and workflow
- `DEPLOYMENT_TARGET` (optional, default: "azure"): Where to deploy (azure|aws|docker|none)
- `ENABLE_CODE_SCANNING` (optional, default: "true"): Enable CodeQL security scanning
- `ENABLE_DEPENDENCY_REVIEW` (optional, default: "true"): Enable dependency vulnerability scanning
- `CREATE_PR` (optional, default: "true"): Create PR instead of direct commit
- `RUNNER_OS` (optional, default: "ubuntu-latest"): GitHub Actions runner OS
- `NODE_VERSION` (optional): Override detected Node.js version
- `PYTHON_VERSION` (optional): Override detected Python version
- `JAVA_VERSION` (optional): Override detected Java version
- `DOTNET_VERSION` (optional): Override detected .NET version

Environment Variables to Set (PowerShell):
```powershell
$env:GITHUB_REPO_OWNER = "your-github-username"
$env:GITHUB_REPO_NAME = "your-repository-name"
$env:GITHUB_BRANCH = "main"  # optional
$env:DEPLOYMENT_TARGET = "azure"  # default: azure (auto-creates Web App) | aws|docker|none
$env:ENABLE_CODE_SCANNING = "true"  # optional
$env:CREATE_PR = "true"  # optional
```

Example Invocation:
1. Set required environment variables as shown above
2. Execute this prompt through your MCP client
3. Review the generated workflow and supporting documentation
4. Merge the PR or push changes
5. Configure required secrets in GitHub repository settings
6. Push code to trigger the first build

Expected Output:
```json
{
  "analysis": {
    "techStack": {
      "languages": ["JavaScript", "TypeScript"],
      "runtime": "Node.js 18.x",
      "framework": "Next.js 14.0.0",
      "packageManager": "npm",
      "buildTool": "next build",
      "testFramework": "Jest"
    },
    "dependencies": {
      "runtime": 25,
      "development": 15,
      "vulnerabilities": 0
    },
    "deployment": {
      "type": "Static Site",
      "artifacts": "out/",
      "containerized": false
    }
  },
  "pipeline": {
    "stages": ["checkout", "setup", "install", "build", "test", "security", "deploy"],
    "triggers": ["push", "pull_request", "workflow_dispatch"],
    "runners": ["ubuntu-latest"],
    "estimatedBuildTime": "3-5 minutes"
  },
  "generatedFiles": [
    ".github/workflows/ci-cd-pipeline.yml",
    ".github/workflows/README.md",
    ".env.example",
    "DEPLOYMENT.md"
  ],
  "requiredSecrets": [
    "AZURE_WEBAPP_PUBLISH_PROFILE",
    "AZURE_CREDENTIALS"
  ],
  "pullRequest": {
    "number": 42,
    "url": "https://github.com/owner/repo/pull/42",
    "branch": "ci-cd-pipeline-setup"
  },
  "nextSteps": [
    "Review and merge PR #42",
    "Configure required secrets in repository settings",
    "Enable GitHub Actions if not already enabled",
    "Push code to trigger first workflow run",
    "Monitor workflow execution at Actions tab"
  ]
}
```

Validation:
- Tech stack detection must identify at least one primary language/framework
- Generated workflow must pass GitHub Actions YAML validation
- All referenced actions must exist and be accessible
- Build commands must match detected package manager conventions
- Test commands must match detected test framework
- Deployment configuration must be valid for specified target
- PR/commit must be created successfully

Error Handling:
- If repository not accessible: Provide clear authentication instructions
- If no tech stack detected: Request manual specification
- If unsupported framework: Generate basic template and document manual steps
- If deployment target invalid: Fall back to build-only pipeline
- If workflow creation fails: Provide YAML content for manual creation

Security Considerations:
- Never commit secrets or credentials to the repository
- Use GitHub Secrets for sensitive values
- Enable branch protection rules recommendation
- Suggest dependabot configuration for dependency updates
- Include security scanning stages
- Use OIDC for cloud provider authentication when possible

Best Practices Applied:
- Pin action versions for reproducibility
- Use caching to speed up builds
- Implement fail-fast strategies
- Generate clear, commented workflow files
- Include build status badges
- Document all manual setup steps
- Provide troubleshooting guidance

```