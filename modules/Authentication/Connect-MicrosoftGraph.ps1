<#
.SYNOPSIS
    Module 01 - Microsoft Graph Authentication

.DESCRIPTION
    Connects to Microsoft Graph using
    App Registration Client Secret authentication.

.AUTHOR
    Younus Ansari

.VERSION
    1.0
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================================="
Write-Host " Module 01 - Microsoft Graph Authentication"
Write-Host "==========================================================="
Write-Host ""

#------------------------------------------------------------
# Read Environment Variables
#------------------------------------------------------------

$ClientId     = $env:CLIENT_ID
$TenantId     = $env:TENANT_ID
$ClientSecret = $env:CLIENT_SECRET

#------------------------------------------------------------
# Validate Variables
#------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($ClientId)) {
    throw "CLIENT_ID is missing."
}

if ([string]::IsNullOrWhiteSpace($TenantId)) {
    throw "TENANT_ID is missing."
}

if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
    throw "CLIENT_SECRET is missing."
}

Write-Host "✓ Environment variables validated."
Write-Host ""

#------------------------------------------------------------
# Import Module
#------------------------------------------------------------

Import-Module Microsoft.Graph.Authentication

Write-Host "✓ Microsoft Graph Authentication module loaded."
Write-Host ""

#------------------------------------------------------------
# Convert Secret
#------------------------------------------------------------

$SecureSecret = ConvertTo-SecureString `
    $ClientSecret `
    -AsPlainText `
    -Force

#------------------------------------------------------------
# Create PSCredential
#------------------------------------------------------------

$Credential = New-Object System.Management.Automation.PSCredential(
    $ClientId,
    $SecureSecret
)

#------------------------------------------------------------
# Connect
#------------------------------------------------------------

Write-Host "Connecting to Microsoft Graph..."

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientSecretCredential $Credential `
    -NoWelcome

Write-Host "✓ Connected successfully."
Write-Host ""

#------------------------------------------------------------
# Context
#------------------------------------------------------------

$Context = Get-MgContext

Write-Host "==========================================================="
Write-Host " Microsoft Graph Context"
Write-Host "==========================================================="
Write-Host ""

Write-Host ("{0,-20}: {1}" -f "Status","Connected")
Write-Host ("{0,-20}: {1}" -f "Tenant ID",$Context.TenantId)
Write-Host ("{0,-20}: {1}" -f "Client ID",$Context.ClientId)
Write-Host ("{0,-20}: {1}" -f "Auth Type",$Context.AuthType)
Write-Host ("{0,-20}: {1}" -f "Graph Cloud",$Context.Environment)

Write-Host ""

Disconnect-MgGraph

Write-Host "✓ Disconnected."
Write-Host ""
Write-Host "Module completed successfully."