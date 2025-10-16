#### This script is used to copy a managed disk to a storage account in VHD format
### Reference DOcumentation:  https://learn.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-powershell-sample-copy-managed-disks-vhd



#Provide the subscription Id of the subscription where managed disk is created
$subscriptionId = "<subscriptionId>"
#Provide the name of your resource group where managed is created
$resourceGroupName ="<resourceGroupName>"
#Provide the managed disk name 
$diskName = "<diskName>"
#Provide Shared Access Signature (SAS) expiry duration in seconds e.g. 3600.
#Know more about SAS here: https://docs.microsoft.com/en-us/Az.Storage/storage-dotnet-shared-access-signature-part-1
$sasExpiryDuration = "3600"
#Provide storage account name where you want to copy the underlying VHD of the managed disk. 
$storageAccountName = "<storageAccountName>"
#Name of the storage container where the downloaded VHD will be stored##Create manually
$storageContainerName = "<storagecontainername>"
#Provide the key of the storage account where you want to copy the VHD of the managed disk. 
$storageAccountKey = '<storageaccountkeyvalue>'
#Provide the name of the destination VHD file to which the VHD of the managed disk will be copied.
$destinationVHDFileName = "<vhdfilename>"
#Set the value to 1 to use AzCopy tool to download the data. This is the recommended option for faster copy.
#Download AzCopy v10 from the link here: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
#Ensure that AzCopy is downloaded in the same folder as this file
#If you set the value to 0 then Start-AzStorageBlobCopy will be used. Azure storage will asynchronously copy the data. 
$useAzCopy = 1
# Set the context to the subscription Id where managed disk is created
Select-AzSubscription -SubscriptionId $SubscriptionId
#Generate the SAS for the managed disk 
$sas = Grant-AzDiskAccess -ResourceGroupName $ResourceGroupName -DiskName $diskName -DurationInSecond $sasExpiryDuration -Access Read
#Create the context of the storage account where the underlying VHD of the managed disk will be copied
$destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$storageurl = $destinationContext.BlobEndPoint
#Copy the VHD of the managed disk to the storage account
if($useAzCopy -eq 1)
{
    #$containerSASURI = New-AzStorageContainerSASToken -Context $destinationContext -ExpiryTime(get-date).AddSeconds($sasExpiryDuration) -FullUri -Name $storageContainerName -Permission rw
    #./azcopy.exe copy $sas.AccessSAS $containerSASURI
    $containerSAStoken = New-AzStorageContainerSASToken -Context $destinationContext -ExpiryTime(get-date).AddSeconds($sasExpiryDuration) -Name $storageContainerName -Permission rw
    ./azcopy.exe copy $sas.AccessSAS ${storageurl}${storageContainerName}/${destinationVHDFileName}?$containerSAStoken
}else{
Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $storageContainerName -DestContext $destinationContext -DestBlob $destinationVHDFileName
}