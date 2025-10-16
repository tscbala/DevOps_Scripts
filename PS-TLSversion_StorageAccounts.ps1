# Get all subscriptions in the tenant
$subscriptions = Get-AzSubscription
$results = @()
foreach ($sub in $subscriptions) {
   Set-AzContext -SubscriptionId $sub.Id | Out-Null
   # Get all storage accounts in the subscription
   $storageAccounts = Get-AzStorageAccount
   foreach ($storage in $storageAccounts) {
       $results += [PSCustomObject]@{
           SubscriptionName = $sub.Name
           ResourceGroup    = $storage.ResourceGroupName
           StorageAccount   = $storage.StorageAccountName
           Location         = $storage.Location
           MinimumTlsVersion = $storage.MinimumTlsVersion
           SkuName          = $storage.Sku.Name
           Kind             = $storage.Kind
       }
   }
}
# Display the results
$results | Format-Table -AutoSize
# Optionally export to CSV
$results | Export-Csv -Path "StorageAccounts_TLS.csv" -NoTypeInformation