@description('La région du déploiement')
@allowed([
  'canadacentral'
  'canadaeast'
])
param location string = 'canadacentral' 
@description('Le nom du compte de stockage')
param stgAcctName string
@description('Le nom de conteneur blob')
param blobContName string

// Compte de stockage
resource stgAcct 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: stgAcctName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_ZRS' // Stockage redondant interzone : disponibilité au niveau des centres de données
  }
}

// Services blob pour la création du conteneur
resource blobservices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: stgAcct
}

// Conteneur blob
resource blobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: toLower('${blobContName}space')
  parent: blobservices
  properties: {
    publicAccess: 'None' // Privé (aucun accès anonyme)
    metadata: {}
  }
}
