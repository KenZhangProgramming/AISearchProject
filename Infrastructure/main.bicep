targetScope = 'resourceGroup'

// =====================================
// Parameters
// =====================================
@description('Location where resources will be deployed')
param location string

@description('Location for AI resources (may require specific region)')
param locationAi string

@description('Root name to use for all resources')
param rootName string

@description('Short root name used for Container Apps resources that have stricter name length limits (e.g., Container Apps, Jobs, and related identities)')
param rootNameContainerApps string

@description('Root name to use for storage accounts (no hyphens)')
param rootNameStorageAccounts string

@description('DNS Zone name')
param dnsZoneName string

@description('When true, Bicep manages ACA custom domains + managed certificates (overwrites manual bindings).')
param enableCustomDomains bool = true

@description('Optional: Existing managed certificate resource IDs to bind to. Keys: web, apiUi, persona, tourGuide, mcpTourGuide, copilot, outdoorActivity.')
param customDomainCertificateIds object = {}

@description('Optional: Create new managed certificates for these app keys (web, apiUi, persona, tourGuide, mcpTourGuide, copilot, outdoorActivity).')
param createManagedCertificatesKeys array = []

@description('Resource group that contains the DNS Zone and shared ACR')
param commonResourceGroupName string = 'rg-soft-eng-gen-ai-common'

@description('Name of the existing Azure Container Registry in the common resource group')
param containerRegistryName string = 'crsoftenggenaicommon'

@description('Frontend Origin URL')
param frontendOrigin string

@description('Auth Tenant ID for Azure AD authentication')
param authTenantId string

@description('Azure AD domain used by the apps (e.g., avanadeai.com or <tenant>.onmicrosoft.com)')
param azureAdDomain string

@description('To Do Canada URL for scraping weekend events (used for reference)')
#disable-next-line no-unused-params
param toDoCanadaUrl string

// Secure parameters for Container Apps
@description('Open Weather API Key')
@secure()
param openWeatherApiKey string

@description('Google Search API Key')
@secure()
param googleSearchApiKey string

@description('Google Search Engine ID')
@secure()
param googleSearchEngineId string

@description('Entra ID Client Secret for Copilot')
@secure()
param apiCopilotClientSecret string

@description('Strava Client ID')
@secure()
param stravaClientId string

@description('Strava Client Secret')
@secure()
param stravaClientSecret string

// =====================================
// Module: Observability (Log Analytics + App Insights)
// =====================================
module observabilityModule 'modules/observability.bicep' = {
  name: 'observabilityDeployment'
  params: {
    rootName: rootName
    location: location
  }
}

// =====================================
// Module: Storage Account (with containers and file share)
// =====================================
module storageAccountModule 'modules/storage-account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    rootName: rootNameStorageAccounts
    location: location
  }
}

// =====================================
// Module: AI Search (with role assignments)
// =====================================
module aiSearchModule 'modules/ai-search.bicep' = {
  name: 'aiSearchDeployment'
  params: {
    rootName: rootName
    location: location
    storageAccountName: storageAccountModule.outputs.storageAccountName
  }
}

// =====================================
// Module: AI Foundry (references Search + App Insights)
// =====================================
module aiFoundryModule 'modules/ai-foundry.bicep' = {
  name: 'aiFoundryDeployment'
  dependsOn: [
    aiSearchModule
    observabilityModule
  ]
  params: {
    location: locationAi
    rootName: rootName
    storageAccountId: storageAccountModule.outputs.storageAccountId
    storageAccountName: storageAccountModule.outputs.storageAccountName
    storageAccountBlobEndpoint: storageAccountModule.outputs.storageAccountBlobEndpoint
  }
}

// =====================================
// Module: AI Foundry Role Assignments
// =====================================
module aiFoundryRoleAssignmentsModule 'modules/ai-foundry-role-assignments.bicep' = {
  name: 'aiFoundryRoleAssignmentsDeployment'
  params: {
    personaManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.personaManagedIdentityPrincipalId
    tourGuideManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.tourGuideManagedIdentityPrincipalId
    mcpTourGuideManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.mcpTourGuideManagedIdentityPrincipalId
    copilotManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.copilotManagedIdentityPrincipalId
    outdoorActivityManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.outdoorActivityManagedIdentityPrincipalId
    openaiId: aiFoundryModule.outputs.aiFoundryId
  }
}

// =====================================
// Module: Storage Role Assignments
// =====================================
module storageRoleAssignmentsModule 'modules/storage-role-assignments.bicep' = {
  name: 'storageRoleAssignmentsDeployment'
  params: {
    batchManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.batchManagedIdentityPrincipalId
    tourGuideManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.tourGuideManagedIdentityPrincipalId
    mcpTourGuideManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.mcpTourGuideManagedIdentityPrincipalId
    copilotManagedIdentityPrincipalId: containerAppsIdentitiesModule.outputs.copilotManagedIdentityPrincipalId
    storageAccountId: storageAccountModule.outputs.storageAccountId
  }
}

// =====================================
// Outputs
// =====================================
output resourceGroupName string = resourceGroup().name

// Observability
output logAnalyticsWorkspaceId string = observabilityModule.outputs.logAnalyticsWorkspaceId
output appInsightsId string = observabilityModule.outputs.appInsightsId

// Storage
output storageAccountId string = storageAccountModule.outputs.storageAccountId
output storageAccountName string = storageAccountModule.outputs.storageAccountName

// AI Foundry
output aiFoundryId string = aiFoundryModule.outputs.aiFoundryId
output aiFoundryName string = aiFoundryModule.outputs.aiFoundryName
output aiFoundryProjectId string = aiFoundryModule.outputs.aiFoundryProjectId
output aiFoundryProjectName string = aiFoundryModule.outputs.aiFoundryProjectName

// AI Search
output aiSearchId string = aiSearchModule.outputs.aiSearchId
output aiSearchEndpoint string = aiSearchModule.outputs.aiSearchEndpoint