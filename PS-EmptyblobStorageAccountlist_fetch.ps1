###This script is used to fetch the list of storage account which has containers with its names, also used to find out the empty storage accounts, set your subscription as needed.


# Initialize an array to store storage account details
$StorageAccountDetails = @()
# Get all storage accounts in the current subscription
$StorageAccounts = Get-AzStorageAccount
# Loop through each storage account
foreach ($StorageAccount in $StorageAccounts) {
    $StorageAccountName = $StorageAccount.StorageAccountName
    $ResourceGroupName = $StorageAccount.ResourceGroupName
    # Get the storage account context
    #$StorageAccountContext = $StorageAccount.Context
    $StorageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccountName
    # Retrieve containers, file shares, tables, and queues
    $Containers = Get-AzStorageContainer -Context $StorageAccountContext
    $FileShares = Get-AzStorageShare -Context $StorageAccountContext
    $Tables = Get-AzStorageTable -Context $StorageAccountContext
    $Queues = Get-AzStorageQueue -Context $StorageAccountContext
    # Add storage account details to the array
    $StorageAccountDetails += [PSCustomObject]@{
        'StorageAccountName' = $StorageAccountName
        'ResourceGroupName' = $ResourceGroupName
        'Containers' = ($Containers | Select-Object -ExpandProperty Name) -join ', '
        'FileShares' = ($FileShares | Select-Object -ExpandProperty Name) -join ', '
        'Tables' = ($Tables | Select-Object -ExpandProperty Name) -join ', '
        'Queues' = ($Queues | Select-Object -ExpandProperty Name) -join ', '
    }
}
# Export storage account details to an Excel sheet
$StorageAccountDetails | Export-Excel -Path "C:\temp\Output\Retail Prod.xlsx" -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow