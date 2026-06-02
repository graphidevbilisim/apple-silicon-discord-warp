#!/bin/bash

set -Eeuo pipefail

PROJECT_NAME="Discord Warp"
INSTALL_DIR="$HOME/.discord-warp"
BIN_DIR="$HOME/.local/bin"
LAUNCHER="$BIN_DIR/discord-warp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
if [ $? -ne 0 ]; then
error "Installation failed."
fi
}

trap cleanup EXIT

echo
echo "========================================="
echo "       $PROJECT_NAME Installer"
echo "========================================="
echo

#

# macOS kontrolü

#

if [[ "$(uname)" != "Darwin" ]]; then
error "This installer only supports macOS."
exit 1
fi

#

# Homebrew kontrolü

#

if ! command -v brew >/dev/null 2>&1; then
error "Homebrew is not installed."
echo
echo "Install Homebrew first:"
echo
echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
echo
exit 1
fi

#

# Discord kontrolü

#

if [ ! -d "/Applications/Discord.app" ]; then
warn "Discord.app not found in /Applications"
echo "Please install Discord first:"
echo "https://discord.com/download"
exit 1
fi

log "Updating Homebrew..."
brew update

#

# Bağımlılıklar

#

log "Installing dependencies..."
brew install wgcf wireguard-tools || true

#

# Apple Silicon / Intel uyumluluğu

#

log "Configuring compatibility paths..."

sudo mkdir -p /usr/local/bin

WG_PATH="$(which wg)"
WG_QUICK_PATH="$(which wg-quick)"
WGCF_PATH="$(which wgcf)"

if [ ! -e /usr/local/bin/wg ]; then
sudo ln -s "$WG_PATH" /usr/local/bin/wg
fi

if [ ! -e /usr/local/bin/wg-quick ]; then
sudo ln -s "$WG_QUICK_PATH" /usr/local/bin/wg-quick
fi

if [ ! -e /usr/local/bin/wgcf ]; then
sudo ln -s "$WGCF_PATH" /usr/local/bin/wgcf
fi

#

# Çalışma klasörü

#

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

cd "$INSTALL_DIR"

#

# WGCF hesabı

#

if [ ! -f "$INSTALL_DIR/wgcf-account.toml" ]; then
echo
echo "Cloudflare WARP registration required."
echo "Accept the Cloudflare terms when prompted."
echo


wgcf register


fi

#

# Profil oluştur

#

log "Generating WireGuard profile..."
wgcf generate

#

# WireGuard yapılandırması

#

log "Installing WireGuard profile..."

sudo mkdir -p /etc/wireguard
sudo cp "$INSTALL_DIR/wgcf-profile.conf" /etc/wireguard/wgcf.conf

#

# Launcher

#

log "Creating launcher..."

cat > "$LAUNCHER" << 'EOF'
#!/bin/bash

set -Eeuo pipefail

cleanup() {
sudo wg-quick down wgcf >/dev/null 2>&1 || true
}

trap cleanup EXIT INT TERM

if ! pgrep -x Discord >/dev/null 2>&1; then

```
if ! sudo wg show wgcf >/dev/null 2>&1; then
    sudo wg-quick up wgcf
fi

open -a Discord

while pgrep -x Discord >/dev/null 2>&1
do
    sleep 5
done
```

else
echo "Discord is already running."
fi
EOF

chmod +x "$LAUNCHER"

#

# PATH kontrolü

#

if ! echo "$PATH" | grep -q "$BIN_DIR"; then

```
SHELL_NAME="$(basename "$SHELL")"

case "$SHELL_NAME" in
    zsh)
        PROFILE="$HOME/.zshrc"
        ;;
    bash)
        PROFILE="$HOME/.bashrc"
        ;;
    *)
        PROFILE="$HOME/.profile"
        ;;
esac

if [ -f "$PROFILE" ]; then
    if ! grep -q "$BIN_DIR" "$PROFILE"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE"
    fi
else
    echo 'export PATH="$HOME/.local/bin:$PATH"' > "$PROFILE"
fi
```

fi

#

# uninstall script

#

cat > "$INSTALL_DIR/uninstall.sh" << 'EOF'
#!/bin/bash

sudo wg-quick down wgcf >/dev/null 2>&1 || true

rm -f "$HOME/.local/bin/discord-warp"

sudo rm -f /etc/wireguard/wgcf.conf

echo "Removed."
EOF

chmod +x "$INSTALL_DIR/uninstall.sh"

echo
echo "========================================="
echo "Installation completed."
echo "========================================="
echo
echo "Restart Terminal or run:"
echo
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo
echo "Then launch Discord with:"
echo
echo "discord-warp"
echo
echo "Uninstall:"
echo
echo "$INSTALL_DIR/uninstall.sh"
echo
