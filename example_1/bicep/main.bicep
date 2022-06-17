targetScope = 'subscription'

param location string = 'eastus'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'KMX-DevOpsDays-Bicep1'
  location: location
}

module storageModule './storage-account.bicep' = {
  name: 'storageDeploy'
  scope: rg
  params: {
    location: location
  }
}

