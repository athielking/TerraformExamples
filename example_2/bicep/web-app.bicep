param location string = resourceGroup().location


resource servicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name:'${resourceGroup().name}-bicep-sp'
  location: location
  properties: {
    reserved: false
  }
  sku: {
    name: 'F1'
  }

  kind: 'windows'
}

resource appSvc 'Microsoft.Web/sites@2021-03-01' = {
  name: '${resourceGroup().name}-bicep-api'
  location: location

  properties :{    
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ]
      netFrameworkVersion: 'v6.0'      
    }
  }
}
