targetScope = 'subscription'

param location string = 'eastus'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'RPM-LunchAndLearn-Bicep1'
  location: location
}
