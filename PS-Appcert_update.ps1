###Create a excel sheet with four columns - Subscription, ResourceGroupName, AppName, Binding URL
$details = Import-Excel -Path C:\Temp\retailapps.xlsx
$newThumbprint = "<Thumbprint value>"
 
foreach ($line in $details) {
    Set-AzContext -TenantId 7406f7f1-ef6e-49f3-a9c0-002b8bc12056 -Subscription $line.Subscription
    "Getting Details of $($line.AppName)"
    $webApps = Get-AzWebApp -ResourceGroupName $line.ResourceGroupName -Name $line.AppName
    foreach ($webApp in $webApps) {               
        "Updating binding for $($line.Binding)"
        echo $line.ResourceGroupName
        echo $line.AppName
        echo $line.Binding
        #Get-AzWebAppSSLBinding -ResourceGroupName $line.ResourceGroupName -WebAppName $line.AppName
        New-AzWebAppSSLBinding -ResourceGroupName $line.ResourceGroupName -WebAppName $line.AppName -Thumbprint $newThumbprint -Name $line.Binding
    }
}