#Adding containers in Storage account
#This script is to add containers in storage account.

Select-AzSubscription -Subscription "<SubscriptionName>" -Tenant "TenantID"
$containers = Get-Content -Path C:\Temp\containers.txt  #Local path where the list of containers present
$storageAccountResourceGroup = "<ResourceGroupName>"
$storageAccountName  = "<storageaccountname>"
 
 
foreach($container in $containers)
{
    Get-AzStorageAccount -ResourceGroupName $storageAccountResourceGroup -Name $storageAccountName
    $storageAccountKey = (Get-AzStorageAccountKey -Name $storageAccountName -ResourceGroupName "$storageAccountResourceGroup").Value[0]
    $storageContext = New-AzStorageContext –StorageAccountName  $storageAccountName -StorageAccountKey $storageAccountKey
    New-AzStorageContainer -Name $container -Permission Off -Context $storageContext
}