<#
.SYNOPSIS
    Main entry point for Entra ID Bulk User Device Automation.

.DESCRIPTION
    Orchestrates the execution of bulk Entra ID operations by:
      - Validating parameters
      - Loading common functions
      - Connecting to Microsoft Graph
      - Executing the selected operation
      - Disconnecting from Microsoft Graph

.PARAMETER Operation
    Operation selected from the GitHub Actions workflow.

.PARAMETER CsvPath
    Full path to the request CSV file.

.PARAMETER DryRun
    Yes or No.

.EXAMPLE
    ./scripts/main.ps1 `
        -Operation "Add Users to Group" `
        -CsvPath "./csv/pending/finance-users.csv" `
        -DryRun "No"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Operation,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CsvPath,

    [Parameter(Mandatory)]
    [ValidateSet("Yes","No")]
    [string]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $PSCommandPath

try {

    Write-Host ""
    Write-Host "==========================================="
    Write-Host " Entra ID Bulk User Device Automation"
    Write-Host "==========================================="
    Write-Host "Operation    : $Operation"
    Write-Host "Request File : $CsvPath"
    Write-Host "Dry Run      : $DryRun"
    Write-Host "==========================================="
    Write-Host ""

    # Import shared functions
    . "$ScriptRoot/common.ps1"

    # Import Graph authentication
    . "$ScriptRoot/connect-entra.ps1"

    # Validate request file
    Test-CsvFile -Path $CsvPath

    # Connect to Microsoft Graph
    Connect-EntraGraph

    switch ($Operation)
    {
        "Add Users to Group" {

            . "$ScriptRoot/add-users-to-group.ps1"

            Add-UsersToGroup `
                -CsvPath $CsvPath `
                -DryRun $DryRun
        }

        "Remove Users from Group" {

            . "$ScriptRoot/remove-users-from-group.ps1"

            Remove-UsersFromGroup `
                -CsvPath $CsvPath `
                -DryRun $DryRun
        }

        "Add Devices to Group" {

            . "$ScriptRoot/add-devices-to-group.ps1"

            Add-DevicesToGroup `
                -CsvPath $CsvPath `
                -DryRun $DryRun
        }

        "Remove Devices from Group" {

            . "$ScriptRoot/remove-devices-to-group.ps1"

            Remove-DevicesFromGroup `
                -CsvPath $CsvPath `
                -DryRun $DryRun
        }

        default {

            throw "Unsupported operation: $Operation"
        }
    }

}
catch {

    Write-Host ""
    Write-Host "Automation failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    throw
}
finally {

    Disconnect-EntraGraph

}