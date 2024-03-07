@description('La région du déploiement')
@allowed([
  'canadacentral'
  'canadaeast'
])
param location string = 'canadacentral'
@description('Le nom de l\'application web à déployer')
param webAppName string
@description('Spécifier l\'environment de l\'application (ASPNETCORE_ENVIRONMENT)')
param isProduction bool

@description('Le niveau tarifaire')
@allowed([
  'F1'
  'B1'
  'S1'
])
param sku string = 'F1'

// Plan de service
resource servicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'sp-${webAppName}'
  location: location
  tags: {
    Application: webAppName
  }
  sku: {
    name: sku
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'webapp-${webAppName}-${uniqueString(resourceGroup().id)}'
  location: location
  tags: {
    Application: webAppName
  }
  properties: {
    serverFarmId: servicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: isProduction ? 'Production' : 'Development'
        }
      ]
    }
  }
}

// Staging Slot
resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = if(sku == 'S1') {
  name: 'staging'
  location: location
  parent: webApp
  tags: {
    Application: webAppName
  }
  properties: {
    serverFarmId: servicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Staging'
        }
      ]
    }
  }
}

// Règle de mise à l'échelle
resource scaleOutRule 'Microsoft.Insights/autoscalesettings@2022-10-01' = if(sku == 'S1') {
  name: '${servicePlan.name}-auto-scale'
  location: location
  tags: {
    Application: webAppName
  }
  properties: {
    enabled: true
    profiles: [
      {
        name: 'Condition de mise à l\'échelle'
        capacity: {
          maximum: '10' // default : 3
          default: '1'
          minimum: '1'
        }
          
        // Règle 1
        rules: [
          {
            scaleAction: {
              type: 'ChangeCount'
              direction: 'Increase'
              cooldown: 'PT5M'
              value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              operator: 'GreaterThan'
              timeAggregation: 'Average'
              threshold: 80
              metricResourceUri: servicePlan.id
              timeWindow: 'PT10M'
              timeGrain: 'PT1M'
              statistic: 'Average'
            }
          }

          // Règle 2
          {
            scaleAction: {
            type: 'ChangeCount'
            direction: 'Decrease'
            cooldown: 'PT5M'
            value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              operator: 'LessThan'
              timeAggregation: 'Average'
              threshold: 45
              metricResourceUri: servicePlan.id
              timeWindow: 'PT10M'
              timeGrain: 'PT1M'
              statistic: 'Average'
            }
          } 
        ]
      }
    ]
    targetResourceUri: servicePlan.id
  }
}
