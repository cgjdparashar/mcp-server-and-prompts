```prompt
Title: Detect Tech Stack and Generate Azure DevOps CI/CD Pipeline

Goal: Analyze an Azure DevOps repository to detect its technology stack, then automatically generate and configure a complete CI/CD pipeline (Azure Pipelines YAML) that builds, tests, and deploys the application to Azure with all required dependencies.

Preconditions:
- Azure DevOps MCP server is connected and authenticated with appropriate permissions.
- Repository access (read for analysis, write for creating pipeline files).
- Target repository specified via `AZDO_ORG_URL`, `AZDO_PROJECT`, and `AZDO_REPO_NAME`.
- Azure subscription available for deployment.
- Optional: `AZDO_BRANCH` (default: "main"), `DEPLOYMENT_TARGET` (default: "azure-webapp").

System/Tool Context:
- Use Azure DevOps REST API via MCP server tools to read repository contents.
- Analyze package managers, configuration files, and project structure.
- Generate Azure Pipelines YAML with appropriate agents and tasks.
- Configure Azure service connections for deployment.
- Respect repository permissions and branch policies.

Instructions:

## Phase 1: Tech Stack Detection

1) Connect to Azure DevOps organization and fetch repository structure for `AZDO_PROJECT/AZDO_REPO_NAME`.

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
   - Serverless functions (Azure Functions)
   - Native executables
   - Web applications (Azure App Service)

## Phase 2: Azure DevOps Pipeline Design

6) Based on detected tech stack, design an Azure Pipelines YAML with:
   
   **Pipeline Configuration:**
   - Trigger: Automatically trigger on commits to main/master branch and PRs
   - Pool: Select appropriate agent pool (ubuntu-latest, windows-latest, macos-latest)
   - Variables: Define build configuration, runtime versions, deployment settings
   - Stages: Build, Test, Security Scan, Deploy
   
   **Build Stage:**
   - Select appropriate VM image (ubuntu-latest, windows-latest, vs2017-win2016)
   - Install language runtime using appropriate task:
     * NodeTool@0, UsePythonVersion@0, JavaToolInstaller@0, UseDotNet@2
   - Specify correct versions from detected configuration
   - Cache dependencies for faster builds
   
   **Automatic Dependency Installation (CRITICAL - Must Include):**
   Install ALL required dependencies based on detected tech stack:
   
   - **Node.js/JavaScript/TypeScript:**
     ```yaml
     - task: NodeTool@0
       inputs:
         versionSpec: '18.x'
       displayName: 'Install Node.js'
     
     - task: Cache@2
       inputs:
         key: 'npm | "$(Agent.OS)" | package-lock.json'
         path: $(npm_config_cache)
       displayName: 'Cache npm packages'
     
     - script: |
         npm ci
       displayName: 'Install dependencies'
       condition: and(succeeded(), exists('package-lock.json'))
     
     - script: |
         yarn install --frozen-lockfile
       displayName: 'Install dependencies (Yarn)'
       condition: and(succeeded(), exists('yarn.lock'))
     
     - script: |
         pnpm install --frozen-lockfile
       displayName: 'Install dependencies (pnpm)'
       condition: and(succeeded(), exists('pnpm-lock.yaml'))
     ```
   
   - **Python:**
     ```yaml
     - task: UsePythonVersion@0
       inputs:
         versionSpec: '3.11'
         addToPath: true
       displayName: 'Use Python 3.11'
     
     - task: Cache@2
       inputs:
         key: 'pip | "$(Agent.OS)" | requirements.txt'
         path: $(Pipeline.Workspace)/.pip
       displayName: 'Cache pip packages'
     
     - script: |
         python -m pip install --upgrade pip
         pip install -r requirements.txt
       displayName: 'Install Python dependencies'
       condition: and(succeeded(), exists('requirements.txt'))
     
     - script: |
         pip install poetry
         poetry install --no-root
       displayName: 'Install dependencies (Poetry)'
       condition: and(succeeded(), exists('pyproject.toml'))
     ```
   
   - **Java (Maven):**
     ```yaml
     - task: JavaToolInstaller@0
       inputs:
         versionSpec: '17'
         jdkArchitectureOption: 'x64'
         jdkSourceOption: 'PreInstalled'
       displayName: 'Install Java 17'
     
     - task: Cache@2
       inputs:
         key: 'maven | "$(Agent.OS)" | **/pom.xml'
         path: $(MAVEN_CACHE_FOLDER)
       displayName: 'Cache Maven packages'
     
     - task: Maven@3
       inputs:
         mavenPomFile: 'pom.xml'
         goals: 'clean install'
         options: '-DskipTests=true'
         publishJUnitResults: false
       displayName: 'Build with Maven'
     ```
   
   - **Java (Gradle):**
     ```yaml
     - task: JavaToolInstaller@0
       inputs:
         versionSpec: '17'
         jdkArchitectureOption: 'x64'
         jdkSourceOption: 'PreInstalled'
       displayName: 'Install Java 17'
     
     - task: Cache@2
       inputs:
         key: 'gradle | "$(Agent.OS)" | **/build.gradle*'
         path: $(GRADLE_USER_HOME)
       displayName: 'Cache Gradle packages'
     
     - task: Gradle@2
       inputs:
         workingDirectory: ''
         gradleWrapperFile: 'gradlew'
         gradleOptions: '-Xmx3072m'
         javaHomeOption: 'JDKVersion'
         jdkVersionOption: '1.17'
         jdkArchitectureOption: 'x64'
         publishJUnitResults: false
         tasks: 'build'
       displayName: 'Build with Gradle'
     ```
   
   - **.NET/C#:**
     ```yaml
     - task: UseDotNet@2
       inputs:
         packageType: 'sdk'
         version: '8.0.x'
       displayName: 'Use .NET SDK 8.0'
     
     - task: DotNetCoreCLI@2
       inputs:
         command: 'restore'
         projects: '**/*.csproj'
       displayName: 'Restore NuGet packages'
     
     - task: DotNetCoreCLI@2
       inputs:
         command: 'build'
         projects: '**/*.csproj'
         arguments: '--configuration $(buildConfiguration) --no-restore'
       displayName: 'Build project'
     ```
   
   - **Go:**
     ```yaml
     - task: GoTool@0
       inputs:
         version: '1.21'
       displayName: 'Install Go 1.21'
     
     - script: |
         go mod download
         go mod verify
       displayName: 'Download Go dependencies'
     ```
   
   - **Ruby:**
     ```yaml
     - task: UseRubyVersion@0
       inputs:
         versionSpec: '>= 3.2'
       displayName: 'Use Ruby >= 3.2'
     
     - script: |
         gem install bundler
         bundle install --jobs=4 --retry=3
       displayName: 'Install Ruby dependencies'
     ```
   
   - **PHP:**
     ```yaml
     - script: |
         php -v
         curl -sS https://getcomposer.org/installer | php
         php composer.phar install --no-interaction --prefer-dist --optimize-autoloader
       displayName: 'Install PHP dependencies'
     ```
   
   **Test Stage:**
   - Run unit tests with appropriate task
   - Run integration tests if detected
   - Publish test results using PublishTestResults@2
   - Publish code coverage using PublishCodeCoverageResults@1
   - Generate and upload test artifacts
   
   **Security Checks:**
   - Dependency vulnerability scanning
   - Static code analysis using SonarQube or similar
   - Security scanning for container images
   
   **Deployment Stage (DEFAULT: Azure Web Apps - auto-create based on tech stack):**
   - **Azure App Service (Web Apps)** (PRIMARY):
     - Uses Azure service connection for authentication
     - Automatically creates Resource Group, App Service Plan, and Web App using Azure CLI
     - Deploys based on detected runtime:
       * Node.js → Azure Web App with Node.js runtime (NODE|18-lts)
       * Python → Azure Web App with Python runtime (PYTHON|3.11)
       * Java → Azure Web App with Java runtime (JAVA|17-java17)
       * .NET → Azure Web App with .NET Core runtime (DOTNETCORE|8.0)
       * PHP → Azure Web App with PHP runtime (PHP|8.2)
       * Ruby → Azure Web App with Ruby runtime (RUBY|3.2)
       * Static sites → Azure Static Web Apps or App Service with Node.js + Express
     - Uses AzureWebApp@1 or AzureRmWebAppDeployment@4 task
     - Requires: Azure service connection, resource group name, web app name
   
   - **Azure Container Instances**: For containerized applications
   - **Azure Kubernetes Service (AKS)**: For container orchestration
   - **Azure Functions**: For serverless applications
   - **Azure Static Web Apps**: For static sites and JAMstack apps
   - **None**: Skip deployment, only build and test

7) Configure pipeline triggers:
   - CI trigger: Push to main/master/develop branches
   - PR trigger: Pull requests to main/master
   - Manual trigger: Allow manual runs via Azure DevOps UI
   - Scheduled trigger (optional): Nightly builds

8) Add environment-specific configurations:
   - Variable groups for dev, staging, production
   - Service connections for Azure
   - Approval gates for production deployments
   - Environment variables and secrets

## Phase 3: Pipeline Generation and Azure Setup

9) Generate the complete Azure Pipelines YAML file:
   - Path: `azure-pipelines.yml` (root of repository)
   - Include comprehensive comments explaining each task
   - Use templates for reusable components if appropriate
   - Add conditional execution based on branch/environment

10) Generate supporting files:
    - `docs/AZURE-DEVOPS-PIPELINE.md` - Documentation for the CI/CD pipeline
    - `.env.example` - Template for required environment variables
    - `DEPLOYMENT.md` - Deployment instructions and prerequisites
    - `scripts/setup-azure-service-connection.ps1` - Script to create Azure service connection

11) Create Azure service connection setup script:
    - PowerShell script to automate service connection creation
    - Creates Service Principal with appropriate permissions
    - Configures Azure DevOps service connection
    - Generates required variables for pipeline:
      * Azure subscription ID
      * Service Principal credentials
      * Resource group name
      * Web app name
      * Location
      * SKU/pricing tier

12) Set up Azure resources (if deployment enabled):
    - Create Resource Group in Azure
    - Create App Service Plan with appropriate SKU
    - Create Web App with detected runtime stack
    - Configure application settings and connection strings
    - Set up deployment slots (staging, production)

13) Create variable groups in Azure DevOps:
    - **Azure-Connection** variables:
      * `azureSubscription` - Service connection name
      * `resourceGroupName` - Azure resource group
      * `webAppName` - Azure web app name
      * `location` - Azure region (e.g., eastus, westus2)
      * `sku` - App Service SKU (e.g., F1, B1, P1V2)
    
    - **Build-Configuration** variables:
      * `buildConfiguration` - Release/Debug
      * `nodeVersion` - Node.js version
      * `pythonVersion` - Python version
      * `javaVersion` - Java version
      * `dotnetVersion` - .NET version

14) Configure pipeline in Azure DevOps:
    - Create new pipeline from YAML file
    - Link to azure-pipelines.yml in repository
    - Configure branch policies to require successful build
    - Set up notifications for build status
    - Configure retention policies for artifacts

15) Create or update the pipeline:
    - Commit azure-pipelines.yml to repository
    - Branch name: `azure-devops-pipeline-setup`
    - Commit message: "feat: Add Azure DevOps CI/CD pipeline for [detected tech stack]"
    - Create pull request with:
      * Detected tech stack summary
      * Pipeline capabilities
      * Required service connections and variables
      * Next steps for team

16) Validate the generated pipeline:
    - Check YAML syntax using Azure DevOps schema validation
    - Verify all tasks use stable versions
    - Ensure variables and service connections are referenced correctly
    - Validate dependency installation commands for detected package managers
    - Ensure all lockfiles are committed
    - For Azure deployment:
      * Verify service connection is configured
      * Confirm Azure CLI tasks use correct subscription
      * Validate resource names follow Azure naming conventions
      * Ensure all required variables are defined

## Phase 4: Output and Summary

17) Provide a comprehensive summary including:
    - **Detected Technologies**: Languages, frameworks, tools with versions
    - **Dependencies**: Runtime and dev dependencies count
    - **Build Configuration**: Commands, scripts, environment requirements
    - **Test Setup**: Test frameworks, coverage tools
    - **Pipeline Features**: Stages included, deployment target
    - **Generated Files**: List with descriptions
    - **Required Actions**: 
      * Service connections to configure
      * Variable groups to create
      * Azure resources to provision
      * Repository settings to enable
    - **Azure Setup Steps**:
      * Run setup script: `.\scripts\setup-azure-service-connection.ps1`
      * Create service connection in Azure DevOps
      * Configure variable groups with required values
      * Create Azure resources (Resource Group, App Service Plan, Web App)
      * Reference: `docs/AZURE-DEVOPS-PIPELINE.md` for detailed instructions
    - **Pipeline URL**: Direct link to the pipeline in Azure DevOps
    - **Next Steps**: How to trigger first build, monitoring instructions

Parameters:
- `AZDO_ORG_URL` (required): Azure DevOps organization URL (e.g., "https://dev.azure.com/your-org")
- `AZDO_PROJECT` (required): Azure DevOps project name
- `AZDO_REPO_NAME` (required): Repository name
- `AZDO_BRANCH` (optional, default: "main"): Target branch for analysis and pipeline
- `DEPLOYMENT_TARGET` (optional, default: "azure-webapp"): Where to deploy (azure-webapp|azure-functions|azure-container|aks|azure-static|none)
- `AZURE_SUBSCRIPTION_ID` (required for deployment): Azure subscription ID
- `AZURE_LOCATION` (optional, default: "eastus"): Azure region for resources
- `AZURE_SKU` (optional, default: "B1"): App Service SKU (F1|B1|B2|B3|S1|S2|S3|P1V2|P2V2|P3V2)
- `ENABLE_CODE_SCANNING` (optional, default: "true"): Enable SonarQube/security scanning
- `ENABLE_TEST_COVERAGE` (optional, default: "true"): Enable code coverage reporting
- `CREATE_PR` (optional, default: "true"): Create PR instead of direct commit
- `AGENT_POOL` (optional, default: "Azure Pipelines"): Agent pool to use
- `NODE_VERSION` (optional): Override detected Node.js version
- `PYTHON_VERSION` (optional): Override detected Python version
- `JAVA_VERSION` (optional): Override detected Java version
- `DOTNET_VERSION` (optional): Override detected .NET version

Environment Variables to Set (PowerShell):
```powershell
# Required
$env:AZDO_ORG_URL = "https://dev.azure.com/your-org"
$env:AZDO_PROJECT = "YourProject"
$env:AZDO_REPO_NAME = "your-repository"

# For deployment
$env:AZURE_SUBSCRIPTION_ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$env:AZURE_LOCATION = "eastus"  # optional
$env:AZURE_SKU = "B1"  # optional
$env:DEPLOYMENT_TARGET = "azure-webapp"  # default

# Optional
$env:AZDO_BRANCH = "main"  # optional
$env:ENABLE_CODE_SCANNING = "true"  # optional
$env:CREATE_PR = "true"  # optional
```

Example Invocation:
1. Set required environment variables as shown above
2. Execute this prompt through your MCP client with Azure DevOps connection
3. Review the generated pipeline and supporting documentation
4. Run setup script to create Azure service connection
5. Create variable groups in Azure DevOps
6. Provision Azure resources if needed
7. Merge the PR or push changes
8. Configure service connection in Azure DevOps project settings
9. Trigger the pipeline manually or push code to activate CI trigger

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
      "type": "Azure App Service",
      "runtime": "NODE|18-lts",
      "artifacts": "out/",
      "containerized": false
    }
  },
  "pipeline": {
    "stages": ["Build", "Test", "Security", "Deploy"],
    "triggers": ["CI", "PR", "Manual"],
    "pool": "Azure Pipelines",
    "vmImage": "ubuntu-latest",
    "estimatedBuildTime": "3-5 minutes"
  },
  "generatedFiles": [
    "azure-pipelines.yml",
    "docs/AZURE-DEVOPS-PIPELINE.md",
    "scripts/setup-azure-service-connection.ps1",
    ".env.example",
    "DEPLOYMENT.md"
  ],
  "azureResources": {
    "resourceGroup": "myapp-rg",
    "appServicePlan": "myapp-plan",
    "webApp": "myapp-webapp",
    "location": "eastus",
    "sku": "B1"
  },
  "requiredSetup": {
    "serviceConnection": {
      "name": "Azure-Service-Connection",
      "type": "AzureRM",
      "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "subscriptionName": "Your Subscription"
    },
    "variableGroups": [
      {
        "name": "Azure-Connection",
        "variables": [
          "azureSubscription",
          "resourceGroupName",
          "webAppName",
          "location",
          "sku"
        ]
      },
      {
        "name": "Build-Configuration",
        "variables": [
          "buildConfiguration",
          "nodeVersion"
        ]
      }
    ]
  },
  "pullRequest": {
    "id": 123,
    "url": "https://dev.azure.com/your-org/YourProject/_git/your-repo/pullrequest/123",
    "branch": "azure-devops-pipeline-setup",
    "status": "Active"
  },
  "nextSteps": [
    "Review and complete PR #123",
    "Run setup script: .\\scripts\\setup-azure-service-connection.ps1",
    "Create service connection in Azure DevOps: Project Settings → Service connections → New service connection → Azure Resource Manager",
    "Create variable groups: Pipelines → Library → Add variable group",
    "Provision Azure resources (Resource Group, App Service Plan, Web App)",
    "Configure branch policies to require build success",
    "Merge PR to activate CI trigger",
    "Monitor pipeline execution in Pipelines tab"
  ]
}
```

Validation:
- Tech stack detection must identify at least one primary language/framework
- Generated pipeline must pass Azure Pipelines YAML schema validation
- All referenced tasks must be available in Azure DevOps
- Build commands must match detected package manager conventions
- Test commands must match detected test framework
- Deployment configuration must be valid for specified Azure target
- Service connection configuration must be valid
- Variable references must be consistent
- PR/commit must be created successfully

Error Handling:
- If repository not accessible: Provide clear authentication instructions for Azure DevOps
- If no tech stack detected: Request manual specification
- If unsupported framework: Generate basic template and document manual steps
- If deployment target invalid: Fall back to build-only pipeline
- If pipeline creation fails: Provide YAML content for manual creation
- If Azure subscription not accessible: Provide instructions to set up service connection
- If service connection creation fails:
  * Verify Azure subscription permissions
  * Check Service Principal has Contributor role
  * Ensure Azure DevOps has permission to create service connections
  * Reference: Azure DevOps documentation for service connection setup
- If resource creation fails:
  * Verify resource names are globally unique (web app names)
  * Check subscription quotas and limits
  * Ensure location supports required services
  * Validate SKU is available in selected region

Security Considerations:
- Never commit secrets or credentials to the repository
- Use Azure DevOps variable groups with secret variables
- Mark sensitive variables as secret in variable groups
- Enable branch policies to require successful build before merge
- Use service connections for Azure authentication (Managed Identity preferred)
- Implement approval gates for production deployments
- For Azure deployment:
  * Use Service Principal with minimum required permissions (Contributor on Resource Group)
  * Rotate Service Principal secrets regularly
  * Use Azure Key Vault for application secrets
  * Enable Azure AD authentication for App Service
  * Configure network restrictions (IP whitelisting) for App Service
  * Use deployment slots for zero-downtime deployments
  * Store connection strings and app settings in Azure, not in code

Best Practices Applied:
- Use stable task versions for reproducibility (e.g., `NodeTool@0`, `AzureWebApp@1`)
- Leverage caching to speed up builds (npm, pip, Maven, NuGet)
- Implement fail-fast strategies (stop on first error)
- Generate clear, commented pipeline files
- Include build badges in README
- Document all manual setup steps
- Provide troubleshooting guidance
- For Azure deployments:
  * Automatically create Azure resources if they don't exist (idempotent)
  * Detect tech stack and configure appropriate Azure runtime
  * Use appropriate App Service Plan SKU for environment (F1 for dev, B1+ for prod)
  * Enable Application Insights for monitoring
  * Configure auto-scaling rules for production
  * Use deployment slots (staging) for production deployments
  * Include comprehensive logging for debugging
  * Validate all variables and connections before deployment
  * Provide clear error messages for missing configuration
  * Use multi-stage pipelines for separation of concerns
  * Implement proper artifact management between stages

Example Pipeline Structure:
```yaml
trigger:
  branches:
    include:
    - main
    - develop

pr:
  branches:
    include:
    - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: Azure-Connection
  - group: Build-Configuration
  - name: buildConfiguration
    value: 'Release'

stages:
- stage: Build
  displayName: 'Build Application'
  jobs:
  - job: BuildJob
    displayName: 'Build and Test'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '$(nodeVersion)'
      displayName: 'Install Node.js'
    
    - task: Cache@2
      inputs:
        key: 'npm | "$(Agent.OS)" | package-lock.json'
        path: $(npm_config_cache)
      displayName: 'Cache npm packages'
    
    - script: npm ci
      displayName: 'Install dependencies'
    
    - script: npm run build
      displayName: 'Build application'
    
    - script: npm test
      displayName: 'Run tests'
    
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results.xml'
      displayName: 'Publish test results'
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: 'dist'
        artifactName: 'drop'
      displayName: 'Publish artifacts'

- stage: Deploy
  displayName: 'Deploy to Azure'
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployWeb
    displayName: 'Deploy to Azure Web App'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: '$(azureSubscription)'
              appType: 'webAppLinux'
              appName: '$(webAppName)'
              package: '$(Pipeline.Workspace)/drop'
              runtimeStack: 'NODE|18-lts'
            displayName: 'Deploy to Azure Web App'
```

Notes:
- Azure DevOps requires a service connection to be created manually in the UI
- Variable groups must be created through Azure DevOps Library
- The setup script will guide through Service Principal creation
- First deployment may take longer as Azure provisions resources
- Consider using deployment slots for production deployments
- Enable Application Insights for monitoring deployed applications
```
