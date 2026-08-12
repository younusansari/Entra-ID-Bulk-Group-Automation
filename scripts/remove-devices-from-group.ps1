<#
.SYNOPSIS
    Bulk remove devices from Entra ID groups.

.DESCRIPTION
    Reads DeviceName and GroupName from the request CSV,
    resolves the device and group in Microsoft Entra ID,
    checks existing membership, and removes the device
    from the group when required.

.NOTES
    Author  : Younous Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Remove-DevicesFromGroup {

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

    Write-Log "Starting operation : Remove Devices from Group"

    #--------------------------------------------------------
    # Validate CSV Structure
    #--------------------------------------------------------

    Test-CsvColumns `
        -CsvPath $CsvPath `
        -RequiredColumns @(
            "DeviceName",
            "GroupName"
        )

    #--------------------------------------------------------
    # Import CSV
    #--------------------------------------------------------

    $Devices = @(
        Import-Csv -Path $CsvPath |
        Sort-Object -Property DeviceName, GroupName -Unique
    )

    Write-Log "Total unique records to process: $($Devices.Count)"

    #--------------------------------------------------------
    # Process Records
    #--------------------------------------------------------

    foreach ($DeviceRecord in $Devices)
    {
        $Processed++

        try
        {
            $DeviceName = "$($DeviceRecord.DeviceName)".Trim()
            $GroupName  = "$($DeviceRecord.GroupName)".Trim()

            #------------------------------------------------
            # Validate mandatory values
            #------------------------------------------------

            if (
                [string]::IsNullOrWhiteSpace($DeviceName) -or
                [string]::IsNullOrWhiteSpace($GroupName)
            )
            {
                $Failed++

                Write-Log `
                    "Invalid CSV record. DeviceName='$DeviceName', GroupName='$GroupName'. Both values are required." `
                    "ERROR"

                continue
            }

            Write-Log `
                "Processing device [$DeviceName] for group [$GroupName]"

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
            # Get Device
            #------------------------------------------------

            $EntraDevice = Get-EntraDevice `
                -DeviceName $DeviceName

            if ($null -eq $EntraDevice)
            {
                $Failed++

                Write-Log `
                    "Device [$DeviceName] not found." `
                    "ERROR"

                continue
            }

            #------------------------------------------------
            # Check Membership
            #------------------------------------------------

            if (
                -not (
                    Test-GroupMembership `
                        -GroupId $Group.Id `
                        -ObjectId $EntraDevice.Id
                )
            )
            {
                $Skipped++

                Write-Log `
                    "Device [$DeviceName] is not a member of [$GroupName]." `
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
                    "[Dry Run] Device [$DeviceName] would be removed from [$GroupName]."

                continue
            }

            #------------------------------------------------
            # Remove Device
            #------------------------------------------------

            Remove-MgGroupMemberDirectoryObjectByRef `
                -GroupId $Group.Id `
                -DirectoryObjectId $EntraDevice.Id

            $Successful++

            Write-Log `
                "Device [$DeviceName] successfully removed from [$GroupName]." `
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
        -Operation "Remove Devices from Group" `
        -Processed $Processed `
        -Successful $Successful `
        -Skipped $Skipped `
        -Failed $Failed `
        -StartTime $StartTime
}