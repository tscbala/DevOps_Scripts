//Fetching data from the Azure montior logs (LogAnalytics workspace) using Perf table that stores Performance conutners for Windows & Linux servers.
//Using Log analytics workspace to fetch the Servername, Disk name, TotalSpace ,UsedSpace,Free Space Percentage and UsedSpace Percentage 

Perf
| where CounterName == "% Free Space"
| where InstanceName != '_Total'
| summarize arg_max(TimeGenerated, *) by Computer, InstanceName
| project Computer, InstanceName, PercentFreeSpace = CounterValue
| join kind = inner
(
    Perf
    | where CounterName == "Free Megabytes"
    | where InstanceName != '_Total'
    | summarize arg_max(TimeGenerated, *) by Computer, InstanceName
    | project Computer, InstanceName, FreeSpaceInGB = CounterValue / 1024
) on Computer, InstanceName
| project-away Computer1, InstanceName1
| project Computer = tostring(split(Computer, ".")[0]),
InstanceName,
TotalSpaceInGB = round((FreeSpaceInGB /( PercentFreeSpace * 0.01)), 2),
round(FreeSpaceInGB, 2),
UsedSpaceInGB = round((FreeSpaceInGB / ( PercentFreeSpace * 0.01)) * ((100 - PercentFreeSpace) * 0.01), 2),
PercentFreeSpace = round(PercentFreeSpace),
PercentUsedSpace = round(100 - PercentFreeSpace)
| order by PercentUsedSpace desc, Computer
