##This Script is used to add specific site to an App.
##Prerequisites for this script are that App should have sites.selected Microsoft Graph permission granted on it.
##The changes we need to do to this script are change the Site ID and assignee client ID as per request and verify the asigner client secret is valid or not.
 ##### Get the client secret value from cpn-devops key vault--sites.selected

# Variables
$tenantId = "<tenantId_value>"
$assignerClientId = "<clientid_value>"
$assignerClientSecret = "**************************************"
$spoOrg = "cpncorp.sharepoint.com"
$siteId = "<siteid_value>"
$assigneeClientId = "<assigneeClientId_value>"
$assigneeDisplayName = "<assigneeDisplayName>"
$role = "write" # Example roles: read, write

# Function to acquire an access token
function Get-GraphAccessToken {
    param (
        $TenantId,
        $ClientId,
        $ClientSecret
    )

    $body = @{
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $ClientId
        client_secret = $ClientSecret
    }

    $accessTokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    return $accessTokenResponse.access_token
}

# Function to add permissions to a SharePoint site
function Add-SPOSitePermissions {
    param (
        $AccessToken,
        $SPOOrg,
        $SiteId,
        $ClientId,
        $DisplayName,
        $Role
    )

    $url = "https://graph.microsoft.com/v1.0/sites/$SPOOrg,$SiteId/permissions"
    Write-Host $url
    $body = @{
        roles = @($Role)
        grantedToIdentities = @(
            @{
                application = @{
                    id = $ClientId
                    displayName = $DisplayName
                }
            }
        )
    } | ConvertTo-Json -Depth 5

    Write-Host $body

    $headers = @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Body $body -Method Post
    return $response
}

# Acquire an access token
$accessToken = Get-GraphAccessToken -TenantId $tenantId -ClientId $assignerClientId -ClientSecret $assignerClientSecret

# Add permissions to the SharePoint site
$result = Add-SPOSitePermissions -AccessToken $accessToken -SPOOrg $spoOrg -SiteId $siteId -ClientId $assigneeClientId -DisplayName $assigneeDisplayName -Role $role

# Output the result
$result