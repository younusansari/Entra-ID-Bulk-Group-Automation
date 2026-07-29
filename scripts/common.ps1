<#
.SYNOPSIS
    Common helper functions for Entra ID Bulk User Device Automation.

.NOTES
    Author  : Younus Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#------------------------------------------------------------
# Write-Log
#------------------------------------------------------------

function Write-Log {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host "[$TimeStamp] [$Level] $Message"
}

#------------------------------------------------------------
# Test-CsvFile
#------------------------------------------------------------

function Test-CsvFile {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (!(Test-Path $Path))
    {
        throw "Request file not found: $Path"
    }

    $Csv = Import-Csv $Path

    if ($Csv.Count -eq 0)
    {
        throw "CSV file is empty."
    }

    Write-Log "CSV validation successful."

}

#------------------------------------------------------------
# Get-EntraGroup
#------------------------------------------------------------

function Get-EntraGroup {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName
    )

    Get-MgGroup -Filter "displayName eq '$GroupName'"
}

#------------------------------------------------------------
# Get-EntraUser
#------------------------------------------------------------

function Get-EntraUser {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Email
    )

    Get-MgUser -Filter "mail eq '$Email'"
}

#------------------------------------------------------------
# Get-EntraDevice
#------------------------------------------------------------

function Get-EntraDevice {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DeviceName
    )

    Get-MgDevice -Filter "displayName eq '$DeviceName'"
}

#------------------------------------------------------------
# Test-GroupMembership
#------------------------------------------------------------

function Test-GroupMembership {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupId,

        [Parameter(Mandatory)]
        [string]$ObjectId
    )

    $Member = Get-MgGroupMember `
                -GroupId $GroupId `
                -All |
              Where-Object { $_.Id -eq $ObjectId }

    return ($null -ne $Member)
}