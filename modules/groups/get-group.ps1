<#
.SYNOPSIS
    Module 03 - Get Group

.DESCRIPTION
    Connects to Microsoft Graph using App Registration
    Client Secret authentication and retrieves an Entra ID
    Group by Display Name.

.AUTHOR
    Younus Ansari

.VERSION
    1.0
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================================="
Write-Host " Module 03 - Get Group"
Write-Host "==========================================================="
Write-Host ""

#------------------------------------------------------------
# Read Environment Variables
#------------------------------------------------------------

$ClientId     = $env:CLIENT_ID
$TenantId     = $env:TENANT_ID
$ClientSecret = $env:CLIENT_SECRET
$GroupName    = $env:GROUP_NAME

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

if ([string]::IsNullOrWhiteSpace($GroupName)) {
    throw "GROUP_NAME environment variable is missing."
}

Write-Host "✓ Environment variables validated."
Write-Host ""

#------------------------------------------------------------
# Import Microsoft Graph Module
#------------------------------------------------------------

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Groups

Write-Host "✓ Microsoft Graph modules loaded."
Write-Host ""

#------------------------------------------------------------
# Authenticate
#------------------------------------------------------------

$SecureSecret = ConvertTo-SecureString `
    $ClientSecret `
    -AsPlainText `
    -Force

$Credential = New-Object System.Management.Automation.PSCredential(
    $ClientId,
    $SecureSecret
)

Write-Host "Connecting to Microsoft Graph..."

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientSecretCredential $Credential `
    -NoWelcome

Write-Host "✓ Connected successfully."
Write-Host ""

#------------------------------------------------------------
# Search Group
#------------------------------------------------------------

Write-Host "Searching for Group..."
Write-Host "Group Name : $GroupName"
Write-Host ""

try {

    $Group = Get-MgGroup `
        -Filter "displayName eq '$GroupName'"

}
catch {

    Disconnect-MgGraph

    throw "Microsoft Graph query failed.`n$($_.Exception.Message)"

}

if (-not $Group)
{
    Disconnect-MgGraph
    throw "Group '$GroupName' was not found."
}

$Group = @($Group)

if ($Group.Count -gt 1)
{
    Disconnect-MgGraph
    throw "Multiple groups found with display name '$GroupName'."
}

$Group = $Group[0]

#------------------------------------------------------------
# Display Group Information
#------------------------------------------------------------

Write-Host "==========================================================="
Write-Host " Group Information"
Write-Host "==========================================================="
Write-Host ""

Write-Host ("{0,-25}: {1}" -f "Display Name",      $Group.DisplayName)
Write-Host ("{0,-25}: {1}" -f "Object ID",         $Group.Id)
Write-Host ("{0,-25}: {1}" -f "Mail Enabled",      $Group.MailEnabled)
Write-Host ("{0,-25}: {1}" -f "Security Enabled",  $Group.SecurityEnabled)
Write-Host ("{0,-25}: {1}" -f "Mail Nickname",     $Group.MailNickname)

Write-Host ""

#------------------------------------------------------------
# Disconnect
#------------------------------------------------------------

Disconnect-MgGraph

Write-Host "✓ Disconnected."
Write-Host ""
Write-Host "Module completed successfully."

return $Group