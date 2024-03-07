@description('La région du déploiement')
@allowed([
  'canadacentral'
  'canadaeast'
])
param location string
@description('Le nom su serveur SQL')
param serverName string
@description('La liste des objets (propriétés : name et sku) pour les bases de données')
param databases array
@description('Le nom de l\'utilisateur pour accéder aux données')
param dbUser string

@description('Le mot de passe de l\'utilisateur')
@minLength(10)
@maxLength(20)
@secure()
param dbPassword string

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'srv-${serverName}'
  location: location
  properties: {
    administratorLogin: dbUser
    administratorLoginPassword: dbPassword
    version: '12.0'
  }
}

// SQL Databases
resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = [for db in databases: {
  name: 'db-${db.name}'
  location: location
  parent: sqlServer
  sku: {
    name: db.storageSku
    tier: db.storageSku
  }
}]

// Règle de pare-feu qui inclut tous les clients (adresses)
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  name: 'All'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255' 
  }
}
