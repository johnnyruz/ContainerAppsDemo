param environmentName string
param location string
param logAnalyticsClientId string
param logAnalyticsSecretKey string
param aiInstrumentationKey string

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsClientId
        sharedKey: logAnalyticsSecretKey
      }
    }
    daprAIInstrumentationKey: aiInstrumentationKey
    daprAIConnectionString: 'string'
//    vnetConfiguration: {
//      dockerBridgeCidr: 'string'
//      infrastructureSubnetId: 'string'
//      internal: bool
//      platformReservedCidr: 'string'
//      platformReservedDnsIP: 'string'
//      runtimeSubnetId: 'string'
//    }
    zoneRedundant: false
  }
}

resource environmentDaprConfig 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: 'servicebus-pubsub'
  parent: environment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'servicebus-connection-string'
      }
      {
        name: 'maxDeliveryCount'
        value: '1'
      }
      {
        name: 'maxConcurrentHandlers'
        value: '1'
      }
      {
        name: 'prefetchCount'
        value: '1'
      }
    ]
    scopes: [
      'containerappdemo-frontend'
      'containerappdemo-backend'
    ]
    secrets: [
      {
        name: 'servicebus-connection-string'
        value: SERVICE_BUS_CONNECTION_STRING
      }
    ]
    version: 'v1'
  }
}
