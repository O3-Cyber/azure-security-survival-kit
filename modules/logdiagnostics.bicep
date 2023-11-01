targetScope = 'subscription'

param logAnalyticsName string
param logDiagnosticsAADName string
param logDiagnosticsSubscriptionName string
param resourceGroupName string

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
  scope: resourceGroup(resourceGroupName)
}


resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: logDiagnosticsSubscriptionName
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      { 
        category: 'Security'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
      {
        category: 'ServiceHealth'
        enabled: true
      }
      {
        category: 'Recommendation'
        enabled: true
      }
      {
        category: 'Autoscale'
        enabled: true
      }
      {
        category: 'ResourceHealth'
        enabled: true
      }
    ]
  }
}


resource aadLogs 'microsoft.aadiam/diagnosticSettings@2017-04-01' = {
  name: logDiagnosticsAADName
  scope: tenant()
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [ 
      {
      category: 'AuditLogs'
      enabled: true
    }
    {
      category: 'SignInLogs'
      enabled: true
    }
    {
      category: 'NonInteractiveUserSignInLogs'
      enabled: true
    }
    {
      category: 'ServicePrincipalSignInLogs'
      enabled: true
    }
    {
      category: 'ManagedIdentitySignInLogs'
      enabled: true
    }
    {
      category: 'ProvisioningLogs'
      enabled: true
    }
    {
      category: 'ADFSSignInLogs'
      enabled: true
    }
    {
      category: 'RiskyUsers'
      enabled: true
    }
    {
      category: 'UserRiskEvents'
      enabled: true
    }
    {
      category: 'NetworkAccessTrafficLogs'
      enabled: true
  
    }
    {
      category: 'RiskyServicePrincipals'
      enabled: true
    }
    {
      category: 'ServicePrincipalRiskEvents'
      enabled: true
    }
    {
      category: 'MicrosoftGraphActivityLogs'
      enabled: true
    }
    ]
  }
}
