#get user member from sharepoint UniqPerm
#Install-Module Microsoft.Entra -AllowClobber
import-module Microsoft.Entra
Connect-Entra -Scopes 'User.Read.All', 'GroupMember.Read.All'

$InFile= $(ls "$pwd\iQoneDoc*.csv")
$ReportFile="$pwd\iQoneRights.csv"
if(($InFile -eq $null)){
	write-host -ForegroundColor red "File 'iQoneDoc*.csv' missing"
	exit
}
if(($InFile -is [array])){
	write-host -ForegroundColor red "Only on file 'iQoneDoc*.csv' in this folder"
	exit
}
$rightList = Import-Csv "$pwd\iQoneDoc*.csv"

$PermissionCollection = @()
foreach($right in $rightList){
    if($right.'User Or Group Type' -eq "SecurityGroup"){
        $gn = $right.'User Name'
        $group = Get-EntraGroup -Filter "DisplayName eq '$gn'"
        $groupmembers = Get-EntraGroupMember -GroupId $group.Id -All | Select-Object DisplayName ,mail, accountEnabled
        foreach($groupmember in $groupmembers){
            $Permissions = New-Object PSObject
            $Permissions | Add-Member -NotePropertyName "Path" -NotePropertyValue  $right.'Resource Path'
            $Permissions | Add-Member -NotePropertyName "Type" -NotePropertyValue  $right.'Item Type'
            $Permissions | Add-Member -NotePropertyName "Permission" -NotePropertyValue  $right.Permission
            $Permissions | Add-Member -NotePropertyName "GroupName" -NotePropertyValue  "$gn"
            $Permissions | Add-Member -NotePropertyName "UserName" -NotePropertyValue  $groupmember.displayname
            $Permissions | Add-Member -NotePropertyName "User Email" -NotePropertyValue  $groupmember.mail
            $Permissions | Add-Member -NotePropertyName "Enabled" -NotePropertyValue  $groupmember.accountEnabled
            $PermissionCollection += $Permissions
        }
    }else{
        if($right.'User Or Group Type' -eq "Internal"){
            $entraUser = Get-EntraUser -UserId $right.'User Email' -Property AccountEnabled
            $Permissions = New-Object PSObject
            $Permissions | Add-Member -NotePropertyName "Path" -NotePropertyValue  $right.'Resource Path'
            $Permissions | Add-Member -NotePropertyName "Type" -NotePropertyValue  $right.'Item Type'
            $Permissions | Add-Member -NotePropertyName "Permission" -NotePropertyValue  $right.Permission
            $Permissions | Add-Member -NotePropertyName "GroupName" -NotePropertyValue  ""
            $Permissions | Add-Member -NotePropertyName "UserName" -NotePropertyValue  $right.'User Name'
            $Permissions | Add-Member -NotePropertyName "User Email" -NotePropertyValue  $right.'User Email'
            $Permissions | Add-Member -NotePropertyName "Enabled" -NotePropertyValue  $entraUser.AccountEnabled
            $PermissionCollection += $Permissions
        }else{
            if($right.'User Or Group Type' -eq "SharePointGroup"){
                $Permissions = New-Object PSObject
                $Permissions | Add-Member -NotePropertyName "Path" -NotePropertyValue  $right.'Resource Path'
                $Permissions | Add-Member -NotePropertyName "Type" -NotePropertyValue  $right.'Item Type'
                $Permissions | Add-Member -NotePropertyName "Permission" -NotePropertyValue  $right.Permission
                $Permissions | Add-Member -NotePropertyName "GroupName" -NotePropertyValue  $right.'User Name'
                $Permissions | Add-Member -NotePropertyName "UserName" -NotePropertyValue  ""
                $Permissions | Add-Member -NotePropertyName "User Email" -NotePropertyValue  $right.'User Email'
                $Permissions | Add-Member -NotePropertyName "Enabled" -NotePropertyValue  ""
                $PermissionCollection += $Permissions
            }else{
                Write-host -BackgroundColor Red "$($right.'User Or Group Type') Unknown"
            }
        }
    }
}


$PermissionCollection | Export-CSV $ReportFile -NoTypeInformation -Encoding utf8
