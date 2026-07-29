function Test-CsvFile {

    param(
        [string]$Path
    )

    if (!(Test-Path $Path)) {
        throw "CSV file not found: $Path"
    }

    $rows = Import-Csv $Path

    if ($rows.Count -eq 0) {
        throw "CSV file is empty."
    }

    Write-Host "$($rows.Count) record(s) loaded."
}

function Write-Log {

    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host "[$timestamp][$Level] $Message"
}