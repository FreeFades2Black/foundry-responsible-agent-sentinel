targetScope = 'resourceGroup'

@minLength(3)
@maxLength(24)
@description('Prefix used for naming all provisioned Azure resources')
param environmentName string = 'sentinel'

@description('Primary Azure region for all services')
param location string = resourceGroup().location

@description('Severity threshold for custom RAI content filters')
param raiSeverityThreshold string = 'Medium'

var cleanEnv = toLower(replace(replace(environmentName, '-', ''), '_', ''))
var uniqueSuffix = uniqueString(resourceGroup().id)
var baseResourceName = '${cleanEnv}${uniqueSuffix}'

// 1. User-Assigned Managed Identity for Passwordless Zero-Trust Access
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${baseResourceName}-id'
  location: location
}

// 2. Storage Account for AI Foundry Artifacts and Index Data
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take('${cleanEnv}st${uniqueSuffix}', 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: { enabled: true }
        file: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// 3. Azure Key Vault for Secure Key and Secret Management
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take('${cleanEnv}kv${uniqueSuffix}', 24)
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

// 4. Azure AI Foundry Hub, Projects & OpenAI Model Deployments
module aiFoundry 'modules/ai-foundry.bicep' = {
  name: 'ai-foundry-deployment'
  params: {
    location: location
    baseName: baseResourceName
    principalId: managedIdentity.properties.principalId
    storageAccountId: storageAccount.id
    keyVaultId: keyVault.id
  }
}

// 5. Azure AI Search Service with Semantic Ranker & Vector Store
module aiSearch 'modules/ai-search.bicep' = {
  name: 'ai-search-deployment'
  params: {
    location: location
    searchServiceName: '${baseResourceName}-search'
    sku: 'standard'
    semanticSearch: 'standard'
    principalId: managedIdentity.properties.principalId
  }
}

// 6. Custom RAI Policy (Content Safety, Prompt Shield, Indirect Attack Filters)
module raiPolicy 'modules/rai-policy.bicep' = {
  name: 'rai-policy-deployment'
  params: {
    accountName: aiFoundry.outputs.aiServicesName
    policyName: 'eld-custom-guardrail'
    severityThreshold: raiSeverityThreshold
  }
}

// Outputs exported for Application Configuration & azd runtime
output AZURE_RESOURCE_GROUP string = resourceGroup().name
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_MANAGED_IDENTITY_CLIENT_ID string = managedIdentity.properties.clientId
output AZURE_AI_SERVICES_ENDPOINT string = aiFoundry.outputs.aiServicesEndpoint
output AZURE_AI_PROJECT_ID string = aiFoundry.outputs.projectId
output AZURE_AI_PROJECT_NAME string = aiFoundry.outputs.projectName
output AZURE_SEARCH_ENDPOINT string = aiSearch.outputs.searchEndpoint
output AZURE_SEARCH_SERVICE_NAME string = aiSearch.outputs.searchServiceName
output RAI_POLICY_RESOURCE_ID string = raiPolicy.outputs.raiPolicyId
output RAI_POLICY_NAME string = raiPolicy.outputs.raiPolicyName
output AZURE_AI_FOUNDRY_CONNECTION_STRING string = '${location}.api.azureml.ms;${subscription().subscriptionId};${resourceGroup().name};${aiFoundry.outputs.projectName}'
