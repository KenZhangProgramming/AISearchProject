using './main.bicep'

// Location settings
param location = 'canadacentral'
param locationAi = 'canadaeast'

// Naming
param rootName = 'soft-eng-gen-ai-prod'
param rootNameContainerApps = 'segenaiprd'
param rootNameStorageAccounts = 'segenaiprod'

// Common resource references
param dnsZoneName = 'avanadeai.com'

// Container Apps custom domains + managed certificates
param enableCustomDomains = true

// Bind these hostnames to existing managed certificates in the environment
param customDomainCertificateIds = {
	copilot: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/api-copilot.avanadeai.com-cae-soft-260224143924'
	apiUi: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/mc-api-ui-segenaiprd'
	tourGuide: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/mc-api-tour-guide-segenaiprd'
	web: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/www.avanadeai.com-cae-soft-260224144725'
	mcpTourGuide: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/mcp-tour-guide.avanadeai.com-cae-soft-260224150028'
	outdoorActivity: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/api-outdoor-activity.avanade-cae-soft-260224150133'
	persona: '/subscriptions/fec51923-ff31-40de-afda-56f816f0c297/resourceGroups/rg-soft-eng-gen-ai-prod/providers/Microsoft.App/managedEnvironments/cae-soft-eng-gen-ai-prod/managedCertificates/api-persona-chat.avanadeai.c-cae-soft-260224153640'
}

// Create managed certificates for hostnames that don't have one yet.
// After these succeed, add their resource IDs to customDomainCertificateIds and rerun to bind TLS.
param createManagedCertificatesKeys = []
param commonResourceGroupName = 'rg-soft-eng-gen-ai-common'
param containerRegistryName = 'crsoftenggenaicommon'

// Authentication
param authTenantId = 'cb3e9707-d04b-4352-82fb-5e6ab3fab215'
param azureAdDomain = 'avanadeai.com'

// Frontend
param frontendOrigin = 'https://www.avanadeai.com'

// External APIs
param toDoCanadaUrl = 'https://webcache.googleusercontent.com/search?q=cache:https://www.todocanada.ca/things-to-do-in-toronto-this-weekend/'

// Secure parameters - Replace with actual values or use Key Vault references
param openWeatherApiKey = getSecret('fec51923-ff31-40de-afda-56f816f0c297', 'rg-soft-eng-gen-ai-common', 'kv-soft-eng-gen-ai-cmmn', 'openweather-api-key')
param googleSearchApiKey = 'YOUR-API-KEY-HERE'
param googleSearchEngineId = 'YOUR-SEARCH-ENGINE-ID-HERE'
param apiCopilotClientSecret = getSecret('fec51923-ff31-40de-afda-56f816f0c297', 'rg-soft-eng-gen-ai-common', 'kv-soft-eng-gen-ai-cmmn', 'api-copilot-client-secret')
param stravaClientId = getSecret('fec51923-ff31-40de-afda-56f816f0c297', 'rg-soft-eng-gen-ai-common', 'kv-soft-eng-gen-ai-cmmn', 'strava-client-id')
param stravaClientSecret = getSecret('fec51923-ff31-40de-afda-56f816f0c297', 'rg-soft-eng-gen-ai-common', 'kv-soft-eng-gen-ai-cmmn', 'strava-client-secret')
