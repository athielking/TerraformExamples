targetScope = 'subscription'

param location string = 'eastus'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'RPM-LunchAndLearn-Bicep2'
  location: location
}

module storageModule './web-app.bicep' = {
  name: 'storageDeploy'
  scope: rg
  params: {
    location: location
  }
}
