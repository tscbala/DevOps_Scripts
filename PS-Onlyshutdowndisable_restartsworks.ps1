
# Install and Import Azure PowerShell Module (if not installed)
# Install-Module -Name Az -Force -Scope CurrentUser
# Import-Module Az

# Connect to Azure
Connect-AzAccount

# Define Resource Group and VM Name
$resourceGroup = "vm RG"
$vmName = "vm hostname"

# Define the script to disable Shutdown but keep Restart
$script = @'
# Disable Shutdown in Start Menu but keep Restart
$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$registryName = "NoClose"
$registryValue = 1  # 1 = Disable Shutdown, 0 = Enable Shutdown

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord

# Restart Explorer to apply changes
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "Shutdown disabled. Restart option remains available."
'@

# Execute script on Azure VM remotely
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroup -VMName $vmName -CommandId "RunPowerShellScript" -ScriptString $script

Write-Host "Shutdown disabled on VM: $vmName"

