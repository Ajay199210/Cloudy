//------------//
// PARAMÈTRES //
//------------//

@description('La location (région) des ressources à déployer')
param location string = resourceGroup().location

// Paramètres du serveur SQL
@description('Le nom du serveur SQL hébérgant les deux bases de données')
param serverName string
@description('Le nom de l\'utilisateur accédant au serveur (BD) SQL')
param dbUser string
@minLength(10)
@maxLength(20)
@description('Le mot de passe de l\'utilisateur')
@secure()
param dbPassword string

// Paramètres du compte de stockage
@description('Le nom du compte de stockage')
param stgAcctName string
@description('Le nom de conteneur blob')
param blobContName string = 'documents'

//-----------//
// VARIABLES //
//-----------//

// Applications web
var webApps = [
  { name: 'mvc', sku: 'S1', isProduction: true }
  { name: 'postulations', sku: 'B1', isProduction: false }
  { name: 'emplois', sku: 'F1', isProduction: false }
  { name: 'favoris' , sku: 'F1', isProduction: false  }
  { name: 'documents', sku: 'F1', isProduction: false }
]

// Bases de données
var dbs = [
  { name: 'emplois', storageSku: 'Basic' }
  { name: 'postulations', storageSku: 'Standard' }
]

//--------------------------//
// CONSOMMATION DES MODULES //
//--------------------------//

// Module web apps
module webAppsModule 'modules/appService.bicep' = [for webApp in webApps: {
  name: 'webApp-${webApp.name}'
  params: {
    webAppName: webApp.name
    location: location
    sku: webApp.sku
    isProduction: webApp.isProduction
  }
}]

// Module base de donné
module db 'modules/sqlDb.bicep' = {
  name: 'databases'
  params: {
    serverName: serverName
    location: location
    databases: dbs // un serveur avec deux BD
    dbUser: dbUser
    dbPassword: dbPassword
  }
}

// Module compte de stockage
module stgAcct 'modules/stgAcct.bicep' = {
  name: 'storage-account'
  params: {
    location: location
    stgAcctName: stgAcctName
    blobContName: blobContName
  }
}
