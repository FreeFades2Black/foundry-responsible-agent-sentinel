@description('Azure region for AI Search service')
param location string

@description('Name of the Azure AI Search service')
param searchServiceName string

@description('SKU for Azure AI Search (standard is required for semantic ranker)')
@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param sku string = 'standard'

@description('Enable semantic search ranker')
param semanticSearch string = 'standard'

@description('Principal ID of the Managed Identity for RBAC assignment')
param principalId string = ''

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: searchServiceName
  location: location
  sku: {
    name: sku
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    semanticSearch: semanticSearch
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

// Built-in Role: Search Index Data Contributor
var searchIndexDataContributorRoleId = '8ebe5a00-a779-49be-a319-d0ba9f59604a'
// Built-in Role: Search Service Contributor
var searchServiceContributorRoleId = '7ca78c08-252a-457e-8644-23d403142140'

resource rbacDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  scope: searchService
  name: guid(searchService.id, principalId, searchIndexDataContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource rbacServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  scope: searchService
  name: guid(searchService.id, principalId, searchServiceContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output searchServiceId string = searchService.id
output searchServiceName string = searchService.name
output searchEndpoint string = 'https://${searchService.name}.search.windows.net'
