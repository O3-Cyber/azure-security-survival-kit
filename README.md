# Azure Security Survival Kit

# Background

Inspired by the work done by [Victor Grenu](https://zoph.io/) on the project [AWS Security Survival Kit](https://github.com/zoph-io/aws-security-survival-kit) we decided to create a similar project for Microsoft Azure.

The project is built using Azure Bicep with modules. The author had little to no previous experience with Azure Bicep prior to this project.

## Purpose
We want to give anyone with an Azure subscription the ability to centralize logs and to detect a bare minimum of potential threats in Microsoft Azure and to provide the community with a simple framework that allows to further expand detections without investing a lot of time.

If you are looking into performing comprehensive threat detection you should consider a Sentinel deployment paired with a more rigid process.

## Log sources
The log sources are from Management Group Activity, Azure Activity and Azure Active Directory Sign-in and Audit logs. Note: Using this project you are able to export logs that requires a license and cannot be enabled through the portal unless you have the license. The intention of this project is not to circumvent licensing. To be compliant with the license, you will need Azure AD P1 or P2 license.

## Alerts

The alerts are deployed on Azure Monitor with Scheduled Query Rules. Each detection has its own rule.

The following detections are part of the template:

1. ConditionalAccessModified - Detects any changes to Conditional Access for the tenant

2. RunCommandInvoked - Detects any invocation of Run command

3. VMDiskSnapshotGenerated - Detects any generation of shareable snapshots links

4. VMPasswordResetInvoked - Detects password reset extension being used on VMs

5. BastionShareableLinkCreated - Detects creation of Bastion Shareable links for persistence

6. ElevatedAccessToggleInvoked - Detects the invocation of Elevated Access Toggle

For adding more alerts, see [Extending Alerts](https://github.com/03-Cyber/Azure-Security-Survival-Kit-Prerelease/blob/main/README.md#extending-alerts).

## Deployment

To get started with deployment, update the main.parameters.json file with the relevant parameters. The deployment is scoped to Management Group level with each module having a different target scope. The reason behind the Management Group scope is so log diagnostics can also be enabled for any operations on the management group, allowing to detect actions such as usage of [Elevated Access Toggle in Azure](https://www.o3c.no/knowledge/detecting-usage-of-elevated-access-toggle-in-azure-environments).

Before you can deploy the project, you need to modify the parameters in the main.parameters.json. The parameters below has to be edited for it to succesfully deploy: 

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "location": {
        "value": "westeurope"
      },
      "resourceGroupName": {
        "value": "azssk-monitoring-rg"
      },
      "subscriptionId":{
        "value": "SUBSCRIPTIONID"
      },
      "targetManagementGroup":{
        "value": "MANAGEMENTGROUPID"
      },
      "notificationEmail": {
        "value": "notification@example.com"
      }
    }
  }
```

Once the parameters are updated, you can deploy using Azure CLI with the command below

```bash
az deployment mg create --location <location> --template-file ./main.bicep --parameters "@./parameters/main.parameters.json" --management-group-id <management-group-id>
```

## Monitoring

The alerts that have triggered can also be monitored through Azure Monitor > Alerts:

![image](https://user-images.githubusercontent.com/26272119/211192792-5f8b4fab-2766-495a-9cd5-38f71428e79b.png)

## Extending Alerts

If you want to further extened the alerts, you can do so by following the steps below:

1.  Add a parameter with the name of the detection rule in main.parameters.json file.

```powershell
"alertRuleNameX": {
        "value": "NameOfAlert"
      }
```

2. Declare the parameter in the main.bicep file.

```powershell
param alertRuleName5 string
param alertRuleName6 string
param alertRuleNameX string
```

3. Add the parameter to the alerts module in the main.bicep file

```json
params: {
    alertRuleNameX: alertRuleNameX
}
```

4. Add a azskDetectionRule resource in the alerts.bicep file, reference the detectionRuleName and provide a query that triggers the alert.

```
resource azskDetectionRuleX 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  location: location
  kind:'LogAlert'
  name: alertRuleNameX
  properties: {
    displayName: alertRuleNameX
    actions: {
      actionGroups: [ 
        azsskactionGroup.id
      ]
    }
    autoMitigate: false
    description: 'Description of the alert'
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
          query: 'KQL QUERY'
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
```

## Costs

The costs of the project depends on each environment, in a small environment which the project is intended for, the cost is likely to be less than $20 a month. However, it will depend on:

1. The volume of log data

2. The amount of alerts you have. Each alert with an evaluation of PT15 costs $0.50 per month.

For more information on Pricing:  [https://azure.microsoft.com/en-us/pricing/details/monitor/](https://azure.microsoft.com/en-us/pricing/details/monitor/)

## Contributions
Contributions that seek to improve the project or further extend it are welcome. If you want to build company-specific use cases, we suggest creating a fork.