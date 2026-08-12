<#
.SYNOPSIS
    Bulk add devices to Entra ID groups.

.DESCRIPTION
    Reads DeviceName and GroupName from the request CSV,
    resolves the device and group in Microsoft Entra ID,
    checks existing membership, and adds the device
    to the group when required.

.NOTES
    Author  : Younous Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Add-DevicesToGroup {

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

    Write-Log "Starting operation : Add Devices to Group"

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
                Test-GroupMembership `
                    -GroupId $Group.Id `
                    -ObjectId $EntraDevice.Id
            )
            {
                $Skipped++

                Write-Log `
                    "Device [$DeviceName] is already a member of [$GroupName]." `
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
                    "[Dry Run] Device [$DeviceName] would be added to [$GroupName]."

                continue
            }

            #------------------------------------------------
            # Add Device
            #------------------------------------------------

            New-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -BodyParameter @{
                    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($EntraDevice.Id)"
                }

            $Successful++

            Write-Log `
                "Device [$DeviceName] successfully added to [$GroupName]." `
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
        -Operation "Add Devices to Group" `
        -Processed $Processed `
        -Successful $Successful `
        -Skipped $Skipped `
        -Failed $Failed `
        -StartTime $StartTime
}