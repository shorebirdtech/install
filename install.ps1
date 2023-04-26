$installDirectory = [IO.Path]::Combine($home, ".shorebird")

if (Test-Path $installDirectory) {
    Write-Output "Shorebird is already installed."
    return
}

Write-Output "Installing Shorebird to $installDirectory..."

# & git clone https://github.com/shorebirdtech/shorebird.git -b stable $installDirectory
& git clone https://github.com/shorebirdtech/shorebird.git -b bo/flutter-batch-files $installDirectory

Push-Location $installDirectory\bin
& .\shorebird.ps1 --version
Pop-Location

Write-Output @"
🐦 Shorebird has been installed!"

To get started, add $installDirectory\bin to your PATH environment variable and run the following command:

shorebird --help

For more information, visit:
https://github.com/shorebirdtech/shorebird/blob/main/TRUSTED_TESTERS.md.
"@
