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

# Global Log File
if (!(Test-Path "./logs")) {
    New-Item -ItemType Directory -Path "./logs" | Out-Null
}

$RequestName = [System.IO.Path]::GetFileNameWithoutExtension($env:REQUEST_FILE)
$Environment = $env:ENVIRONMENT
$RunNumber = $env:GITHUB_RUN_NUMBER
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$Global:LogFile = Join-Path $LogFolder "$RequestName`_$Environment`_Run$RunNumber`_$TimeStamp.log"

function Write-Log {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $LogEntry = "[$TimeStamp] [$Level] $Message"

    # Console
    Write-Host $LogEntry

    # File
    Add-Content -Path $Global:LogFile -Value $LogEntry
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