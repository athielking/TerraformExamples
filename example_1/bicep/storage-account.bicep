param location string = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'kmxbicepstorage1'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
