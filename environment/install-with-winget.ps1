param(
    [switch]$WhatIf,
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"

# Add more packages here by appending Name/Id pairs.
$packages = @(
    @{
        Name = "Python 3 (latest)"
        Id   = "Python.Python.3"
        # Commands are used to locate the installed executable path.
        Commands = @("python", "py")
    },
    @{
        Name = "uv"
        Id   = "Astral-sh.uv"
        Commands = @("uv")
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

function Get-WingetTableRow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    # winget list/search returns a text table, so extract the row for the package ID.
    $output = & winget $Command --id $Id --exact --source winget 2>$null | Out-String
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    $lines = $output -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match [regex]::Escape($Id)) {
            return (($line -replace "\u2026", "") -split "\s{2,}").Where({ $_ -and $_.Trim() })
        }
    }

    return $null
}

function Get-PackageExecutablePath {
    param(
        [string[]]$Commands
    )

    # Try known command names and use the first path PowerShell can resolve.
    foreach ($commandName in $Commands) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($command -and $command.Source) {
            return $command.Source
        }
    }

    return $null
}

function Get-PackageVersionInfo {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package
    )

    # Prefer the installed version, otherwise show the latest version available in winget.
    $installedRow = Get-WingetTableRow -Command "list" -Id $Package.Id
    if ($installedRow) {
        $idIndex = [Array]::IndexOf($installedRow, $Package.Id)
        if ($idIndex -ge 0 -and $installedRow.Count -gt ($idIndex + 1)) {
            return @{
                State   = "Installed"
                Version = $installedRow[$idIndex + 1]
            }
        }
    }

    $searchRow = Get-WingetTableRow -Command "search" -Id $Package.Id
    if ($searchRow) {
        $idIndex = [Array]::IndexOf($searchRow, $Package.Id)
        if ($idIndex -ge 0 -and $searchRow.Count -gt ($idIndex + 1)) {
            return @{
                State   = "NotInstalled"
                Version = $searchRow[$idIndex + 1]
            }
        }
    }

    return @{
        State   = "Unknown"
        Version = "Unknown"
    }
}

function Show-PackageStatus {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package
    )

    # Combine winget metadata and resolved command path into a readable status block.
    $versionInfo = Get-PackageVersionInfo -Package $Package
    $executablePath = Get-PackageExecutablePath -Commands $Package.Commands
    $installPath = if ($executablePath) { Split-Path -Parent $executablePath } else { "Not installed or path not detected" }

    switch ($versionInfo.State) {
        "Installed" {
            Write-Host "Installed : $($Package.Name)"
            Write-Host "Version   : $($versionInfo.Version)"
            Write-Host "Path      : $installPath"
        }
        "NotInstalled" {
            Write-Host "Not installed : $($Package.Name)"
            Write-Host "Latest      : $($versionInfo.Version)"
            Write-Host "Path        : Not installed"
        }
        default {
            Write-Host "Unknown status : $($Package.Name)"
            Write-Host "Version        : Unknown"
            Write-Host "Path           : $installPath"
        }
    }
}

foreach ($package in $packages) {
    # Show current status before deciding whether installation is needed.
    Show-PackageStatus -Package $package

    if (Test-WingetPackageInstalled -Id $package.Id) {
        Write-Host "Skipping $($package.Name) ($($package.Id)): already installed."
        Write-Host ""
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
    Show-PackageStatus -Package $package
    Write-Host ""
}

Write-Host "Done."

if (-not $NoPause) {
    # Keep the window open when the script is launched by double-click.
    Read-Host "Press Enter to exit" | Out-Null
}
