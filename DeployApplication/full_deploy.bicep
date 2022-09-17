param environmentName string
param location string
param logAnalyticsClientId string
param logAnalyticsSecretKey string
param aiInstrumentationKey string
param serviceBusConnectionString string

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
//    daprAIConnectionString: 'string'
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
        value: serviceBusConnectionString
      }
    ]
    version: 'v1'
  }
}

resource backendapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'containerappdemo-backend'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Multiple'
      secrets: [
        {
          name: 'servicebus-connection-string'
          value: serviceBusConnectionString
        }
        {
          name: 'appinsightsinstrumentationkey'
          value: aiInstrumentationKey
        }
      ]
      dapr: {
        enabled: true
        appProtocol: 'http'
        appPort: 80
        appId: 'containerappdemo-backend'
      }
    }
    managedEnvironmentId: environment.id
    template: {
      containers: [
        {
          env: [
            {
              name: 'AppInsightsInstrumentationKey'
              secretRef: 'appinsightsinstrumentationkey'
            }
          ]
          image: 'jruzia/containerappdemo-backend:latest'
          name: 'containerappdemo-backend'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 10
        minReplicas: 0
        rules: [
          {
            custom: {
              auth: [
                {
                  secretRef: 'servicebus-connection-string'
                  triggerParameter: 'connection'
                }
              ]
              metadata: {
                queueLength: '5'
                topicName: 'messagepublishtopic'
                subscriptionName: 'containerappdemo-backend'
              }
              type: 'azure-servicebus'
            }
            name: 'service-bus-scaling-rule'
          }
        ]
      }
    }
  }
}

resource frontendapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'containerappdemo-frontend'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Multiple'
      secrets: [
        {
          name: 'appinsightsinstrumentationkey'
          value: aiInstrumentationKey
        }
      ]
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 80
      }
      dapr: {
        enabled: true
        appProtocol: 'http'
        appPort: 80
        appId: 'containerappdemo-frontend'
      }
    }
    managedEnvironmentId: environment.id
    template: {
      containers: [
        {
          env: [
            {
              name: 'AppInsightsInstrumentationKey'
              secretRef: 'appinsightsinstrumentationkey'
            }
          ]
          image: 'jruzia/containerappdemo-frontend:latest'
          name: 'containerappdemo-frontend'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 1
        minReplicas: 0
      }
    }
  }
}
