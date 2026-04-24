@description('Root name to use for all resources')
param rootName string

@description('Location where resources will be deployed')
param location string = 'canadacentral'

@description('Storage Account Name')
param storageAccountName string

// AI Search Service
resource searchService 'Microsoft.Search/searchServices@2025-05-01' = {
  name: 'srch-${rootName}'
  location: location
  sku: {
    name: 'free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    replicaCount: 1
    partitionCount: 1
    semanticSearch: 'free'
    disableLocalAuth: true
  }
}

// Reference existing Storage Account for role assignment
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// Role Assignment - Storage Blob Data Contributor for AI Search
var storageBlobDataContributorRoleDefinitionId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource searchStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, searchService.id, storageBlobDataContributorRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleDefinitionId)
    principalId: searchService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output aiSearchId string = searchService.id
output aiSearchEndpoint string = 'https://${searchService.name}.search.windows.net/'
output aiSearchPrincipalId string = searchService.identity.principalId
