@description('Azure region for the AI Foundry resources')
param location string

@description('Base name for Foundry Hub and Project')
param baseName string

@description('Principal ID of the Managed Identity')
param principalId string

@description('Storage Account ID for AI Foundry')
param storageAccountId string

@description('Key Vault ID for AI Foundry')
param keyVaultId string

// Cognitive Services / Azure AI Services account
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: '${baseName}-aiservices'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: toLower('${baseName}-aiservices')
    publicNetworkAccess: 'Enabled'
    apiProperties: {}
  }
}

// Model Deployment: gpt-4o
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    name: 'GlobalStandard'
    capacity: 30
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
  }
}

// Model Deployment: text-embedding-3-large
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'text-embedding-3-large'
  sku: {
    name: 'Standard'
    capacity: 50
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-large'
      version: '1'
    }
  }
  dependsOn: [
    gpt4oDeployment
  ]
}

// Azure AI Foundry Hub (Workspace)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: '${baseName}-hub'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Foundry Sentinel AI Hub'
    description: 'Enterprise Hub for Audited Retrieval & Secure Action Agent Sentinel'
    storageAccount: storageAccountId
    keyVault: keyVaultId
    hbiWorkspace: true
  }
}

// Azure AI Foundry Project
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: '${baseName}-project'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Gilead Sentinel RAI Project'
    description: 'Enterprise Project with strict RAI guardrails and evaluated agents'
    hubResourceId: aiHub.id
  }
}

// Built-in Role: Cognitive Services OpenAI User
var openAiUserRoleId = '5e63751c-e6ae-434e-a543-347b3045bb37'

resource rbacOpenAiUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  scope: aiServices
  name: guid(aiServices.id, principalId, openAiUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', openAiUserRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output aiServicesId string = aiServices.id
output aiServicesName string = aiServices.name
output aiServicesEndpoint string = aiServices.properties.endpoint
output hubId string = aiHub.id
output projectId string = aiProject.id
output projectName string = aiProject.name
output projectDiscoveryUrl string = aiProject.properties.discoveryUrl
