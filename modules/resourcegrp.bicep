targetScope = 'subscription'

param resourceGroupName string
param location string

resource resourceGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

output resourceGrp object = resourceGrp.properties
