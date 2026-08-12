<#
.SYNOPSIS
    Bulk add users to Entra ID security groups.

.DESCRIPTION
    Reads UserEmail and GroupName from the request CSV
    and adds users to the specified Entra ID groups.

.NOTES
    Author  : Younous Ansari
    Project : Entra ID Bulk Group Automation
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

    $Processed  = 0
    $Successful = 0
    $Skipped    = 0
    $Failed     = 0

    $StartTime = Get-Date

    Write-Log "Starting operation : Add Users to Group"

    #--------------------------------------------------------
    # Validate CSV Structure
    #--------------------------------------------------------

    Test-CsvColumns `
        -CsvPath $CsvPath `
        -RequiredColumns @(
            "UserEmail",
            "GroupName"
        )

    #--------------------------------------------------------
    # Import CSV
    #--------------------------------------------------------

    $Users = @(
        Import-Csv -Path $CsvPath |
        Sort-Object -Property UserEmail, GroupName -Unique
    )

    Write-Log "Total unique records to process: $($Users.Count)"

    #--------------------------------------------------------
    # Process Records
    #--------------------------------------------------------

    foreach ($UserRecord in $Users)
    {
        $Processed++

        try
        {
            $Email = "$($UserRecord.UserEmail)".Trim()
            $GroupName = "$($UserRecord.GroupName)".Trim()

            #------------------------------------------------
            # Validate Record
            #------------------------------------------------

            if (
                [string]::IsNullOrWhiteSpace($Email) -or
                [string]::IsNullOrWhiteSpace($GroupName)
            )
            {
                $Failed++

                Write-Log `
                    "Invalid CSV record. UserEmail='$Email', GroupName='$GroupName'. Both values are required." `
                    "ERROR"

                continue
            }

            Write-Log `
                "Processing user [$Email] for group [$GroupName]"

            #------------------------------------------------
            # Get Group
            #------------------------------------------------

            $Group = Get-EntraGroup `
                -GroupName $GroupName

            if ($null -eq $Group)
            {
                $Failed++

                Write-Log `
                    "Group [$GroupName] not found." `
                    "ERROR"

                continue
            }

            #------------------------------------------------
            # Get User
            #------------------------------------------------

            $EntraUser = Get-EntraUser `
                -Email $Email

            if ($null -eq $EntraUser)
            {
                $Failed++

                Write-Log `
                    "User [$Email] not found." `
                    "ERROR"

                continue
            }

            #------------------------------------------------
            # Check Membership
            #------------------------------------------------

            if (
                Test-GroupMembership `
                    -GroupId $Group.Id `
                    -ObjectId $EntraUser.Id
            )
            {
                $Skipped++

                Write-Log `
                    "User [$Email] is already a member of [$GroupName]." `
                    "WARNING"

                continue
            }

            #------------------------------------------------
            # Dry Run
            #------------------------------------------------

            if ($DryRun -eq "Yes")
            {
                $Skipped++

                Write-Log `
                    "[Dry Run] User [$Email] would be added to [$GroupName]."

                continue
            }

            #------------------------------------------------
            # Add User
            #------------------------------------------------

            New-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -BodyParameter @{
                    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($EntraUser.Id)"
                }

            $Successful++

            Write-Log `
                "User [$Email] successfully added to [$GroupName]." `
                "SUCCESS"
        }
        catch
        {
            $Failed++

            Write-Log `
                $_.Exception.Message `
                "ERROR"
        }
    }

    #--------------------------------------------------------
    # Execution Summary
    #--------------------------------------------------------

    Write-Log "Finished processing all request records."

    Write-ExecutionSummary `
        -Operation "Add Users to Group" `
        -Processed $Processed `
        -Successful $Successful `
        -Skipped $Skipped `
        -Failed $Failed `
        -StartTime $StartTime
}