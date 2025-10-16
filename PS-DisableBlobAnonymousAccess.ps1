###This script is used to disabled the blob Anonymous access setting of the Storage accounts under configuration.
##Input the data in excel as three columns as column1 storageAccount, Column2 resourceGroup, column3 subscriptionId



# Load the ImportExcel module
Import-Module ImportExcel
# Load the Excel file
$filePath = "C:\path\storage_accounts.xlsx"
$data = Import-Excel -Path $filePath
# Loop through each row in the Excel sheet
foreach ($row in $data) {
   $storageAccount = $row.StorageAccount
   $resourceGroup = $row.ResourceGroup
   $subscriptionId = $row.SubscriptionId
   # Set the subscription
   Write-Host "Switching to subscription $subscriptionId"
   Set-AzContext -SubscriptionId $subscriptionId
   # Disable blob anonymous access
   Write-Host "Disabling blob anonymous access for $storageAccount in $resourceGroup"
   Set-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -AllowBlobPublicAccess $false
}