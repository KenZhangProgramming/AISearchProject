@description('Root name to use for resource naming')
param rootName string

@description('The principal ID of AI Foundry Project to assign search roles to')
param foundryProjectPrincipalId string

@description('Batch Managed Identity Principal ID')
param batchManagedIdentityPrincipalId string

@description('Tour Guide Managed Identity Principal ID')
param tourGuideManagedIdentityPrincipalId string

@description('MCP Tour Guide Managed Identity Principal ID')
param mcpTourGuideManagedIdentityPrincipalId string

// Reference existing AI Search service
resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: 'srch-${rootName}'
}

// Role definitions
var searchIndexDataContributorRoleDefinitionId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
var searchServiceContributorRoleDefinitionId = '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
var searchIndexDataReaderRoleId = '1407120a-92aa-4202-b7e9-c0e197c71c8f'

// =====================================
// AI Foundry -> AI Search Role Assignments
// =====================================

// Role Assignment - Search Index Data Contributor for AI Foundry
resource foundrySearchIndexDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(searchService.id, foundryProjectPrincipalId, searchIndexDataContributorRoleDefinitionId)
  properties: {
    principalId: foundryProjectPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Search Service Contributor for AI Foundry
resource foundrySearchServiceContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(searchService.id, foundryProjectPrincipalId, searchServiceContributorRoleDefinitionId)
  properties: {
    principalId: foundryProjectPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

// =====================================
// Container Apps -> AI Search Role Assignments
// =====================================

// Search Index Data Reader for tour-guide
resource tourGuideSearchRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, tourGuideManagedIdentityPrincipalId, searchIndexDataReaderRoleId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataReaderRoleId)
    principalId: tourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Search Index Data Reader for mcp-tour-gd
resource mcpTourGuideSearchRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, mcpTourGuideManagedIdentityPrincipalId, searchIndexDataReaderRoleId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataReaderRoleId)
    principalId: mcpTourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Search Service Contributor for batch job
resource batchSearchRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, batchManagedIdentityPrincipalId, searchServiceContributorRoleDefinitionId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRoleDefinitionId)
    principalId: batchManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output searchServiceId string = searchService.id
output searchServiceName string = searchService.name
