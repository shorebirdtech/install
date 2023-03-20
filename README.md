# Shorebird (un)installer

**❗️ Note: This project is under heavy development. Things will change frequently and none of the code is ready for production use. We will do our best to keep the documentation up-to-date.**

## Getting Started 🚀

1. 🔑 Request an API Key (coming soon...)
1. 🐦 Install the Shorebird CLI

   ```
   # Clone Shorebird
   git clone https://github.com/shorebirdtech/shorebird

   # Activate the Shorebird CLI
   dart pub global activate --source path shorebird/packages/shorebird_cli
   ```

1. 🔐 Login

   ```bash
   shorebird login
   ? Please enter your API Key: <API-KEY>
   ✓ Logging into shorebird.dev (7ms)
   You are now logged in.
   ```

1. ✨ Initialize Shorebird

   ```bash
   # Initialize shorebird in the current directory.
   # This will generate a `shorebird.yaml` configuration file.
   shorebird init
   ```

1. 📱 Create a new app

   ```bash
   shorebird apps create
   ```

1. 📦 Create a new build

   ```bash
   shorebird build
   ```

   **❗️Note**: If it's the first time, `shorebird` will download and build the shorebird engine which may take some time. The shorebird engine will be cached for subsequent runs.

1. ☁️ Publish a new release

   ```bash
   shorebird publish
   ```

That's it 🎉

Once a new release has been published, all applications will automatically update the next time they are launched.

View all apps and their latest releases and patches using the `shorebird apps list` command:

```
shorebird apps list
my_counter: v1.0.0 (patch #1)
my_example: v2.1.0 (patch #2)
```

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
