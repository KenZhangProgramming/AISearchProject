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

@description('Root name to use for storage accounts (no hyphens)')
param rootNameStorageAccounts string

@description('To Do Canada URL for scraping weekend events (used for reference)')
#disable-next-line no-unused-params
param toDoCanadaUrl string


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