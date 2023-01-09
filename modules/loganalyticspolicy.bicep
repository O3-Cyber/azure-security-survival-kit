param logAnalyticsPolicyName string
param LogAnalyticsName string
param resourceGroupName string
param subscriptionId string
param location string

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: LogAnalyticsName
  scope: resourceGroup(subscriptionId, resourceGroupName)
}


targetScope = 'managementGroup'
param targetManagementGroup string

var mgScope = tenantResourceId('Microsoft.Management/managementGroups', targetManagementGroup)



resource LAPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: logAnalyticsPolicyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Resources/subscriptions'
      }
      then: {
        effect: 'DeployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          deploymentScope: 'Subscription'
          existenceScope: 'Subscription'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs.enabled'
                equals: 'true'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: loganalyticsWorkspace.id
              }
            ]
        }
        deployment: {
          location: location
          properties: {
            mode: 'incremental'
            template: {
              schema: 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#'
              contentVersion: '1.0.0.0'
              parameters: {
                logAnalytics: {
                  type: 'string'
                }
                logsEnabled: {
                  type: 'string'
                }
              }
            }
          }
        }
        roleDefinitionIds: [
          '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
         ]    
      }
    }
    }
  }
}


param assignmentName string

resource AzureLAPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    scope: mgScope
    policyDefinitionId: extensionResourceId(mgScope, 'Microsoft.Authorization/policyDefinitions', LAPolicyDefinition.name)
  }
}

