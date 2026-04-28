@description('Location where resources will be deployed')
param location string

@description('Root name to use for all resources')
param rootName string

@description('Storage account resource ID for connection')
param storageAccountId string

@description('Storage account name for connection')
param storageAccountName string

@description('Storage account blob endpoint')
param storageAccountBlobEndpoint string

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: 'srch-${rootName}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'appi-${rootName}'
}

resource account 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: 'aif-${rootName}'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: 'aif-${rootName}'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
    // API-key based auth is not supported for the Agent service
    disableLocalAuth: false
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-10-01-preview' = {
  parent: account
  name: 'proj-${rootName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Personal website'
    description: 'Personal website'
  }
}

resource chatDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview' = {
  parent: account
  name: 'oaidpl-${rootName}-chat'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5.4'
      version: '2026-03-05'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 49
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview' = {
  parent: account
  name: 'oaidpl-${rootName}-embedding'
  dependsOn: [chatDeployment] // Prevent concurrent operations on the same account
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-large'
      version: '1'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 998
  }
}

resource projectConnectionAppInsights 'Microsoft.CognitiveServices/accounts/connections@2025-10-01-preview' = {
  parent: account
  name: appInsights.name
  properties: {
    category: 'AppInsights'
    target: appInsights.id
    authType: 'ApiKey'
    credentials: {
      key: appInsights.properties.InstrumentationKey
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: appInsights.id
    }
  }
}

resource projectConnectionStorage 'Microsoft.CognitiveServices/accounts/connections@2025-10-01-preview' = {
  parent: account
  name: storageAccountName
  properties: {
    category: 'AzureStorageAccount'
    target: storageAccountBlobEndpoint
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: storageAccountId
      location: location
    }
  }
}

resource projectConnectionSearch 'Microsoft.CognitiveServices/accounts/connections@2025-10-01-preview' = {
  parent: account
  name: searchService.name
  properties: {
    category: 'CognitiveSearch'
    target: 'https://${searchService.name}.search.windows.net'
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: searchService.id
      location: searchService.location
    }
  }
}

resource projectConnectionBankAiKnowledgebase 'Microsoft.CognitiveServices/accounts/projects/connections@2025-10-01-preview' = {
  parent: project
  name: 'kb-bank-ai'
  properties: {
    category: 'RemoteTool'
    target: 'https://${searchService.name}.search.windows.net/knowledgebases/bank-ai/mcp?api-version=2025-11-01-Preview'
    #disable-next-line BCP036
    authType: 'ProjectManagedIdentity'
    audience: 'https://search.azure.com/'
    isSharedToAll: true
    metadata: {
      type: 'knowledgeBase_MCP'
      knowledgeBaseName: 'bank-ai'
    }
  }
}

resource azureAiUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '53ca6127-db72-4b80-b1b0-d745d6d5456d'
  scope: resourceGroup()
}

resource searchAiUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, account.id,  azureAiUserRole.id)
  scope: account
  properties: {
    principalId:searchService.identity.principalId
    roleDefinitionId: azureAiUserRole.id
    principalType: 'ServicePrincipal'
  }
}

resource cognitiveServicesOpenAiUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  scope: resourceGroup()
}

resource cognitiveServicesOpenAiUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, account.id,  cognitiveServicesOpenAiUserRole.id)
  scope: account
  properties: {
    principalId:searchService.identity.principalId
    roleDefinitionId: cognitiveServicesOpenAiUserRole.id
    principalType: 'ServicePrincipal'
  }
}

@description('The resource ID of the AI Foundry account')
output aiFoundryId string = account.id

@description('The name of the AI Foundry account')
output aiFoundryName string = account.name

@description('The principal ID of the AI Foundry account system-assigned identity')
output aiFoundryPrincipalId string = account.identity.principalId

@description('The resource ID of the AI Foundry project')
output aiFoundryProjectId string = project.id

@description('The name of the AI Foundry project')
output aiFoundryProjectName string = project.name

@description('The principal ID of the AI Foundry project system-assigned identity')
output aiFoundryProjectPrincipalId string = project.identity.principalId

@description('The OpenAI endpoint URL')
output openaiEndpoint string = 'https://${account.name}.openai.azure.com'

@description('The AI Foundry project endpoint URL')
output aiFoundryProjectEndpoint string = '${account.properties.endpoint}api/projects/${project.name}'

@description('The OpenAI chat deployment name')
output openAiDeploymentName string = chatDeployment.name

@description('The OpenAI embedding deployment name')
output openAiDeploymentNameEmbedding string = embeddingDeployment.name
