$search_url = "https://srch-soft-eng-gen-ai-ken.search.windows.net"
$aoai_resource_url = "https://aif-soft-eng-gen-ai-prod.openai.azure.com"
$aoai_deployment_name_chat_completion = "oaidpl-soft-eng-gen-ai-prod-chat"
$aoai_deployment_name_embedding = "oaidpl-soft-eng-gen-ai-prod-embedding"
$aoai_model_name_chat_completion = "gpt-5"
$aoai_model_name_embedding = "text-embedding-3-large"
$storage_account_connection_string = "ResourceId=/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.Storage/storageAccounts/stsegenaiprod"

$ErrorActionPreference = "Stop"

# Resolve paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pyFile = Join-Path $scriptDir "KnowledgeBase.py"
$tempPyFile = Join-Path $scriptDir "KnowledgeBase.run.py"
$requirements = Join-Path $scriptDir "requirements.txt"

if (!(Test-Path $pyFile)) {
    Write-Error "Python file not found: $pyFile"
}

# Read original content
$content = Get-Content -Raw -Path $pyFile

#substitute any placeholders if needed
$content = $content -replace '{search_url}', $search_url
$content = $content -replace '{aoai_resource_url}', $aoai_resource_url
$content = $content -replace '{aoai_deployment_name_chat_completion}', $aoai_deployment_name_chat_completion
$content = $content -replace '{aoai_deployment_name_embedding}', $aoai_deployment_name_embedding
$content = $content -replace '{aoai_model_name_chat_completion}', $aoai_model_name_chat_completion
$content = $content -replace '{aoai_model_name_embedding}', $aoai_model_name_embedding  
$content = $content -replace '{storage_account_connection_string}', $storage_account_connection_string

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