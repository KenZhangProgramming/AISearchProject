// AI Foundry / OpenAI role assignments for Container Apps managed identities
targetScope = 'resourceGroup'

@description('Persona Managed Identity Principal ID')
param personaManagedIdentityPrincipalId string

@description('Tour Guide Managed Identity Principal ID')
param tourGuideManagedIdentityPrincipalId string

@description('MCP Tour Guide Managed Identity Principal ID')
param mcpTourGuideManagedIdentityPrincipalId string

@description('Copilot Managed Identity Principal ID')
param copilotManagedIdentityPrincipalId string

@description('Outdoor Activity Managed Identity Principal ID')
param outdoorActivityManagedIdentityPrincipalId string

@description('OpenAI Resource ID')
param openaiId string

// =====================================
// Role Definition IDs
// =====================================
var azureAiUserRoleId = '53ca6127-db72-4b80-b1b0-d745d6d5456d'

// =====================================
// OpenAI (Azure AI User) Role Assignments
// =====================================

// Reference to OpenAI resource
resource openaiResource 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: split(openaiId, '/')[8]
}

// persona
resource personaOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openaiId, personaManagedIdentityPrincipalId, azureAiUserRoleId)
  scope: openaiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: personaManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// tour-guide
resource tourGuideOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openaiId, tourGuideManagedIdentityPrincipalId, azureAiUserRoleId)
  scope: openaiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: tourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// mcp-tour-gd
resource mcpTourGuideOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openaiId, mcpTourGuideManagedIdentityPrincipalId, azureAiUserRoleId)
  scope: openaiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: mcpTourGuideManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// copilot
resource copilotOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openaiId, copilotManagedIdentityPrincipalId, azureAiUserRoleId)
  scope: openaiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: copilotManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// outdoor-aty
resource outdoorAtyOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openaiId, outdoorActivityManagedIdentityPrincipalId, azureAiUserRoleId)
  scope: openaiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: outdoorActivityManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
