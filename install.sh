#!/bin/bash

set -e

echo "Installing dependencies..."

if ! command -v brew >/dev/null 2>&1; then
echo "Homebrew is required."
exit 1
fi

brew install wgcf wireguard-tools

sudo mkdir -p /usr/local/bin

[ -e /usr/local/bin/wg ] || sudo ln -s /opt/homebrew/bin/wg /usr/local/bin/wg 2>/dev/null || true
[ -e /usr/local/bin/wg-quick ] || sudo ln -s /opt/homebrew/bin/wg-quick /usr/local/bin/wg-quick 2>/dev/null || true
[ -e /usr/local/bin/wgcf ] || sudo ln -s /opt/homebrew/bin/wgcf /usr/local/bin/wgcf 2>/dev/null || true

mkdir -p "$HOME/.discord-warp"
cd "$HOME/.discord-warp"

if [ ! -f wgcf-account.toml ]; then
wgcf register
fi

wgcf generate

sudo mkdir -p /etc/wireguard
sudo cp wgcf-profile.conf /etc/wireguard/wgcf.conf

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/discord-warp" << 'EOF'
#!/bin/bash

cleanup() {
sudo wg-quick down wgcf >/dev/null 2>&1 || true
}

trap cleanup EXIT INT TERM

if ! sudo wg show wgcf >/dev/null 2>&1; then
sudo wg-quick up wgcf
fi

open -a Discord

while pgrep -x Discord >/dev/null
do
sleep 5
done
EOF

chmod +x "$HOME/.local/bin/discord-warp"

echo ""
echo "Installation complete."
echo ""
echo "Run:"
echo "discord-warp"
