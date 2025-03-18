# Gensokyo Radio Miniplayer

A compact, cross-platform unofficial desktop player for [Gensokyo Radio](https://app.gensokyoradio.net/).

## Build

Flutter SDK must be installed prior to these build instructions. See Flutter's instructions for that [here](https://docs.flutter.dev/get-started/install). Choose your platform then "Desktop".

Clone this repository or download and extract it. In the project folder, run the following commands to setup the project.

```bash
flutter create . --platforms="windows,macos,linux"
flutter pub get
```

If using the VSCode extension, the project can be run through VSCode (ie, press F5).

To build the project in release mode:

```bash
flutter build <platforms>
```

Where `<platforms>` is either `windows`, `macos` or `linux`. The output file will be somewhere in the directory `/build/<platform>/...`, with different locations for different platform-specific build systems. For example, x64 Windows uses Visual Studio, so the executable is `/build/windows/x64/runner/Release/gr_miniplayer.exe`

### Linux

`libmpv` and `mpv` packages are required to run the project.

```bash
sudo apt install libmpv-dev mpv
```
