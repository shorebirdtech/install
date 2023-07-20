$installDirectory = [IO.Path]::Combine($home, ".shorebird")

function Test-GitInstalled {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Debug "Git is installed."
    } else {
        Write-Output "No git installation detected. Git is required to use shorebird."
        exit 1
    }
}

function Compare-SemVer {
    param (
        [string]$Version1,
        [string]$Version2
    )

    function Parse-SemVer {
        param (
            [string]$Version
        )
    
        $versionPattern = '^(\d+)\.(\d+)\.(\d+)(?:-([\w.-]+))?(?:\+([\w.-]+))?$'
        if ($Version -match $versionPattern) {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            $patch = [int]$Matches[3]
            $preRelease = $Matches[4]
            $buildMetadata = $Matches[5]
    
            [PSCustomObject]@{
                Major = $major
                Minor = $minor
                Patch = $patch
                PreRelease = $preRelease
                BuildMetadata = $buildMetadata
            }
        }
        else {
            Write-Host "Invalid version format: $Version"
            return $null
        }
    }
    
    $ver1 = Parse-SemVer -Version $Version1
    $ver2 = Parse-SemVer -Version $Version2
    
    if ($ver1 -eq $null -or $ver2 -eq $null) {
        Write-Host "Unable to compare versions. Please ensure both versions are in SemVer format."
        return
    }

    if ($ver1.Major -gt $ver2.Major) {
        return 1
    }
    elseif ($ver1.Major -lt $ver2.Major) {
        return -1
    }
    
    if ($ver1.Minor -gt $ver2.Minor) {
        return 1
    }
    elseif ($ver1.Minor -lt $ver2.Minor) {
        return -1
    }
    
    if ($ver1.Patch -gt $ver2.Patch) {
        return 1
    }
    elseif ($ver1.Patch -lt $ver2.Patch) {
        return -1
    }
    
    # If both versions are equal up to this point, check for pre-release versions
    if ($ver1.PreRelease -and !$ver2.PreRelease) {
        return -1
    }
    elseif (!$ver1.PreRelease -and $ver2.PreRelease) {
        return 1
    }
    elseif ($ver1.PreRelease -and $ver2.PreRelease) {
        $preComp = [System.StringComparer]::OrdinalIgnoreCase.Compare($ver1.PreRelease, $ver2.PreRelease)
        if ($preComp -ne 0) {
            return $preComp
        }
    }
    
    return 0
}

function Test-GitVersion {
    $minGitVersion = "2.37.1"
    $gitVersion = (Get-Command git).FileVersionInfo.ProductVersion

    $comparisonResult = Compare-SemVer -version1 $gitVersion -version2 $minGitVersion
    if ($comparisonResult -eq -1) {
        Write-Output "Installed version $installedVersion is older than required version $requiredVersion."
        exit 1
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
    } else {
        Write-Output "Error: Existing Shorebird installation detected. Use --force to overwrite."
        return
    }
}

Write-Output "Installing Shorebird to $installDirectory..."

& git clone https://github.com/shorebirdtech/shorebird.git -b stable $installDirectory

Push-Location $installDirectory\bin
& .\shorebird.ps1 --version
Pop-Location

$wasPathUpdated = Update-Path
# 1F426 is the code for 🐦. See https://unicode.org/emoji/charts/full-emoji-list.html#1f426.
$birdEmoji = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F426",16))

Write-Output @"

$birdEmoji Shorebird has been installed!

"@

if ($wasPathUpdated) {
    Write-Output @"
Please restart your terminal to start using Shorebird.
"@
}

Write-Output @"
To get started, run the following command:

shorebird --help

For more information, visit https://docs.shorebird.dev
"@
