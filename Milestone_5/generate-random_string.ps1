param($Timer)

Import-Module Az.Storage


Disconnect-AzAccount
Connect-AzAccount -Identity


$StorageAccountName = $env:Storage_Account_Name
$ResourceGroupName = $env:Resource_Group_Name
$ContainerName = $env:Container_Name

# Define storage details
# $StorageAccountName = "m05subtostorefile"
# $ResourceGroupName = "devops-interview-gauntlet-x-kgouda"
# $ContainerName = "stringcontainer"


$randomNumber = ""
for ($i = 1; $i -le 20; $i++) {
    $randomNumber += Get-Random -Min 0 -Max 9
}

# Create a filename with timestamp
$timestamp = Get-Date -Format "MMddyyy_HHmm"
$localFilePath = "$env:TEMP\RandomNumber_$timestamp.txt"
$blobName = "RandomNumber_$timestamp.txt"

# Save the random number to a file
$randomNumber | Out-File -FilePath $localFilePath

# Get Storage Context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$ctx = $storageAccount.Context

# Upload the file to Azure Storage
Set-AzStorageBlobContent -Container $ContainerName -File $localFilePath -Blob $blobName -Context $ctx

# to remove the local file after upload
Remove-Item -Path $localFilePath -Force

Write-Output "File '$blobName' uploaded successfully to '$ContainerName'"