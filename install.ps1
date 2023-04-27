$installDirectory = [IO.Path]::Combine($home, ".shorebird")

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

if (Test-Path $installDirectory) {
    Write-Output "Shorebird is already installed."
    return
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
