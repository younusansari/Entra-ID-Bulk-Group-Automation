Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================="
Write-Host " Module 02 - Get User"
Write-Host "==============================================="
Write-Host ""

# Read environment variables
$ClientId     = $env:CLIENT_ID
$TenantId     = $env:TENANT_ID
$ClientSecret = $env:CLIENT_SECRET
$UserEmail    = $env:USER_EMAIL

# Authenticate
$SecureSecret = ConvertTo-SecureString `
    $ClientSecret `
    -AsPlainText `
    -Force

$Credential = New-Object `
    System.Management.Automation.PSCredential `
    ($ClientId,$SecureSecret)

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientSecretCredential $Credential `
    -NoWelcome

Write-Host "Searching for user..."
Write-Host ""

try {

    $User = Get-MgUser `
        -UserId $UserEmail

}
catch {

    Write-Host ""
    Write-Host "==============================================="
    Write-Host "User Lookup Result"
    Write-Host "==============================================="
    Write-Host ""

    Write-Host "Status        : Failed"
    Write-Host "User Email    : $UserEmail"
    Write-Host "Reason        : User not found"

    Disconnect-MgGraph

    exit 1
}

Write-Host ""
Write-Host "==============================================="
Write-Host "User Information"
Write-Host "==============================================="
Write-Host ""

Write-Host ("{0,-20}: {1}" -f "Status","Success")
Write-Host ("{0,-20}: {1}" -f "Display Name",$User.DisplayName)
Write-Host ("{0,-20}: {1}" -f "Email",$User.Mail)
Write-Host ("{0,-20}: {1}" -f "UPN",$User.UserPrincipalName)
Write-Host ("{0,-20}: {1}" -f "Object ID",$User.Id)
Write-Host ("{0,-20}: {1}" -f "Account Enabled",$User.AccountEnabled)

Disconnect-MgGraph