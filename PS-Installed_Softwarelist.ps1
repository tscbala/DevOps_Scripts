$servers = Get-Content "C:\Temp\servers.txt"


foreach ($server in $servers){
    Invoke-Command -ComputerName $server -ScriptBlock {Install-Module PSSoftware -Scope CurrentUser -AllowClobber -Force}
}

$Report = 
foreach ($server in $servers){
    #Invoke-Command -ComputerName $server -ScriptBlock {Install-Module PSSoftware -Scope CurrentUser -AllowClobber}
    Invoke-Command -ComputerName $server -ScriptBlock{
        Get-InstalledSoftware  | Select-Object Name, Version
       }
}
$Report | Export-Csv "C:\Temp\installedsoftware.csv" -NoTypeInformation