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
        Id   = "astral-sh.uv"
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
    $output = winget list --id $Id --exact --source winget --disable-interactivity 2>$null | Out-String
    return $LASTEXITCODE -eq 0 -and $output -match [regex]::Escape($Id)
}

function Refresh-PathEnvironment {
    # Reload PATH from user and machine scope so newly installed shims resolve immediately.
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = @($userPath, $machinePath) -join ";"
}

function Get-WingetPackageRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    # winget list/search returns a text table, so extract the row for the package ID.
    $output = & winget $Command --id $Id --exact --source winget --disable-interactivity 2>$null | Out-String
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    $lines = $output -split "`r?`n"
    foreach ($line in $lines) {
        $trimmedLine = $line.Trim()
        if ($trimmedLine -and -not $trimmedLine.StartsWith("Name ") -and -not $trimmedLine.StartsWith("---")) {
            $parts = $trimmedLine -split '\s+'
            if ($parts.Count -ge 3 -and $parts[$parts.Count - 2] -eq $Id) {
                return @{
                    Name = ($parts[0..($parts.Count - 3)] -join " ")
                    Id = $parts[$parts.Count - 2]
                    Version = $parts[$parts.Count - 1]
                }
            }
        }
    }

    return $null
}

function Get-PackageExecutablePath {
    param(
        [string[]]$Commands,
        [string]$PackageId
    )

    # Try known command names and use the first path PowerShell can resolve.
    foreach ($commandName in $Commands) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($command -and $command.Source) {
            return $command.Source
        }
    }

    # Fall back to the WinGet package cache when PATH has not been refreshed yet.
    if ($PackageId) {
        foreach ($commandName in $Commands) {
            $packageRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
            $candidate = Get-ChildItem $packageRoot -Directory -Filter "$PackageId*" -ErrorAction SilentlyContinue |
                ForEach-Object { Join-Path $_.FullName "$commandName.exe" } |
                Where-Object { Test-Path $_ } |
                Select-Object -First 1

            if ($candidate) {
                return $candidate
            }
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
    $installedRecord = Get-WingetPackageRecord -Command "list" -Id $Package.Id
    if ($installedRecord) {
        return @{
            State   = "Installed"
            Version = $installedRecord.Version
        }
    }

    $searchRecord = Get-WingetPackageRecord -Command "search" -Id $Package.Id
    if ($searchRecord) {
        return @{
            State   = "NotInstalled"
            Version = $searchRecord.Version
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
    $executablePath = Get-PackageExecutablePath -Commands $Package.Commands -PackageId $Package.Id
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
    Refresh-PathEnvironment
    Show-PackageStatus -Package $package
    Write-Host ""
}

Write-Host "Done."

if (-not $NoPause) {
    # Keep the window open when the script is launched by double-click.
    Read-Host "Press Enter to exit" | Out-Null
}
