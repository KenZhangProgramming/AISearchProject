$SearchServiceEndpoint = "https://srch-soft-eng-gen-ai-prod.search.windows.net"
$KnowledgebaseName = "weekend-events"
$ProjectEndpoint = "https://aif-soft-eng-gen-ai-prod.services.ai.azure.com/api/projects/proj-soft-eng-gen-ai-prod"
$KnowledgebaseConnectionName = "kb-weekend-events"
$AgentName = "weekend-planner"
$DeployedLLM = "oaidpl-soft-eng-gen-ai-prod-chat"

$ErrorActionPreference = "Stop"

# Resolve paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pyFile = Join-Path $scriptDir "WeekendPlanner.py"
$tempPyFile = Join-Path $scriptDir "WeekendPlanner.run.py"
$requirements = Join-Path $scriptDir "requirements.txt"

if (!(Test-Path $pyFile)) {
    Write-Error "Python file not found: $pyFile"
}

# Read original content
$content = Get-Content -Raw -Path $pyFile

# Replace placeholders with provided values
$content = $content -replace '{search_service_endpoint}', $SearchServiceEndpoint
$content = $content -replace '{knowledge_base_name}', $KnowledgebaseName
$content = $content -replace '{project_endpoint}', $ProjectEndpoint
$content = $content -replace '{knowledgebase_connection_name}', $KnowledgebaseConnectionName
$content = $content -replace '{agent_name}', $AgentName
$content = $content -replace '{deployed_LLM}', $DeployedLLM

# Write temp file
Set-Content -Path $tempPyFile -Value $content -Encoding UTF8

try {
    Write-Host "Running WeekendPlanner with provided parameters..." -ForegroundColor Cyan
    # Prefer py if available, else python
    $pythonCmd = "python"
    $pythonVersion = (& $pythonCmd --version 2>$null)
    if (-not $pythonVersion) {
        $pythonCmd = "py"
    }

    if (Test-Path $requirements) {
        Write-Host "Installing Python dependencies from requirements.txt..." -ForegroundColor Yellow
        & $pythonCmd -m pip install --upgrade -r $requirements
    } else {
        Write-Warning "requirements.txt not found at $requirements; skipping dependency installation."
    }

    & $pythonCmd $tempPyFile
}
finally {
    if (-not $KeepTemp -and (Test-Path $tempPyFile)) {
        Remove-Item $tempPyFile -Force
    }
}