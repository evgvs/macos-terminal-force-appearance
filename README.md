# macos-terminal-force-appearance

![Dark Terminal and Light Terminal demo](demo.png)

Add the "Dark Terminal" and "Light Terminal" apps to macOS. The title bars of these apps will remain dark or light, respectively, regardless of the system appearance.

## Installation:

> [!NOTE]
> Xcode Command Line Tools are required to build the shared library.
>
> ```sh
> xcode-select --install
> ```

```sh
# Install both "Dark Terminal" and "Light Terminal"
./install.sh
```

```sh
# Install "Light Terminal" only
./install.sh light
```

```sh
# Install "Dark Terminal" only
./install.sh dark
```

Apps will be installed to `~/Applications`.

## How it works

This tweak creates a separate copy of macOS Terminal.app and injects a small dynamic library (`.dylib`) into it using `DYLD_INSERT_LIBRARIES`. The library runs inside Terminal's process and uses AppKit's `NSAppearance` API to explicitly set the application's appearance to `NSAppearanceNameDarkAqua` (dark) or `NSAppearanceNameAqua` (light), overriding the appearance normally inherited from macOS.

Because system applications normally restrict this kind of library injection, the copied Terminal bundle is ad-hoc re-signed; the original `/System/Applications/Utilities/Terminal.app` is never modified.
