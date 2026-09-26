#!/usr/bin/env zsh
set -e

build_light() {
    clang -arch arm64e -dynamiclib -fblocks -framework Cocoa -DLIGHT_THEME -o "ForceLight.dylib" "ForceAppearance.m"
}

build_dark() {
    clang -arch arm64e -dynamiclib -fblocks -framework Cocoa -o "ForceDark.dylib" "ForceAppearance.m"
}

install_dark() {
    echo -e "\033[1m🌃 Installing Dark Terminal\e[0m"
    echo -e "⚙️  Compiling Dark dylib payload"
    build_dark

    DARK_TERMINAL_PATH="$HOME/Applications/Dark Terminal.app"

    if [[ -e "$DARK_TERMINAL_PATH" ]]; then
        printf "Dark Terminal already exists. Reinstall it? [Y/n] "
        read -r answer

        case "$answer" in
            ""|[yY])
                rm -rf "$DARK_TERMINAL_PATH"
                ;;
            [nN])
                return 0
                ;;
            *)
                echo "Invalid response."
                return 1
                ;;
        esac
    fi

    echo -e "📂 Duplicating Terminal.app"

    mkdir -p "$HOME/Applications"
    cp -R /System/Applications/Utilities/Terminal.app "$DARK_TERMINAL_PATH"

    mkdir -p "$DARK_TERMINAL_PATH/Contents/Frameworks"
    cp "ForceDark.dylib" "$DARK_TERMINAL_PATH/Contents/Frameworks/"

    mv "$DARK_TERMINAL_PATH/Contents/MacOS/Terminal" "$DARK_TERMINAL_PATH/Contents/MacOS/Terminal.real"

    cat > "$DARK_TERMINAL_PATH/Contents/MacOS/Terminal" <<'EOF'
#!/bin/zsh

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_CONTENTS="$(dirname "$HERE")"

export DYLD_INSERT_LIBRARIES="$APP_CONTENTS/Frameworks/ForceDark.dylib"

exec "$HERE/Terminal.real" "$@"
EOF

    chmod +x "$DARK_TERMINAL_PATH/Contents/MacOS/Terminal"

    echo -e "✍️  Signing"
    codesign --force --deep --sign - "$DARK_TERMINAL_PATH"

    echo -e "\033[1m✅ Dark Terminal installed\e[0m to \"$DARK_TERMINAL_PATH\""
}

install_light() {
    echo -e "\033[1m🌃 Installing Light Terminal\e[0m"
    echo -e "⚙️  Compiling Light dylib payload"
    build_light

    LIGHT_TERMINAL_PATH="$HOME/Applications/Light Terminal.app"

    if [[ -e "$LIGHT_TERMINAL_PATH" ]]; then
        printf "Light Terminal already exists. Reinstall it? [Y/n] "
        read -r answer

        case "$answer" in
            ""|[yY])
                rm -rf "$LIGHT_TERMINAL_PATH"
                ;;
            [nN])
                return 0
                ;;
            *)
                echo "Invalid response."
                return 1
                ;;
        esac
    fi

    echo -e "📂 Duplicating Terminal.app"
    mkdir -p "$HOME/Applications"
    cp -R /System/Applications/Utilities/Terminal.app "$LIGHT_TERMINAL_PATH"

    mkdir -p "$LIGHT_TERMINAL_PATH/Contents/Frameworks"
    cp "ForceLight.dylib" "$LIGHT_TERMINAL_PATH/Contents/Frameworks/"

    mv "$LIGHT_TERMINAL_PATH/Contents/MacOS/Terminal" "$LIGHT_TERMINAL_PATH/Contents/MacOS/Terminal.real"

    cat > "$LIGHT_TERMINAL_PATH/Contents/MacOS/Terminal" <<'EOF'
#!/bin/zsh

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_CONTENTS="$(dirname "$HERE")"

export DYLD_INSERT_LIBRARIES="$APP_CONTENTS/Frameworks/ForceLight.dylib"

exec "$HERE/Terminal.real" "$@"
EOF

    chmod +x "$LIGHT_TERMINAL_PATH/Contents/MacOS/Terminal"

    echo -e "✍️  Signing"
    codesign --force --deep --sign - "$LIGHT_TERMINAL_PATH"

    echo -e "\033[1m✅ Light Terminal installed\e[0m to \"$LIGHT_TERMINAL_PATH\""
}

if [[ ${1-} == "light" ]]; then
    install_light
elif [[ ${1-} == "dark" ]]; then
    install_dark
elif [[ -z ${1-} ]]; then
    install_light
    echo ""
    install_dark
else
    echo "2026, https://github.com/evgvs/macos-terminal-force-appearance"
    echo
    echo "Usage:"
    echo "  ./install.sh [light|dark]"
    echo
    echo "Options:"
    echo "  light    Install the Light Terminal"
    echo "  dark     Install the Dark Terminal"
    echo
    echo "If no option is specified, both Light and Dark Terminals are installed."
fi
