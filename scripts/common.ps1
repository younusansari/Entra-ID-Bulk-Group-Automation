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

#------------------------------------------------------------
# Logging Configuration
#------------------------------------------------------------

$LogFolder = "./logs"

if (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}

$RequestName = [System.IO.Path]::GetFileNameWithoutExtension($env:REQUEST_FILE)

if ([string]::IsNullOrWhiteSpace($RequestName)) {
    $RequestName = "manual-run"
}

$Environment = if ($env:ENVIRONMENT) { $env:ENVIRONMENT } else { "LOCAL" }

$RunNumber = if ($env:GITHUB_RUN_NUMBER) { $env:GITHUB_RUN_NUMBER } else { "0" }

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$Global:LogFile = Join-Path $LogFolder "$($RequestName)_$($Environment)_Run$($RunNumber)_$($TimeStamp).log"

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
    if ($Global:LogFile -and (Test-Path $LogFolder)) {
    Add-Content -Path $Global:LogFile -Value $LogEntry
    }
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

function Write-ExecutionSummary {
    param(
        [string]$Operation,
        [int]$Processed,
        [int]$Successful,
        [int]$Skipped,
        [int]$Failed,
        [datetime]$StartTime
    )

    $Duration = New-TimeSpan -Start $StartTime -End (Get-Date)

    Write-Log ""
    Write-Log "========================================="
    Write-Log "Execution Summary"
    Write-Log "========================================="
    Write-Log "Operation      : $Operation"
    Write-Log "Request File   : $($env:REQUEST_FILE)"
    Write-Log "Environment    : $($env:ENVIRONMENT)"
    Write-Log ""
    Write-Log "Processed      : $Processed"
    Write-Log "Successful     : $Successful"
    Write-Log "Skipped        : $Skipped"
    Write-Log "Failed         : $Failed"
    Write-Log ""
    Write-Log ("Duration       : {0:N2} Seconds" -f $Duration.TotalSeconds)
    Write-Log "========================================="
}


function Test-CsvColumns {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CsvPath,

        [Parameter(Mandatory)]
        [string[]]$RequiredColumns
    )

    $Csv = Import-Csv -Path $CsvPath

    if ($Csv.Count -eq 0) {
        throw "CSV file is empty."
    }

    $Headers = $Csv[0].PSObject.Properties.Name

    foreach ($Column in $RequiredColumns) {

        if ($Column -notin $Headers) {

            throw "Required column '$Column' is missing from the CSV file."

        }

    }

    Write-Log "CSV column validation successful."

}