###This script helps to fetch the list of App Registrations for which client secret or certificate is expired


# Install required modules
#Install-Module Microsoft.Graph
#Install-Module ImportExcel
# Connect to Microsoft Graph with the necessary permissions
Connect-MgGraph -Scopes "Application.Read.All"
# List to store expired app credentials
$expiredApps = @()
# Pagination handling for large number of applications
$appPage = Get-MgApplication -All
foreach ($app in $appPage) {
   $secrets = $app.PasswordCredentials
   $certificates = $app.KeyCredentials
   # Extract tags (or empty if none exist)
   $tags = if ($app.Tags) { $app.Tags -join ", " } else { "No Tags" }
   # Check for expired secrets
   foreach ($secret in $secrets) {
       if ($secret.EndDateTime -lt (Get-Date)) {
           $expiredApps += [pscustomobject]@{
               AppName          = $app.DisplayName
               CredentialType   = 'Secret'
               ExpirationDate   = $secret.EndDateTime
               AppId            = $app.AppId
               ObjectId         = $app.Id
               Tags             = $tags
           }
       }
   }
   # Check for expired certificates
   foreach ($certificate in $certificates) {
       if ($certificate.EndDateTime -lt (Get-Date)) {
           $expiredApps += [pscustomobject]@{
               AppName          = $app.DisplayName
               CredentialType   = 'Certificate'
               ExpirationDate   = $certificate.EndDateTime
               AppId            = $app.AppId
               ObjectId         = $app.Id
               Tags             = $tags
           }
       }
   }
}
# Export to Excel
$outputFilePath = "C:\path\to\ExpiredAppCredentials_WithTags.xlsx"
$expiredApps | Export-Excel -Path $outputFilePath -AutoSize
Write-Host "Exported expired app credentials with tags to $outputFilePath"

