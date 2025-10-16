$apps = Import-Excel -path "C:\Temp\appreg.xlsx"
foreach($line in $apps)
{
    write-host "checking $($line.DisplayName)"
    Update-AzADApplication -ApplicationId $line.AppID -Tag $line.Owner
}