### Script to disable cosmos DB key access:
Connect-AzAccount
Set-AzContext "<subscription_name>"  ###Provide subscription name
$parameters = @{
    ResourceGroupName = "<Resourcegroup_name>"  ###Provide ResourceGroupName
    ResourceName = "<CosmosDB_name>"  ###Provide CosmosDB name
    ResourceType = "Microsoft.DocumentDB/databaseAccounts"
}
$resource = Get-AzResource @parameters

$resource.Properties.DisableLocalAuth = $true

$resource | Set-AzResource -Force



#### Validation if disabled or not (If true disabled, if false enabled)

Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -ResourceType "Microsoft.DocumentDB/databaseAccounts" | Select-Object -ExpandProperty Properties | Select-Object disableLocalAuth



####### Get the built in roles assigne dfor cosmos BD's

Connect-AzAccount
Set-AzContext "<subscription_name>"
Get-AzCosmosDBSqlRoleDefinition `
 -AccountName <CosmosDB_name> `
 -ResourceGroupName <Resourcegroup_name>