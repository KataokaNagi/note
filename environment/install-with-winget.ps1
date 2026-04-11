param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget was not found. Please install App Installer from Microsoft Store first."
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $output = winget list --id $Id --exact --source winget 2>$null | Out-String
    return $LASTEXITCODE -eq 0 -and $output -match [regex]::Escape($Id)
}

$packages = @(
    @{
        Name = "Python 3"
        Id   = "Python.Python.3.13"
    }
)

foreach ($package in $packages) {
    if (Test-WingetPackageInstalled -Id $package.Id) {
        Write-Host "Skipping $($package.Name) ($($package.Id)): already installed."
        continue
    }

    $args = @(
        "install"
        "--id", $package.Id
        "--exact"
        "--source", "winget"
        "--accept-source-agreements"
        "--accept-package-agreements"
    )

    if ($WhatIf) {
        Write-Host "[WhatIf] winget $($args -join ' ')"
        continue
    }

    Write-Host "Installing $($package.Name) ($($package.Id))..."
    winget @args
}

Write-Host "Done."
