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
      - [Caching Pause](#caching-pause)
      - [TODO: Default Window Size](#todo-default-window-size)
  - [Build](#build)
    - [Linux](#linux)

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
- High (256kbps MP#)
- Lossless (FLAC) (requires Indigo subscription)

### Advanced Settings

These additional settings are currently only available directly through editting the [`shared_preferences`](https://pub.dev/packages/shared_preferences) settings file. From its documentation:

| Platform | Location |
| -------- | -------- |
| Linux | XDG_DATA_HOME |
| MacOS | NSUserDefaults |
| Windows | Roaming AppData |

From there, it will most likely be in `com.fenekhu/gr_miniplayer/shared_preferences.json`.

#### Art Quality

The resolution (maximum dimension for non-square images) of art to be retrieved from the station.  

Key: `art.quality`  
Values: `string`: `500` (default), `200`, `100`, `40`  
Example: `"art.quality": "500"`  

#### Caching Pause

When true, pausing the player will stop the audio output, but continue receiving audio stream data, as if the audio had been muted instead of stopped. This can decrease loading time when playing after stopping, but is not recommended, as it maintains a connection to the station when not actively listening.  
This option is not tested, use at your own risk. The station may flag you as a illegitimate user if you remain connected for too long.

Key: `player.cachingPause`  
Values: `bool`: `true`, `false` (default)  
Example: `"player.cachingPause": false`

#### TODO: Default Window Size

The default window size to reset to after presing the Reset Window Size button in settings.

NOTE: This is not yet implemented.

Key: `window.defaultWidth`, `window.defaultHeight`  
Values: `double`  
Example: `"window.defaultWidth": 288.0, "window.defaultHeight": 416.0`

## Build

Flutter SDK must be installed prior to these build instructions. See Flutter's instructions for that [here](https://docs.flutter.dev/get-started/install). Choose your platform -> Desktop.

Clone this repository or download and extract it. In the project folder, run the following commands to setup the project:

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

`libmpv` and `mpv` packages are required to build the project.

```bash
sudo apt install libmpv-dev mpv
```
