$RESOURCE_GROUP_NAME = Read-Host -Prompt "Enter your Resource Group Name"
$RESOURCE_PREFIX = Read-Host -Prompt "Enter a resource prefix"
$LOCATION = Read-Host -Prompt "Enter Location"
$SB_CONN_STRING = Read-Host -Prompt "Enter Azure Service Bus Connection String"
$LOG_ANALYTICS_NAME = "${RESOURCE_PREFIX}-analytics"
$APP_INSIGHTS_NAME = "${RESOURCE_PREFIX}-app-insights"
$APP_ENV_NAME = "${RESOURCE_PREFIX}-appenv"

Write-Host "Enabling Preview Features"
az extension add --source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.0-py2.py3-none-any.whl --yes
az extension add -n application-insights --yes
az provider register --namespace Microsoft.Web

Write-Host "Creating Resource Group: $RESOURCE_GROUP_NAME"
az group create -n $RESOURCE_GROUP_NAME -l $LOCATION

Write-Host "Creating Log Analytics Workspace: $LOG_ANALYTICS_NAME"
az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP_NAME --workspace-name $LOG_ANALYTICS_NAME

$LOG_ANALYTICS_WORKSPACE_ID=(az monitor log-analytics workspace show --query id -g $RESOURCE_GROUP_NAME -n $LOG_ANALYTICS_NAME --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP_NAME -n $LOG_ANALYTICS_NAME --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP_NAME -n $LOG_ANALYTICS_NAME --out tsv)

Write-Host "Creating App Insights"
az monitor app-insights component create --app $APP_INSIGHTS_NAME --location $LOCATION --kind web -g $RESOURCE_GROUP_NAME --workspace "$LOG_ANALYTICS_WORKSPACE_ID"

$AI_INSTRUMENTATION_KEY=(az monitor app-insights component show -g $RESOURCE_GROUP_NAME --app $APP_INSIGHTS_NAME --query instrumentationKey --out tsv)
            
Write-Host "Creating Container App Environment: $APP_ENV_NAME"
az deployment group create `
--template-file full_deploy.bicep `
--resource-group $RESOURCE_GROUP_NAME `
--parameters location=$LOCATION `
--parameters environmentName=$APP_ENV_NAME `
--parameters logAnalyticsClientId=$LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
--parameters logAnalyticsSecretKey=$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
--parameters aiInstrumentationKey=$AI_INSTRUMENTATION_KEY `
--parameters serviceBusConnectionString=$SB_CONN_STRING

$KUBE_ENVIRONMENT_ID = az containerapp env show -g $RESOURCE_GROUP_NAME -n $APP_ENV_NAME --query id

Write-Host "------------------------------------------"
Write-Host "YOUR APP INSIGHTS KEY IS: " $AI_INSTRUMENTATION_KEY
Write-Host "YOUR ENVIRONMENT ID: " $KUBE_ENVIRONMENT_ID
