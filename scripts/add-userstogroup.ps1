function Add-UsersToGroup {

param(
    [string]$CsvPath
)

$Users = Import-Csv $CsvPath

foreach ($User in $Users)
{
    try
    {
        Write-Log "Processing $($User.Email)"

        $Group = Get-MgGroup -Filter "displayName eq '$($User.GroupName)'"

        if(!$Group)
        {
            Write-Log "Group not found." "ERROR"
            continue
        }

        $EntraUser = Get-MgUser -Filter "mail eq '$($User.Email)'"

        if(!$EntraUser)
        {
            Write-Log "User not found." "ERROR"
            continue
        }

        $Existing = Get-MgGroupMember `
            -GroupId $Group.Id -All |
            Where-Object {$_.Id -eq $EntraUser.Id}

        if($Existing)
        {
            Write-Log "$($User.Email) already exists."
            continue
        }

        New-MgGroupMember `
            -GroupId $Group.Id `
            -DirectoryObjectId $EntraUser.Id

        Write-Log "$($User.Email) added successfully." "SUCCESS"

    }
    catch
    {
        Write-Log $_.Exception.Message "ERROR"
    }
}
}