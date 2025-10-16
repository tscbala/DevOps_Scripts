#### this script is used to fetch the list of storage accounts which have network public access enabled.
##set subscription as needed.


# Get the list of storage accounts with networking set to 'Allow'
$storageAccounts = Get-AzStorageAccount | Where-Object { $_.NetworkRuleSet.DefaultAction -eq 'Allow' } | Select-Object StorageAccountName, ResourceGroupName, Location

# Export the data to an Excel sheet
$storageAccounts | Export-Excel -Path "C:\path\to\output\StorageAccounts_PublicAccessenabled.xlsx" -WorksheetName "StorageAccounts"
