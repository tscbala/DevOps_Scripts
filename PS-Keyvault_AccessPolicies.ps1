## You can grant access to an AD group in all keyvaults listed in the excel sheet.
## You can add Keyvault RESOURCEGROUP and Keyvault NAME in the excel sheet, the script will go through each keyvault and assign given access.

$data = Import-Excel -Path C:\temp\Keyvaults.xlsx

Select-AzSubscription -Subscription "<Subscription_name>"
Set-AzContext -Subscription "<Subscription_name>"
foreach($line in $data)
{       
    $Keyvault = Get-AzKeyVault -ResourceGroupName ($line.RESOURCEGROUP) -Name ($line.NAME)  
    
 Set-AzKeyVaultAccessPolicy -VaultName $Keyvault -ObjectId "<objectID_value>" -PermissionsToSecrets Get, List, Set -PermissionsToKeys Get, List, Create
 
    Write-Host "Added $($Keyvault.Name).."  
}
