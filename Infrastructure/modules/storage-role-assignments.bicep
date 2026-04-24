// Storage Account role assignments for Container Apps managed identities
targetScope = 'resourceGroup'

@description('Batch Managed Identity Principal ID')
param batchManagedIdentityPrincipalId string

@description('Tour Guide Managed Identity Principal ID')
param tourGuideManagedIdentityPrincipalId string

@description('MCP Tour Guide Managed Identity Principal ID')
param mcpTourGuideManagedIdentityPrincipalId string

@description('Copilot Managed Identity Principal ID')
param copilotManagedIdentityPrincipalId string

@description('Storage Account ID')
param storageAccountId string

// =====================================
// Role Definition IDs
// =====================================
var storageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// =====================================
// Storage Account Role Assignments
// =====================================

// Reference to Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: split(storageAccountId, '/')[8]
}

// Storage Blob Data Reader for copilot
resource copilotStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, copilotManagedIdentityPrincipalId, storageBlobDataReaderRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReaderRoleId)
    principalId: copilotManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Blob Data Reader for tour-guide
resource tourGuideStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, tourGuideManagedIdentityPrincipalId, storageBlobDataReaderRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReaderRoleId)
    principalId: tourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Blob Data Reader for mcp-tour-gd
resource mcpTourGuideStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, mcpTourGuideManagedIdentityPrincipalId, storageBlobDataReaderRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReaderRoleId)
    principalId: mcpTourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Blob Data Contributor for batch job
resource batchStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, batchManagedIdentityPrincipalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: batchManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
