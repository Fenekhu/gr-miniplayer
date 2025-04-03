# Gensokyo Radio Miniplayer

A compact, cross-platform unofficial desktop player for [Gensokyo Radio](https://app.gensokyoradio.net/).

[TODO: Insert demo video]

Contents:

- [Gensokyo Radio Miniplayer](#gensokyo-radio-miniplayer)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Show/Hide Album Art](#showhide-album-art)
    - [Login](#login)
    - [Rate/Favorite Songs](#ratefavorite-songs)
    - [Stream Quality](#stream-quality)
    - [Advanced Settings](#advanced-settings)
      - [Art Quality](#art-quality)
      - [Default Window Size](#default-window-size)
      - [Discord Rich Presence](#discord-rich-presence)
      - [Caching Pause](#caching-pause)
  - [Build](#build)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Build with Flutter](#build-with-flutter)
    - [Package with Fastforge](#package-with-fastforge)

## Installation

Compiled binaries are not currently available, but will be made available in the Releases GitHub page once ready. For now, the application must be manually built. See [build instructions](#build) below.

## Usage

### Show/Hide Album Art

If there is a specific album with art you would rather not see (looking at you, *Innocent Key*), you can blur that album's art with the visibility button in the top left corner. The art will remain blurred whenever the album comes up.

### Login

You can log in with your gensokyoradio.net credentials to enable rating and favorite buttons, as well as the Lossless stream endpoint, if you are logging in from a new IP. The login page can be accessed through the `...` settings menu in the bottom right -> Login button on top.

### Rate/Favorite Songs

Songs can be rated or favorited if you log in. Similar to the official station PWA, the stars will display blue if the song was rated in a previous year, or yellow if the song was rated this year (and your rating has been counted towards the yearly Top 100). If you see a song with blue stars, consider resubmitting your rating, the station appreciates it.

NOTE: Just like with the official PWA, you must be "connected" to the station (audio playing) to rate songs. Sometimes the station does not recognize that you are connected, or takes a few minutes, causing the rating to fail, even when listening. This is a bug present in the official PWA as well, and not specific to this application. Please wait a few minutes and try again.

### Stream Quality

In the `...` settings menu, there are four quality options provided by the station. You can select from:

- Mobile (64kbps Opus)
- Standard (128kbps MP3)
- High (256kbps MP3)
- Lossless (FLAC) (requires Indigo subscription)

### Advanced Settings

These additional settings are currently only available directly through editting the [`shared_preferences`](https://pub.dev/packages/shared_preferences) settings file. From its documentation:

| Platform | Location |
| -------- | -------- |
| Linux | XDG_DATA_HOME |
| MacOS | NSUserDefaults |
| Windows | Roaming AppData |

From there, it will most likely be in `com.fenekhu/Gensokyo Radio Miniplayer/shared_preferences.json`.

#### Art Quality

The resolution (maximum dimension for non-square images) of art to be retrieved from the station. Not all images are available at lower qualities.

Key: `art.quality`  
Values: `string`: `500` (default), `200`, `100`, `40`  
Example: `"art.quality": "500"`  

Note: Images are cached at whatever quality they are first retrieved at. The cache can be manually deleted from disk, but [`path_provider`](https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationCacheDirectory.html) doesn't make it clear where it is located on each system. On Windows, it is `%APPDATA%\Local\com.fenekhu\Gensokyo Radio Miniplayer\art`.

#### Default Window Size

The default window size to reset to after presing the Reset Window Size button in settings.

Key: `window.defaultWidth`, `window.defaultHeight`  
Values: `double`  
Example: `"window.defaultWidth": 288.0, "window.defaultHeight": 416.0`

#### Discord Rich Presence

Whether to display the current song as a discord status when listening.

Key: `discordRPC.enabled`  
Values: `bool`: `true` (default), `false`  
Example: `"discordRPC.enabled": true`  

#### Caching Pause

When true, pausing the player will stop the audio output, but continue receiving audio stream data, as if the audio had been muted instead of stopped. This can decrease loading time when playing after stopping, but is not recommended, as it maintains a connection to the station when not actively listening.  
This option is not tested, use at your own risk. The station may flag you as a illegitimate user if you remain connected for too long.

Key: `player.cachingPause`  
Values: `bool`: `true`, `false` (default)  
Example: `"player.cachingPause": false`

## Build

### Prerequisites

- Flutter SDK must be installed prior to these build instructions. See Flutter's instructions for that [here](https://docs.flutter.dev/get-started/install). Choose your platform -> Desktop.
- [Rustup](https://rustup.rs/) is required. (Required by [smtc_windows](https://pub.dev/packages/smtc_windows) and [flutter_discord_rpc](https://pub.dev/packages/flutter_discord_rpc) packages.)
- **Linux**: `libmpv-dev` and maybe `mpv` are required to build the project.

### Setup

Clone this repository or download and extract it. In the project folder, run the following commands to setup the project:

```bash
flutter create . --platforms="windows,macos,linux"
flutter pub get
```

If using the VSCode extension, the project can be run through VSCode (ie, press F5).

### Build with Flutter

The project can be built in release mode through the Flutter CLI:

```bash
flutter build <platforms>
```

Where `<platforms>` is either `windows`, `macos` or `linux`. The output file will be somewhere in the directory `/build/<platform>/...`, with different locations for different platform-specific build systems. For example, x64 Windows uses Visual Studio, so the executable is `/build/windows/x64/runner/Release/gr_miniplayer.exe`

### Package with Fastforge

The app can also be packaged through [fastforge](https://fastforge.dev/), which uses the `distribute_options.yaml` file to specify packaging formats. The configuration for each format can be found in the `[platform]/packaging/[target]/make_config.yaml` file. Each packaging format may have certain software requirements to build. Check the fastforge documentation for details.  

Fastforge can be installed like so:

```bash
dart pub global activate fastforge
```

All packages can be generated with the following single command:

```bash
fastforge release --name release
```

Alternatively, individual packages can be generated:

```bash
fastforge package --platform=windows --targets=exe,msix
```
