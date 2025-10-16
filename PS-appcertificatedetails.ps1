[System.Collections.ArrayList]$appser = New-Object -TypeName System.Collections.ArrayList
$validSubscriptions = @()
$validSubscriptions += "<subcriptionname1>"
$validSubscriptions += "<subcriptionname2>"
$validSubscriptions += "<subcriptionname3>"

$subscriptions = Get-AzSubscription -TenantId <tenantidvalue> | Where { $_.State -eq "Enabled" -and $_.Name -in @($validSubscriptions) } | Sort "Name"
foreach ($subscription in $subscriptions) {
#echo $subscription.Name
#echo $subscription.Id
Set-AzContext -SubscriptionId $subscription.Id
$context = Get-AzContext
$appservices = Get-AzWebApp
foreach ($appservice in $appservices) {
echo $appservice
$as = [ordered]@{
                    SubscriptionName = $context.Subscription.Name
                    ResourceGroup = $appservice.ResourceGroup
                    Name = $appservice.Name
                    urlname = $appservice.HostNameSslStates.Name -join ' '
                    Thumbprint = $appservice.HostNameSslStates.Thumbprint -join ' '
               }
             $appser.add((New-Object psobject -Property $as))  | Out-Null
        }
        }

$appser | Export-Csv -Path C:\temp\Appcert.csv -NoTypeInformation