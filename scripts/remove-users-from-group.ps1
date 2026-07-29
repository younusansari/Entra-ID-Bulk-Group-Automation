<#
.SYNOPSIS
    Bulk remove users from Entra ID security groups.

.NOTES
    Author  : Younus Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Remove-UsersFromGroup {

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

    $StartTime  = Get-Date

    Write-Log "Starting operation : Remove Users from Group"
    # Validate CSV Structure
    Test-CsvColumns `
        -CsvPath $CsvPath `
        -RequiredColumns @("email", "group_name")

    $Users = Import-Csv -Path $CsvPath |
        Sort-Object -Property email, group_name -Unique
    
    Write-Log "Total unique records to process: $($Users.Count)"

    foreach ($UserRecord in $Users)
    {
        $Processed++

        try
        {
            $Email     = "$($UserRecord.email)".Trim()
            $GroupName = "$($UserRecord.group_name)".Trim()

            # Validate mandatory values
            if ([string]::IsNullOrWhiteSpace($Email) -or
                [string]::IsNullOrWhiteSpace($GroupName))
            {
                $Failed++
                Write-Log "Invalid CSV record. Email='$Email', Group='$GroupName'. Both values are required." "ERROR"
                continue
            }

            Write-Log "Processing user [$Email] for group [$GroupName]"

            # Get Group
            $Group = Get-EntraGroup -GroupName $GroupName

            if ($null -eq $Group)
            {
                $Failed++
                Write-Log "Group [$GroupName] not found." "ERROR"
                continue
            }

            # Get User
            $EntraUser = Get-EntraUser -Email $Email

            if ($null -eq $EntraUser)
            {
                $Failed++
                Write-Log "User [$Email] not found." "ERROR"
                continue
            }

            # Check Membership
            if (-not (Test-GroupMembership -GroupId $Group.Id -ObjectId $EntraUser.Id))
            {
                $Skipped++
                Write-Log "User [$Email] is not a member of [$GroupName]." "WARNING"
                continue
            }
    
            # Dry Run
            if ($DryRun -eq "Yes")
            {
                $Skipped++

                Write-Log "[Dry Run] User [$Email] would be removed from [$GroupName]."

                continue
            }

            # Remove User
            Remove-MgGroupMemberDirectoryObjectByRef `
                -GroupId $Group.Id `
                -DirectoryObjectId $EntraUser.Id

            $Successful++
            Write-Log "User [$Email] successfully removed from [$GroupName]." "SUCCESS"
            

        }
        catch
        {
            $Failed++
            Write-Log $_.Exception.Message "ERROR"
        }
    }
    
    Write-Log "Finished processing all request records."
    Write-ExecutionSummary `
        -Operation "Remove Users from Group" `
        -Processed $Processed `
        -Successful $Successful `
        -Skipped $Skipped `
        -Failed $Failed `
        -StartTime $StartTime
    
}