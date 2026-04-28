$search_url = "https://srch-soft-eng-gen-ai-ken.search.windows.net"
$aoai_resource_url = "https://aif-soft-eng-gen-ai-ken.openai.azure.com"
$aoai_deployment_name_chat_completion = "oaidpl-soft-eng-gen-ai-ken-chat"
$aoai_deployment_name_embedding = "oaidpl-soft-eng-gen-ai-ken-embedding"
$aoai_model_name_chat_completion = "gpt-5"
$aoai_model_name_embedding = "text-embedding-3-large"
$storage_account_connection_string    = "ResourceId=/subscriptions/dfeab144-04e8-484d-9a10-f69a6c606451/resourceGroups/rg-soft-eng-gen-ai-AiBootcamp/providers/Microsoft.Storage/storageAccounts/stsegenaiken"
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
    Write-Host "Running Bank Ai Search knowledge base setup with provided parameters..." -ForegroundColor Cyan
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