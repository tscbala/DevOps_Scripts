###This script is used fetch the list of users in AD Groups. We can input the list of AD Groups in the form of excel sheet and give its path###
Connect-AzureAD
$excelFilePath = "C:\path\to\groupnames.xlsx"
$excelData = Import-Excel -Path $excelFilePath
$groupNames = $excelData.'Group Name'
$GroupMemberDetails = @()
$groupNames | ForEach-Object { 
# Get Group and Members
Write-Output "Fetching the Data for:" $_
$Group = Get-AzureADGroup -SearchString $_
foreach ($item1 in $Group){
$GroupMembers = Get-AzureADGroupMember -ObjectId $item1.ObjectId -All $True | Select DisplayName, UserPrincipalName
foreach ($item in $GroupMembers) 
{
$GroupMemberDetails += [PSCustomObject]@{
       'GroupName' = $item1.DisplayName
        'Display_Name' = $item.DisplayName
        'User_Prinicpal_Name' = $item.UserPrincipalName
    }
}
}
}
$GroupMemberDetails | Export-Excel -Path "C:\path\to\output.xlsx" -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow
