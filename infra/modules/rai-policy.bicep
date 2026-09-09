@description('Name of the Cognitive Services / AI Services account')
param accountName string

@description('Name of the custom Responsible AI Content Safety policy')
param policyName string = 'eld-custom-guardrail'

@description('Severity threshold for standard content harm categories')
@allowed([
  'Low'
  'Medium'
  'High'
])
param severityThreshold string = 'Medium'

resource aiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: accountName
}

resource customRaiPolicy 'Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01' = {
  parent: aiAccount
  name: policyName
  properties: {
    basePolicyName: 'Microsoft.DefaultV2'
    mode: 'Blocking'
    contentFilters: [
      { name: 'Hate', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Prompt' }
      { name: 'Hate', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Completion' }
      { name: 'Sexual', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Prompt' }
      { name: 'Sexual', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Completion' }
      { name: 'Violence', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Prompt' }
      { name: 'Violence', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Completion' }
      { name: 'SelfHarm', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Prompt' }
      { name: 'SelfHarm', blocking: true, enabled: true, severityThreshold: severityThreshold, source: 'Completion' }
      { name: 'Jailbreak', blocking: true, enabled: true, source: 'Prompt' }
      { name: 'IndirectAttack', blocking: true, enabled: true, source: 'Prompt' }
    ]
  }
}

output raiPolicyId string = customRaiPolicy.id
output raiPolicyName string = customRaiPolicy.name
