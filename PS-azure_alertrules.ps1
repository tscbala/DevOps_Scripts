[System.Collections.ArrayList]$alertrul = New-Object -TypeName System.Collections.ArrayList
$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions) {
Set-AzContext -SubscriptionId $subscription.Id
$context = Get-AzContext
$rgs = Get-AzResourceGroup
foreach ($rg in $rgs) {
#$alertrules = Get-AzMetricAlertRuleV2
$alertrules = Get-AzAlertRule -ResourceGroupName $rg.ResourceGroupName
foreach ($alertrule in $alertrules) {
$ar = [ordered]@{
                    SubscriptionName = $context.Subscription.Name
                    ResourceGroup = $alertrule.ResourceGroup
                    Name = $alertrule.Name
                    Actiongroup = $alertrule.Actions.ActionGroupId -join ';'
                    Enabled = $alertrule.Enabled
               }
             $alertrul.add((New-Object psobject -Property $ar))  | Out-Null
        }
        }
        }

$alertrul | Export-Csv -Path C:\temp\Alertrules_classic.csv -NoTypeInformation