# The below script will list all teh Empty Resource Groups from complete tenant.

Connect-AzAccount

# Get all subscriptions you have access to
$subscriptions = Get-AzSubscription

# Define a collection to store the empty resource groups
$emptyResourceGroups = @()

foreach ($subscription in $subscriptions) {
    # Set the context to the current subscription
    Set-AzContext -SubscriptionId $subscription.Id

    # Get all resource groups in the current subscription
    $resourceGroups = Get-AzResourceGroup

    foreach ($rg in $resourceGroups) {
        # Get resources in the current resource group
        $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName

        # If no resources are found in the resource group, add it to the list
        if ($resources.Count -eq 0) {
            $emptyResourceGroups += [PSCustomObject]@{
                SubscriptionName   = $subscription.Name
                SubscriptionId     = $subscription.Id
                ResourceGroupName  = $rg.ResourceGroupName
                Location           = $rg.Location
            }
        }
    }
}

# Export the list of empty resource groups to a CSV file to the desired filename
$outputFilePath = "C:\Temp\Yourfilename.csv"
$emptyResourceGroups | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Host "Export completed! The empty resource groups have been saved to $outputFilePath"