param notificationEmail string
param location string
param LogAnalyticsName string
param resourceGroupName string
param alertRuleName1 string
param alertRuleName2 string
param alertRuleName3 string
param alertRuleName4 string
param alertRuleName5 string
param alertRuleName6 string

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: LogAnalyticsName
  scope: resourceGroup(resourceGroupName)
}

resource azsskactionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  location: 'global'
  name: 'azssk-ActionGroup'
  properties: {
    enabled: true
    groupShortName: 'azssk'
    emailReceivers: [
      {
        name: 'azssk-email'
        emailAddress: notificationEmail
        useCommonAlertSchema: true
      }
    ]
  }

}

resource azskDetectionRule1 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: 'azskDetectionConditionalAccessUpdated'
  properties: {
    displayName: alertRuleName1
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects any changes to Conditional Access for the tenant'
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: 'AuditLogs\n| where LoggedByService == "Conditional Access"\n| project\n    ActivityDateTime,\n    InitiatedBy.user.userPrincipalName,\n    TargetResources[0].displayName,\n    ActivityDisplayName\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}

resource azskDetectionRule2 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: 'azskDetectionRunCommandUsed'
  properties: {
    displayName: alertRuleName2
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects any invocation of Run command'
    enabled: true
    evaluationFrequency: 'PT15M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'AzureActivity\n| where OperationNameValue contains "runCommand/action"\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}

resource azskDetectionRule3 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: alertRuleName3
  properties: {
    displayName: alertRuleName3
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects any generation of shareable snapshots links'
    enabled: true
    evaluationFrequency: 'PT15M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'AzureActivity\n| where OperationNameValue =~"Microsoft.Compute/disks/BeginGetAccess/action"\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}

resource azskDetectionRule4 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: alertRuleName4
  properties: {
    displayName: alertRuleName4
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects password reset extension being used on VMs'
    enabled: true
    evaluationFrequency: 'PT15M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'AzureActivity\n| where OperationNameValue=~"microsoft.compute/virtualMachines/extensions/write" or OperationNameValue=~"Microsoft.Resources/deployments/validate/action"\n| where parse_json(Authorization).scope contains "extensions/enablevmaccess" or parse_json(Authorization).scope contains "VMAccessWindowsPasswordReset"\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}

resource azskDetectionRule5 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: alertRuleName5
  properties: {
    displayName: alertRuleName5
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects creation of Bastion Shareable links for persistence'
    enabled: true
    evaluationFrequency: 'PT15M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'AzureActivity\n| where OperationNameValue=~"MICROSOFT.NETWORK/BASTIONHOSTS/GETSHAREABLELINKS/ACTION" or OperationNameValue=~"MICROSOFT.NETWORK/BASTIONHOSTS/CREATESHAREABLELINKS/ACTION"'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}

resource azskDetectionRule6 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: alertRuleName6
  properties: {
    displayName: alertRuleName6
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Detects the invocation of Elevated Access Toggle'
    enabled: true
    evaluationFrequency: 'PT15M'
    scopes: [
      loganalyticsWorkspace.id
    ]
    severity: 3
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'AzureActivity\n| where parse_json(tostring(parse_json(Authorization).evidence)).role=="User Access Administrator"\n| where OperationNameValue=~"MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS/WRITE"'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}
/*
resource azzskDetectionRule1 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  location: location
  name: 'azsskDetectionRule1'
  properties: {
    actions: [
      {
        actionType:'AddActionGroups'
        actionGroupIds: [ 
          azsskactionGroup.id 
        ]
      }
    ]
    conditions: [
      {    
*/
