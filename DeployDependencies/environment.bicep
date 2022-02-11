param environmentName string
param location string
param logAnalyticsClientId string
param logAnalyticsSecretKey string
param aiInstrumentationKey string

resource environment 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: environmentName
  location: location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsClientId
        sharedKey: logAnalyticsSecretKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: aiInstrumentationKey
    }
  }
}