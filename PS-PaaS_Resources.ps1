
$resourceTypeMapping = @{
    # Databases
    "Microsoft.Sql/servers/databases"                 = "SQL Databases"
    "Microsoft.DocumentDB/databaseAccounts"           = "Cosmos DB"
    "Microsoft.DBforMySQL/servers"                    = "Azure Database for MySQL"
    "Microsoft.DBforPostgreSQL/servers"               = "Azure Database for PostgreSQL"
    "Microsoft.DBforMariaDB/servers"                  = "Azure Database for MariaDB"

    # Storage
    "Microsoft.Storage/storageAccounts"               = "Storage Accounts"
    "Microsoft.Cache/Redis"                           = "Azure Redis Cache"

    # Analytics & Big Data
    "Microsoft.Kusto/Clusters"                        = "Azure Data Explorer"
    "Microsoft.Synapse/workspaces"                    = "Synapse Analytics"
    "Microsoft.DataFactory/factories"                 = "Data Factories"

    # AI & Machine Learning
    "Microsoft.MachineLearning/workspaces"            = "ML Workspaces"
    "Microsoft.CognitiveServices/accounts"            = "AI Services"

    # Integration
    "Microsoft.Logic/workflows"                       = "Logic Apps"
    "Microsoft.ServiceBus/namespaces"                 = "Service Bus"
    "Microsoft.EventHub/namespaces"                   = "Event Hubs"
    "Microsoft.PowerPlatform/accounts"                = "Power Platform Environments"

    # Monitoring & Management
    "Microsoft.Insights/components"                   = "Application Insights"
    "Microsoft.OperationalInsights/workspaces"        = "Log Analytics Workspaces"
    "Microsoft.RecoveryServices/vaults"               = "Recovery Services Vaults"
    "Microsoft.Automation/automationAccounts"         = "Automation Accounts"
    "Microsoft.KeyVault/vaults"                       = "Key Vaults"

    # Containers & Compute
    "Microsoft.ContainerService/managedClusters"      = "AKS Clusters"
    "Microsoft.ContainerRegistry/registries"          = "Container Registries"
    "Microsoft.Compute/availabilitySets"              = "Availability Sets"

    # API Management
    "Microsoft.ApiManagement/service"                 = "API Management"

    
    "Microsoft.Sql/servers"                           = "SQL Servers (For Dedicated SQL Pools)"
}


$validSubscriptions = @(
    "<subscriptionname-1>", "<subscriptionname-2>", "<subscriptionname-3>"
)


$outputPath = "C:\Temp\Combined_PaaS_Resource_Report.csv"


$allResources = @()

$subscriptions = Get-AzSubscription | Where-Object { $_.Name -in $validSubscriptions }

foreach ($sub in $subscriptions) {
    Write-Host "`nSwitching to subscription: $($sub.Name)" -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id

    
    $resources = Get-AzResource

    foreach ($resource in $resources) {

        
        if ($resourceTypeMapping.ContainsKey($resource.ResourceType) -and $resource.ResourceType -ne "Microsoft.Sql/servers") {
            $allResources += [PSCustomObject]@{
                SubscriptionName = $sub.Name
                ResourceGroup    = $resource.ResourceGroupName
                ResourceName     = $resource.Name
                ResourceType     = $resource.ResourceType
                ServiceName      = $resourceTypeMapping[$resource.ResourceType]
                Location         = $resource.Location
            }
        }

        
        elseif ($resource.ResourceType -eq "Microsoft.Sql/servers") {
            try {
                $sqlDbs = Get-AzSqlDatabase -ResourceGroupName $resource.ResourceGroupName -ServerName $resource.Name -ErrorAction Stop
                foreach ($sqlDb in $sqlDbs) {
                    if ($sqlDb.Edition -eq "DataWarehouse") {
                        $allResources += [PSCustomObject]@{
                            SubscriptionName = $sub.Name
                            ResourceGroup    = $sqlDb.ResourceGroupName
                            ResourceName     = $sqlDb.DatabaseName
                            ResourceType     = "Microsoft.Sql/servers/databases"
                            ServiceName      = "Dedicated SQL Pools"
                            Location         = $sqlDb.Location
                        }
                    }
                }
            }
            catch {
                Write-Warning "Failed to query databases for server $($resource.Name): $($_.Exception.Message)"
            }
        }
    }
}


$allResources | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "`nCombined PaaS resource inventory saved to $outputPath" -ForegroundColor Green
