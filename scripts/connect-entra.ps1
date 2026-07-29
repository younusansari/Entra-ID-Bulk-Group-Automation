function Connect-EntraGraph {

    Write-Host ""
    Write-Host "Connecting to Microsoft Graph..."
    Write-Host ""

    $ClientId     = $env:CLIENT_ID
    $TenantId     = $env:TENANT_ID
    $ClientSecret = $env:CLIENT_SECRET

    if ([string]::IsNullOrWhiteSpace($ClientId)) {
        throw "CLIENT_ID environment variable not found."
    }

    if ([string]::IsNullOrWhiteSpace($TenantId)) {
        throw "TENANT_ID environment variable not found."
    }

    if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
        throw "CLIENT_SECRET environment variable not found."
    }

    $SecureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force

    Connect-MgGraph `
        -TenantId $TenantId `
        -ClientId $ClientId `
        -ClientSecret $SecureSecret `
        -NoWelcome

    Write-Host "Successfully connected to Microsoft Graph." -ForegroundColor Green
}