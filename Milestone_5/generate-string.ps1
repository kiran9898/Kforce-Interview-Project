$randomNumber = ""
for ($i = 1; $i -le 20; $i++) {
    $randomNumber += Get-Random -Min 0 -Max 9
}
Write-Output $randomNumber

$file_Name =  "Random_Number_$([datetime]::Now.ToString("MMddyyyy_HH:mm")).txt";

$file_Path = Join-Path -Path ".\files\" -ChildPath $File_Name

$randomNumber | Out-File -FilePath $file_Path

$accountKey = az storage account keys list `
    --resource-group "devops-interview-gauntlet-x-kgouda" `
    --account-name "m05subtostorefile" `
    --query '[0].value' `
    --output tsv

Write-Host "storage account is --> $accountKey"

# Upload the file to the blob container
az storage blob upload `
    --account-name "m05subtostorefile" `
    --account-key $accountKey `
    --container-name "stringcontainer" `
    --name $file_Name `
    --file $file_Path `
    --overwrite


Remove-Item $file_Path -Force

Write-Host "Uploaded $file_Name with value: $randomNumber"