###This script is used to fetch the list of storage accounts having blob anonymous access enabled under configuration of the storage **not the container.


[System.Collections.ArrayList]$saUsage = New-Object -TypeName System.Collections.ArrayList
$validSubscriptions = @()
$validSubscriptions += "<1st SubscriptionName>"
$validSubscriptions += "<2nd SubscriptionName>"
$validSubscriptions += "<3rd SubscriptionName>"

#$subscriptions = Get-AzSubscription
$subscriptions = Get-AzSubscription -TenantId <TenantId_value> | Where { $_.State -eq "Enabled" -and $_.Name -in @($validSubscriptions) } | Sort "Name"
foreach ($subscription in $subscriptions) {
#echo $subscription.Name
#echo $subscription.Id
Set-AzContext -SubscriptionId $subscription.Id
$context = Get-AzContext
$SAs = Get-AzStorageAccount
foreach ($SA in $SAs) {
echo $SA
$StorageAccountDetails = [ordered]@{
                    SubscriptionName = $context.Subscription.Name
                    ResourceGroup = $SA.ResourceGroupName
                    StorageAccountName = $SA.StorageAccountName
                    Location = $SA.Location
                    AllowBlobPublicAcess = $SA.allowBlobPublicAccess
               }
             $saUsage.add((New-Object psobject -Property $StorageAccountDetails))  | Out-Null     
}
}
$saUsage | Export-Csv -Path C:\Path\To\storage_blob.csv -NoTypeInformation