# deploy-full.ps1
# PowerShell script to deploy the full infrastructure using Bicep

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-soft-eng-gen-ai-prod",

    [Parameter(Mandatory = $false)]
    [string]$Location = "canadacentral",

    [Parameter(Mandatory = $false)]
    [string]$ParameterFile = "./main.bicepparam",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Bicep Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$hasAzPowerShell = [bool](Get-Command Get-AzContext -ErrorAction SilentlyContinue)
$hasAzureCli = [bool](Get-Command az -ErrorAction SilentlyContinue)

if (-not $hasAzPowerShell -and -not $hasAzureCli) {
    Write-Host "Neither Azure PowerShell (Az) nor Azure CLI (az) is available." -ForegroundColor Red
    Write-Host "Install one of them to continue deployment." -ForegroundColor Red
    exit 1
}

if ($hasAzPowerShell) {
    # Login check (Azure PowerShell)
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Not logged in to Azure. Please run Connect-AzAccount first." -ForegroundColor Red
        exit 1
    }

    Write-Host "Logged in as: $($context.Account.Id)" -ForegroundColor Green
    Write-Host "Current Subscription: $($context.Subscription.Name)" -ForegroundColor Green

    # Set subscription if provided
    if ($SubscriptionId) {
        Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor Yellow
        Set-AzContext -SubscriptionId $SubscriptionId
    }

    # Check if resource group exists, create if not
    Write-Host "`nChecking resource group: $ResourceGroupName" -ForegroundColor Yellow
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating resource group: $ResourceGroupName in $Location" -ForegroundColor Yellow
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    }
    else {
        Write-Host "Resource group already exists: $ResourceGroupName" -ForegroundColor Green
    }

    # Deploy Bicep template
    Write-Host "`nDeploying Bicep template..." -ForegroundColor Yellow

    $deploymentParams = @{
        Name                  = "seaccelerator-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = "./main.bicep"
        TemplateParameterFile = $ParameterFile
    }

    if ($WhatIf) {
        Write-Host "Running What-If analysis..." -ForegroundColor Cyan
        $result = New-AzResourceGroupDeployment @deploymentParams -WhatIf
    }
    else {
        $result = New-AzResourceGroupDeployment @deploymentParams
        
        if ($result.ProvisioningState -eq "Succeeded") {
            Write-Host "`n==================================" -ForegroundColor Green
            Write-Host "Deployment Succeeded!" -ForegroundColor Green
            Write-Host "==================================" -ForegroundColor Green
            
            Write-Host "`nOutputs:" -ForegroundColor Cyan
            foreach ($output in $result.Outputs.GetEnumerator()) {
                Write-Host "  $($output.Key): $($output.Value.Value)" -ForegroundColor White
            }
        }
        else {
            Write-Host "`nDeployment Failed: $($result.ProvisioningState)" -ForegroundColor Red
            exit 1
        }
    }
}
else {
    # Login check (Azure CLI)
    try {
        $account = az account show --only-show-errors | ConvertFrom-Json
    }
    catch {
        Write-Host "Not logged in to Azure CLI. Please run: az login" -ForegroundColor Red
        exit 1
    }

    Write-Host "Logged in (az) as: $($account.user.name)" -ForegroundColor Green
    Write-Host "Current Subscription: $($account.name) ($($account.id))" -ForegroundColor Green

    if ($SubscriptionId) {
        Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor Yellow
        az account set --subscription $SubscriptionId --only-show-errors | Out-Null
    }

    Write-Host "`nChecking resource group: $ResourceGroupName" -ForegroundColor Yellow
    $rgExists = (az group exists --name $ResourceGroupName --only-show-errors) -eq 'true'
    if (-not $rgExists) {
        Write-Host "Creating resource group: $ResourceGroupName in $Location" -ForegroundColor Yellow
        az group create --name $ResourceGroupName --location $Location --only-show-errors | Out-Null
    }
    else {
        Write-Host "Resource group already exists: $ResourceGroupName" -ForegroundColor Green
    }

    $deploymentName = "seaccelerator-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
    if ($WhatIf) {
        Write-Host "`nRunning What-If analysis..." -ForegroundColor Cyan
        az deployment group what-if --name $deploymentName --resource-group $ResourceGroupName --parameters $ParameterFile --only-show-errors
    }
    else {
        Write-Host "`nDeploying Bicep template..." -ForegroundColor Yellow
        $result = az deployment group create --name $deploymentName --resource-group $ResourceGroupName --parameters $ParameterFile --only-show-errors | ConvertFrom-Json

        if ($null -ne $result.properties -and $result.properties.provisioningState -eq 'Succeeded') {
            Write-Host "`n==================================" -ForegroundColor Green
            Write-Host "Deployment Succeeded!" -ForegroundColor Green
            Write-Host "==================================" -ForegroundColor Green

            if ($null -ne $result.properties.outputs) {
                Write-Host "`nOutputs:" -ForegroundColor Cyan
                foreach ($key in $result.properties.outputs.PSObject.Properties.Name) {
                    Write-Host "  ${key}: $($result.properties.outputs.$key.value)" -ForegroundColor White
                }
            }
        }
        else {
            $state = if ($null -ne $result.properties) { $result.properties.provisioningState } else { 'Unknown' }
            Write-Host "`nDeployment Failed: $state" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "`nDone!" -ForegroundColor Green
