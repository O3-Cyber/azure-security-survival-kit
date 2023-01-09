targetScope = 'managementGroup'

@description('Sets the time now to concatenate the string in the deployment name with a unqiue value.')
param dateTime string = utcNow()

@description('Name of the region where the resources are deployed. (e.g.: westeurope)')
param location string

@description('Name of Resource Group that will be created. Defaults to a predefined value')
param resourceGroupName string

@description('Id of the Subscription the Resources will be provisioned within (e.g.: 41a43949-ccc4-4d0d-b2f6-a073dcfb61da)')
param subscriptionId string

@description('Id of the Management Group that will have diagnostics enabled, e.g.: 88655b27-db23-48d0-ab94-f9ab9e473eef')
param targetManagementGroup string

@description('Email where you want to receive alert notification (e.g.: example@example.com)')
param notificationEmail string

@description('Name of the Log Analytics Workspace. Defaults to a predefined value')
param logAnalyticsName string

@description('Name of the Log Diagnostics Setting for Management Group. Defaults to a predefined value.')
param logDiagnosticsMGName string

@description('Name of the Log Diagnostics Setting for Azure Active Directory. Defaults to a predefined value.')
param logDiagnosticsAADName string

@description('Name of the Log Diagnostics Setting for the Azure Subscription. Defaults to a predefined value.')
param logDiagnosticsSubscriptionName string

// alerts
@description('Name of the existing alert rules. Defaults to a predefined value. If adding more rules, the parameters must be added here.')
param alertRuleName1 string
param alertRuleName2 string
param alertRuleName3 string
param alertRuleName4 string
param alertRuleName5 string
param alertRuleName6 string


module alerts './detections/alerts.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'alertSetup-${dateTime}'
  params: {
    notificationEmail: notificationEmail
    alertRuleName1: alertRuleName1
    alertRuleName2: alertRuleName2
    alertRuleName3: alertRuleName3
    alertRuleName4: alertRuleName4
    alertRuleName5: alertRuleName5
    alertRuleName6: alertRuleName6
    location: location
    LogAnalyticsName: logAnalyticsName
    resourceGroupName: resourceGroupName
  }
  dependsOn: [
    logAnalytics
  ]
}

module resourceGrp './modules/resourcegrp.bicep' = {
  name: 'resourceGroupDeployment-${dateTime}'
  scope: subscription(subscriptionId) 
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}


module logAnalytics './modules/loganalyticsworkspace.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'logAnalyticsDeployment-${dateTime}'
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
  }
  dependsOn: [
    resourceGrp
  ]
}

module logDiagnosticsAADandSub './modules/logdiagnostics.bicep' = {
  scope: subscription(subscriptionId)
  name: 'logDiagnostics-${dateTime}'
  params: {
    logDiagnosticsSubscriptionName: logDiagnosticsSubscriptionName
    logDiagnosticsAADName: logDiagnosticsAADName
    logAnalyticsName: logAnalyticsName
    resourceGroupName: resourceGroupName
  }
  dependsOn: [
    resourceGrp
    logAnalytics
  ]
}

module logDiagnosticsMG './modules/logdiagnosticsmg.bicep' = {
  scope: managementGroup()
  name: 'logDiagnostics-${dateTime}'
  params: {
    logDiagnosticsMGName: logDiagnosticsMGName
    logAnalyticsName: logAnalyticsName
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
  }
  dependsOn: [
    resourceGrp
    logAnalytics
  ]
}


param logAnalyticsPolicyName string = 'azssk-loganalytics-policy'
param assignmentName string = 'azzsk-policy-assignment'

module logAnalyticsPolicy './modules/loganalyticspolicy.bicep' = {
  name: 'logAnalyticsPolicy-${dateTime}'
  params: {
    logAnalyticsPolicyName: logAnalyticsPolicyName
    LogAnalyticsName: logAnalyticsName
    assignmentName: assignmentName
    targetManagementGroup: targetManagementGroup 
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    location: location
  }
  dependsOn: [
    logAnalytics
  ]
}


