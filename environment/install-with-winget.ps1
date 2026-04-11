param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# Add more packages here by appending Name/Id pairs.
$packages = @(
    @{
        Name = "Python 3 (latest)"
        Id   = "Python.Python.3"
    },
    @{
        Name = "uv"
        Id   = "Astral-sh.uv"
    }
)

# App Installer provides winget on current Windows builds.
$appInstallerStoreUrl = "https://apps.microsoft.com/detail/9nblggh4nns1?hl=ja-JP&gl=JP"
$appInstallerDownloadUrl = "https://aka.ms/getwinget"

function Install-AppInstaller {
    param(
        [switch]$WhatIf
    )

    if (Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue) {
        Write-Host "App Installer is already installed."
        return
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Download App Installer from $appInstallerDownloadUrl"
        Write-Host "[WhatIf] Install App Installer package with Add-AppxPackage"
        return
    }

    # Download to a temp file so it can be installed with Add-AppxPackage.
    $tempFile = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller.msixbundle"

    try {
        Write-Host "Downloading App Installer..."
        Invoke-WebRequest -Uri $appInstallerDownloadUrl -OutFile $tempFile

        Write-Host "Installing App Installer..."
        Add-AppxPackage -Path $tempFile
    }
    catch {
        # Fall back to the Store page when direct package installation is blocked.
        Write-Warning "Automatic App Installer installation failed. Opening Microsoft Store page instead."
        Start-Process $appInstallerStoreUrl
        throw
    }
    finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    # Bootstrap winget by installing App Installer when it is missing.
    Write-Host "winget was not found. Trying to install App Installer..."
    Install-AppInstaller -WhatIf:$WhatIf
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget was not found after App Installer setup. Open the Microsoft Store page and complete the installation if needed: $appInstallerStoreUrl"
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    # winget list is used as a precheck so already-installed packages are skipped.
    $output = winget list --id $Id --exact --source winget 2>$null | Out-String
    return $LASTEXITCODE -eq 0 -and $output -match [regex]::Escape($Id)
}

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
