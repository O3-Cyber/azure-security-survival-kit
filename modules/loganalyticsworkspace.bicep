param location string
param logAnalyticsName string


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    retentionInDays: 180
  }
}

output logAnalyticsWorkspace object = logAnalyticsWorkspace.properties
