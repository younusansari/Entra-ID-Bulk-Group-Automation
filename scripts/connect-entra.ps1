<#
.SYNOPSIS
    Connects to Microsoft Graph using a Service Principal.

.DESCRIPTION
    Authenticates to Microsoft Graph using the credentials supplied
    through GitHub Actions environment variables.

    Required Environment Variables:
        CLIENT_ID
        TENANT_ID
        CLIENT_SECRET

.NOTES
    Author  : Younus Ansari
    Project : Entra ID Bulk User Device Automation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Connect-EntraGraph {

    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "======================================="
    Write-Host " Microsoft Graph Authentication"
    Write-Host "======================================="
    Write-Host ""

    # Read GitHub Environment Variables
    $ClientId     = $env:CLIENT_ID
    $TenantId     = $env:TENANT_ID
    $ClientSecret = $env:CLIENT_SECRET

    # Validate Environment Variables
    if ([string]::IsNullOrWhiteSpace($ClientId)) {
        throw "CLIENT_ID environment variable is missing."
    }

    if ([string]::IsNullOrWhiteSpace($TenantId)) {
        throw "TENANT_ID environment variable is missing."
    }

    if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
        throw "CLIENT_SECRET environment variable is missing."
    }

    try {

        Write-Host "Connecting to Microsoft Graph..."

        $SecureClientSecret = ConvertTo-SecureString `
            -String $ClientSecret `
            -AsPlainText `
            -Force

        Connect-MgGraph `
            -TenantId $TenantId `
            -ClientId $ClientId `
            -ClientSecret $SecureClientSecret `
            -NoWelcome

        # Verify connection
        $Context = Get-MgContext

        if ($null -eq $Context) {
            throw "Unable to verify Microsoft Graph connection."
        }

        Write-Host ""
        Write-Host "Connected Successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "Tenant ID : $($Context.TenantId)"
        Write-Host "Client ID : $($Context.ClientId)"
        Write-Host "Auth Type : App Registration"
        Write-Host ""

    }
    catch {

        Write-Host ""
        Write-Host "Microsoft Graph authentication failed." -ForegroundColor Red

        throw $_
    }
}

function Disconnect-EntraGraph {

    [CmdletBinding()]
    param()

    try {

        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null

        Write-Host ""
        Write-Host "Disconnected from Microsoft Graph."

    }
    catch {

    Write-Warning "Unable to disconnect from Microsoft Graph."

    }

}