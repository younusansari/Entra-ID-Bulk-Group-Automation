<#
.SYNOPSIS
    Bulk add users to Entra ID security groups.

.NOTES
    Author  : Younus Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Add-UsersToGroup {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CsvPath,

        [Parameter(Mandatory)]
        [ValidateSet("Yes","No")]
        [string]$DryRun
    )

    Write-Log "Starting operation : Add Users to Group"

    $Users = Import-Csv $CsvPath

    foreach ($User in $Users)
    {
        try
        {
            $Email = $User.email.Trim()
            $GroupName = $User.group_name.Trim()

            Write-Log "Processing user [$Email]"

            # Get Group
            $Group = Get-EntraGroup -GroupName $GroupName

            if ($null -eq $Group)
            {
                Write-Log "Group [$GroupName] not found." "ERROR"
                continue
            }

            # Get User
            $EntraUser = Get-EntraUser -Email $Email

            if ($null -eq $EntraUser)
            {
                Write-Log "User [$Email] not found." "ERROR"
                continue
            }

            # Check Membership
            if (Test-GroupMembership -GroupId $Group.Id -ObjectId $EntraUser.Id)
            {
                Write-Log "User [$Email] is already a member of [$GroupName]." "WARNING"
                continue
            }

            # Dry Run
            if ($DryRun -eq "Yes")
            {
                Write-Log "[Dry Run] User [$Email] would be added to [$GroupName]."
                continue
            }

            # Add User
            New-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -BodyParameter @{
                    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($EntraUser.Id)"
                }

            Write-Log "User [$Email] successfully added to [$GroupName]." "SUCCESS"

        }
        catch
        {
            Write-Log $_.Exception.Message "ERROR"
        }
    }

    Write-Log "Add Users to Group operation completed."
}