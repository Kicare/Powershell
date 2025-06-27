

#region ***Parameters***
$SiteURL="https://childrconnect.sharepoint.com/sites/MemberSpace/"
$CSVFile = "C:\temp\Powershell\ExportMember.txt"
$GroupName = 
#endregion
 
#Connect to the Site collection
$clientid = read-host "Client ID"
$Connect-PnPOnline -Url $SiteURL -clientid $clientid -Interactive
 
#Get the Folder from URL
Get-PnPGroup | foreach{write-output $_.LoginName;Get-PnPGroupMember -Identity $_ | format-table Title, Email -AutoSize}
