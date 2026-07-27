<#
.SYNOPSIS
    Connects to Microsoft Graph using App Registration.

.DESCRIPTION
    Authenticates to Microsoft Graph using the Microsoft Graph
    PowerShell SDK and validates the connection.

.AUTHOR
    Younus Ansari

.VERSION
    1.0
#>

#------------------------------------------------------------
# Script Configuration
#------------------------------------------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#------------------------------------------------------------
# Banner
#------------------------------------------------------------
Write-Host ""
Write-Host "==========================================================="
Write-Host " Module 01 - Microsoft Graph Authentication"
Write-Host "==========================================================="
Write-Host ""

#------------------------------------------------------------
# Read GitHub Secrets
#------------------------------------------------------------
$ClientId     = $env:CLIENT_ID
$TenantId     = $env:TENANT_ID
$ClientSecret = $env:CLIENT_SECRET

#------------------------------------------------------------
# Validate Environment Variables
#------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($ClientId)) {
    throw "CLIENT_ID environment variable is missing."
}

if ([string]::IsNullOrWhiteSpace($TenantId)) {
    throw "TENANT_ID environment variable is missing."
}

if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
    throw "CLIENT_SECRET environment variable is missing."
}

Write-Host "✓ Environment variables validated."
Write-Host ""

#------------------------------------------------------------
# Install Graph SDK (if required)
#------------------------------------------------------------
if (-not (Get-Module -ListAvailable Microsoft.Graph.Authentication))
{
    Write-Host "Installing Microsoft Graph Authentication module..."

    Install-Module Microsoft.Graph.Authentication `
        -Scope CurrentUser `
        -Force
}

Import-Module Microsoft.Graph.Authentication

Write-Host "✓ Microsoft Graph SDK loaded."
Write-Host ""

#------------------------------------------------------------
# Create Credential Object
#------------------------------------------------------------
$SecureSecret = ConvertTo-SecureString `
    $ClientSecret `
    -AsPlainText `
    -Force

$Credential = New-Object `
    System.Management.Automation.PSCredential `
    ($ClientId, $SecureSecret)

#------------------------------------------------------------
# Connect to Microsoft Graph
#------------------------------------------------------------
Write-Host "Connecting to Microsoft Graph..."

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientSecretCredential $Credential `
    -NoWelcome

Write-Host "✓ Connected successfully."
Write-Host ""

#------------------------------------------------------------
# Retrieve Graph Context
#------------------------------------------------------------
$Context = Get-MgContext

#------------------------------------------------------------
# Display Connection Information
#------------------------------------------------------------
Write-Host "==========================================================="
Write-Host " Microsoft Graph Connection Information"
Write-Host "==========================================================="
Write-Host ""

Write-Host ("{0,-20}: {1}" -f "Status","Connected")
Write-Host ("{0,-20}: {1}" -f "Tenant ID",$Context.TenantId)
Write-Host ("{0,-20}: {1}" -f "Client ID",$Context.ClientId)
Write-Host ("{0,-20}: {1}" -f "Auth Type",$Context.AuthType)
Write-Host ("{0,-20}: {1}" -f "Graph Cloud",$Context.Environment)

Write-Host ""

#------------------------------------------------------------
# Disconnect
#------------------------------------------------------------
Disconnect-MgGraph

Write-Host "✓ Disconnected from Microsoft Graph."
Write-Host ""
Write-Host "Module completed successfully."