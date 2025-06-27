#Set Variables  
$SiteURL = "https://https://iqonehc.sharepoint.com/sites/iQoneDoc/"  
$FolderURL = "/Shared Documents" #Document Library Site Relative URL  
$ReportFile = "C:\temp\AllIqoneFolderPermission.csv"
#Connect to the Site collection
$clientid = read-host "Client ID"
$Connect-PnPOnline -Url $SiteURL -clientid $clientid -Interactive


Function Get-PnPPermissions([Microsoft.SharePoint.Client.SecurableObject]$Object, [String]$SubFolderURL)
{
    Try {
        #Get permissions assigned to the Folder
        Get-PnPProperty -ClientObject $Object -Property HasUniqueRoleAssignments, RoleAssignments
 
        #Check if Object has unique permissions
        $HasUniquePermissions = $Object.HasUniqueRoleAssignments
    
        #Loop through each permission assigned and extract details
        $PermissionCollection = @()
        Foreach($RoleAssignment in $Object.RoleAssignments)
        { 
            #Get the Permission Levels assigned and Member
            Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
    
            #Get the Principal Type: User, SP Group, AD Group
            $PermissionType = $RoleAssignment.Member.PrincipalType
            $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name
 
            #Remove Limited Access
            $PermissionLevels = ($PermissionLevels | Where { $_ -ne "Limited Access"}) -join ","
            If($PermissionLevels.Length -eq 0) {Continue}
 
            #Get SharePoint group members
            If($PermissionType -eq "SharePointGroup")
            {
                #Get Group Members
                $GroupMembers = Get-PnPGroupMember -Identity $RoleAssignment.Member.LoginName
                 
                #Leave Empty Groups
                If($GroupMembers.count -eq 0){Continue}
 
                ForEach($User in $GroupMembers)
                {
                    $Permissions = New-Object PSObject
                    $Permissions | Add-Member NoteProperty SubFolderURL($SubFolderURL)
                    $Permissions | Add-Member NoteProperty Name($name)
                    $Permissions | Add-Member NoteProperty User($User.Title)
                    $Permissions | Add-Member NoteProperty Type($PermissionType)
                    $Permissions | Add-Member NoteProperty Permissions($PermissionLevels)
                    $Permissions | Add-Member NoteProperty GrantedThrough("SharePoint Group: $($RoleAssignment.Member.LoginName)")
                    $PermissionCollection += $Permissions
                }
            }
            Else
            {
                $Permissions = New-Object PSObject
                $Permissions | Add-Member NoteProperty SubFolderURL($SubFolderURL)
                $Permissions | Add-Member NoteProperty Name($name)
                $Permissions | Add-Member NoteProperty User($RoleAssignment.Member.Title)
                $Permissions | Add-Member NoteProperty Type($PermissionType)
                $Permissions | Add-Member NoteProperty Permissions($PermissionLevels)
                $Permissions | Add-Member NoteProperty GrantedThrough("Direct Permissions")
                $PermissionCollection += $Permissions
            }
        }
        #Export Permissions to CSV File
        $PermissionCollection | Export-CSV $ReportFile -NoTypeInformation -Append
        Write-host -f Green "`n*** Folder Permission Report Generated Successfully!***"
    }
    Catch {
    write-host -f Red "Error Generating Folder Permission Report!" $_.Exception.Message
    }
}


#Function to reset permissions of all Sub-Folders  
Function Get-SubFolderPermissions($FolderURL)  
{
    #Get all sub-folders of the Folder - Exclude system folders  
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderURL -ItemType Folder | Where {$_.Name -ne "Forms" -and $_.Name -ne "Document"}  

    #Loop through each sub-folder  
    ForEach($SubFolder in $SubFolders)  
    {  
        $SubFolderURL = $FolderUrl+"/"+$SubFolder.Name  
        Write-host -ForegroundColor Green "Processing Folder '$($SubFolder.Name)' at $SubFolderURL"  

        #Get the Folder Object - with HasUniqueAssignments and ParentList properties  
        $Folder = Get-PnPFolder -Url $SubFolderURL -Includes ListItemAllFields.HasUniqueRoleAssignments, ListItemAllFields.ParentList, ListItemAllFields.ID  

        #Get the List Item of the Folder  
        $FolderItem = $Folder.ListItemAllFields  

        #Check if the Folder has unique permissions  
        If($FolderItem.HasUniqueRoleAssignments)  
        {  
            Get-PnPPermissions $Folder.ListItemAllFields $SubFolderURL
        }  

        #Call the function recursively  
        Get-SubFolderPermissions $SubFolderURL
    }  
}

Get-PnPPermissions

#Call the function
Get-SubFolderPermissions $FolderURL