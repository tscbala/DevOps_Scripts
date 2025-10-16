## This script is used to fetch the size of the Repo.
###replace NES.Clientportal with your repo name.
##Size is in bytes




$azcontext = Get-AzContext
 
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
 
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
 
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
 
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}
 
$url = "<Repository Browser URL>"
$details = Invoke-RestMethod -Uri $url -Method  Get -Headers $authHeader
echo $details




