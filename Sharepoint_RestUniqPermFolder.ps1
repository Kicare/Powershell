#Set Variables
$SiteURL = "https://childrconnect.sharepoint.com"
$FolderURL = "/PUBLIC" #Document Library Site Relative URL
#Connect to the Site collection
$clientid = read-host "Client ID"
$Connect-PnPOnline -Url $SiteURL -clientid $clientid -Interactive
 
 
#Function to reset permissions of all Sub-Folders
Function Reset-SubFolderPermissions($FolderURL)
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
            #Reset permission inheritance
            Set-PnPListItemPermission -List $FolderItem.ParentList -Identity $FolderItem.ID -InheritPermissions
            Write-host "`tUnique Permissions are removed from the Folder!"
        }
 
        #Call the function recursively
        Reset-SubFolderPermissions $SubFolderURL
    }
}
   
#Call the function
Reset-SubFolderPermissions $FolderURL