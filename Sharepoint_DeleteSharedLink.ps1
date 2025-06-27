#Define Parameters
$SiteURL= "https://childrconnect.sharepoint.com"
$ListName = "PUBLIC"

#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -clientid <ClientID> -Interactive

#Get All items from List
$Items = Get-PnPListItem -List $ListName -PageSize 2000

#Iterate though each item in the list
ForEach($Item in $Items) {
    #Get Shared links of the item
      $HasUniquePermissions = Get-PnPProperty -ClientObject $Item -Property "HasUniqueRoleAssignments"
        If($HasUniquePermissions) {
            $RoleAssignments = Get-PnPProperty -ClientObject $Item -Property RoleAssignments
            ForEach($RoleAssignment in $RoleAssignments) {
                Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member                
                If($RoleAssignment.Member.Title -like "SharingLinks*") {
                    Remove-PnPGroup -Identity $RoleAssignment.Member.Title -Force
                    Write-host "Removed $($RoleAssignment.Member.Title) from $($Item.FieldValues.FileRef)"
                }
            } 
        }           
}