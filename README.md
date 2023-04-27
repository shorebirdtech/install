# Shorebird (un)installer

**❗️ Note: This project is under heavy development. Things will change frequently and none of the code is ready for production use. We will do our best to keep the documentation up-to-date.**

## 🐦 Installing Shorebird

### Mac/Linux
```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | sh
```

### Windows
```powershell
powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1'|iex"
```

📚 Refer to the [Shorebird CLI documentation](https://github.com/shorebirdtech/shorebird/blob/main/packages/shorebird_cli/README.md) for more information.


## Contributing

If you're interested in contributing, please join us on
[Discord](https://discord.gg/9hKJcWGcaB).

## License

Shorebird projects are licensed for use under either Apache License, Version 2.0
(LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0) MIT license
(LICENSE-MIT or http://opensource.org/licenses/MIT) at your option.

See our license philosophy for more information on why we license files this
way:
https://github.com/shorebirdtech/handbook/blob/main/engineering.md#licensing-philosophy
