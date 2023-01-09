param logAnalyticsName string
param resourceGroupName string
param subscriptionId string
param logDiagnosticsMGName string

targetScope = 'managementGroup'

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
  scope: resourceGroup(subscriptionId, resourceGroupName)
}


resource ManagementGroupActivityLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: logDiagnosticsMGName
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      { 
        category: 'Policy'
        enabled: true
      }
    ]
  }
}
