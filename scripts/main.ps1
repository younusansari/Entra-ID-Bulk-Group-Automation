<#
.SYNOPSIS
    Main controller for Entra ID Bulk Automation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$CsvPath
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================="
Write-Host " Entra ID Bulk Automation"
Write-Host "========================================="
Write-Host "Action    : $Action"
Write-Host "CSV File  : $CsvPath"
Write-Host "========================================="
Write-Host ""

# Import common functions
. "$ScriptRoot\Common.ps1"

# Connect to Microsoft Graph
. "$ScriptRoot\Connect-Entra.ps1"

Connect-EntraGraph

# Validate CSV
Test-CsvFile -Path $CsvPath

switch ($Action)
{
    "Add Users to Group"
    {
        . "$ScriptRoot\Add-UsersToGroup.ps1"
        Add-UsersToGroup -CsvPath $CsvPath
    }

    "Remove Users from Group"
    {
        . "$ScriptRoot\Remove-UsersFromGroup.ps1"
        Remove-UsersFromGroup -CsvPath $CsvPath
    }

    "Add Devices to Group"
    {
        . "$ScriptRoot\Add-DevicesToGroup.ps1"
        Add-DevicesToGroup -CsvPath $CsvPath
    }

    "Remove Devices from Group"
    {
        . "$ScriptRoot\Remove-DevicesFromGroup.ps1"
        Remove-DevicesFromGroup -CsvPath $CsvPath
    }

    Default
    {
        throw "Unknown action: $Action"
    }
}

Disconnect-MgGraph