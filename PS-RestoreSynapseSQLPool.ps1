###This script is to restore a synapse SQL pool between different Subscriptions.
### We will need to create a dedicated SQL pool in the destination resource group for this script to be implmented.
## We need to create a User defined restore point of the Synapse SQL pool which we are going to restore before we start the Process because we need to provide the Restore Point time (in UTC only)
## This script first restores a dedicated SQL pool from user defined restore point and then from dedicated SQL pool it restores synapse sql pool. (There should be no existing pool with the same name)
##Please change parameters accordingly, these are for example.
##Target server is SQL server created for respective environment, for now there are testsb01/02/03.Please update accordingly



$SourceSubscriptionName="<source_subscriptionname>"
$SourceResourceGroupName="<source_resourcegroupname>"
$SourceWorkspaceName="<source_workspacename>"  # Without sql.azuresynapse.net
$SourceSQLPoolName="<source_sqlname>"
$TargetSubscriptionName="<target_subscription>"
$TargetResourceGroupName="<target_resourcegroup>"
$TargetServerName="<target_servername>"  # Without sql.azuresynapse.net
$TargetDatabaseName="<target_databasename>"
$TargetWorkspaceName="<target_workspacename>" # uncomment if restore to an Azure Synapse workspace is required
 
# Update Az.Sql module to the latest version (3.8.0 or above)
# Update-Module -Name Az.Sql -RequiredVersion 3.8.0
 
Connect-AzAccount
Get-AzSubscription
Select-AzSubscription -SubscriptionName $SourceSubscriptionName
 
# list all restore points
Get-AzSynapseSqlPoolRestorePoint -ResourceGroupName $SourceResourceGroupName -WorkspaceName $SourceWorkspaceName -Name $SourceSQLPoolName
# Pick desired restore point using RestorePointCreationDate "xx/xx/xxxx xx:xx:xx xx"
$PointInTime="2/26/2025 1:36:15 PM" # Replace the date and time as per previous command output
 
# Get the specific SQL pool to restore
$SQLPool = Get-AzSynapseSqlPool -ResourceGroupName $SourceResourceGroupName -WorkspaceName $SourceWorkspaceName -Name $SourceSQLPoolName
# Transform Synapse SQL pool resource ID to SQL database ID because currently the restore command only accepts the SQL database ID format.
$DatabaseID = $SQLPool.Id -replace "Microsoft.Synapse", "Microsoft.Sql" -replace "workspaces", "servers" -replace "sqlPools", "databases"
 
# Switch context to the destination subscription
Select-AzSubscription -SubscriptionName $TargetSubscriptionName
 
# Restore database from a desired restore point of the source database to the target server in the desired subscription
$RestoredDatabase = Restore-AzSqlDatabase –FromPointInTimeBackup –PointInTime $PointInTime -ResourceGroupName $TargetResourceGroupName -ServerName $TargetServerName -TargetDatabaseName $TargetDatabaseName –ResourceId $DatabaseID
 
# Verify the status of restored database
$RestoredDatabase.status
 
# uncomment below cmdlets to perform one more restore to push the SQL Pool to an existing workspace in the destination subscription
# # Create restore point
New-AzSqlDatabaseRestorePoint -ResourceGroupName $RestoredDatabase.ResourceGroupName -ServerName $RestoredDatabase.ServerName -DatabaseName $RestoredDatabase.DatabaseName -RestorePointLabel "UD-001"
# Gets the last restore point of the sql dw (will use the RestorePointCreationDate property)
$RestorePoint = Get-AzSqlDatabaseRestorePoint -ResourceGroupName $RestoredDatabase.ResourceGroupName -ServerName $RestoredDatabase.ServerName -DatabaseName $RestoredDatabase.DatabaseName | Select -Last 1
# # Restore to destination synapse workspace
$FinalRestore = Restore-AzSynapseSqlPool –FromRestorePoint -RestorePoint $RestorePoint.RestorePointCreationDate -ResourceGroupName $TargetResourceGroupName -WorkspaceName $TargetWorkspaceName -TargetSqlPoolName $TargetDatabaseName –ResourceId $RestoredDatabase.ResourceID -PerformanceLevel DW100c