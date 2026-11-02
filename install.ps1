$ErrorActionPreference = "Stop"

$installDirectory = [IO.Path]::Combine($home, ".shorebird")

function Test-GitInstalled {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Debug "Git is installed."
    }
    else {
        throw "No git installation detected. Git is required to use shorebird."
    }
}

function Compare-GitVersions {
    param (
        [string]$version1,
        [string]$version2
    )

    $version1Components = $version1 -split '\.'
    $version2Components = $version2 -split '\.'

    for ($i = 0; $i -lt 3; $i++) {
        $version1Number = [int]$version1Components[$i]
        $version2Number = [int]$version2Components[$i]

        if ($version1Number -lt $version2Number) {
            return -1
        }
        elseif ($version1Number -gt $version2Number) {
            return 1
        }
    }

    return 0
}

function Test-GitVersion {
    $minGitVersion = "2.25.1"
    $gitVersion = (Get-Item (Get-Command git).Source).VersionInfo.ProductVersionRaw
    $comparisonResult = Compare-GitVersions -version1 $gitVersion -version2 $minGitVersion
    if ($comparisonResult -eq -1) {
        throw "Installed git version $gitVersion is older than required git version $minGitVersion."
    }
}

function Update-Path {
    $path = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($path.contains($installDirectory)) {
        return $false
    }
    $binPath = [IO.Path]::Combine($installDirectory, "bin")
    [Environment]::SetEnvironmentVariable(
        "Path", $path + [IO.Path]::PathSeparator + $binPath, "User"
    )

    return $true
}

Test-GitInstalled
Test-GitVersion

$force = $args -contains "--force"

if (Test-Path $installDirectory) {
    if ($force) {
        Write-Output "Existing Shorebird installation detected. Overwriting..."
        Remove-Item -Recurse -Force $installDirectory
    }
    else {
        # Not an error: setup-shorebird reruns this on persistent runners and
        # uses the existing install.
        $reinstall = @"
To delete it and install again, run:

  Remove-Item -Recurse -Force "$installDirectory"
  irm https://shorebird.dev/install.ps1 | iex
"@
        if (Test-Path ([IO.Path]::Combine($installDirectory, "bin", "cache", "shorebird.snapshot"))) {
            Write-Output @"
Shorebird is already installed at $installDirectory.

To update it, run:

  shorebird upgrade

$reinstall
"@
        }
        else {
            Write-Output @"
A previous Shorebird install at $installDirectory is incomplete.

$reinstall
"@
        }
        return
    }
}

# A fresh install (Shorebird, Flutter and the Dart SDK) measured about 2.2GB.
$minFreeBytes = 3GB
try {
    $freeBytes = (New-Object IO.DriveInfo ([IO.Path]::GetPathRoot($installDirectory))).AvailableFreeSpace
}
catch {
    # Not a local drive (e.g. a UNC profile path); skip the check.
    $freeBytes = $null
}
if ($null -ne $freeBytes -and $freeBytes -lt $minFreeBytes) {
    $freeMB = [math]::Floor($freeBytes / 1MB)
    throw "Not enough disk space to install Shorebird. Shorebird needs 3GB free on $([IO.Path]::GetPathRoot($installDirectory)); $($freeMB)MB is free."
}

Write-Output "Installing Shorebird to $installDirectory..."

# If the install fails partway (a dropped connection, a full disk, Ctrl-C),
# remove what was installed so running the installer again starts clean.
# This is in finally, not catch, because Ctrl-C skips catch.
$installComplete = $false
try {
    & git clone https://github.com/shorebirdtech/shorebird.git -b stable $installDirectory
    if ($LASTEXITCODE -ne 0) { throw "git clone failed." }

    Push-Location $installDirectory\bin
    try {
        & .\shorebird.ps1 --version
        if ($LASTEXITCODE -ne 0) { throw "shorebird --version failed." }
    }
    finally {
        Pop-Location
    }
    $installComplete = $true
}
finally {
    if (-not $installComplete -and (Test-Path $installDirectory)) {
        Remove-Item -Recurse -Force $installDirectory -ErrorAction SilentlyContinue
        if (Test-Path $installDirectory) {
            Write-Host -ForegroundColor Red "Shorebird installation did not finish. Delete $installDirectory, then run the installer again."
        }
        else {
            Write-Host -ForegroundColor Red "Shorebird installation did not finish. Removed the partial install at $installDirectory. Run the installer again (after fixing any error above)."
        }
    }
}

$wasPathUpdated = Update-Path
# 1F426 is the code for 🐦. See https://unicode.org/emoji/charts/full-emoji-list.html#1f426.
$birdEmoji = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F426", 16))

Write-Output @"

$birdEmoji Shorebird has been installed!

"@

if ($wasPathUpdated) {
    Write-Output @"
Please restart your terminal to start using Shorebird.
"@
}

Write-Output @"
To create an account, visit: https://console.shorebird.dev
Then login using:

  shorebird login

For more information, visit:
https://docs.shorebird.dev
"@
