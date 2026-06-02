# Discord Warp for macOS

Launch Discord with Cloudflare WARP automatically.

## Features

* Apple Silicon (M1/M2/M3/M4) support
* Intel Mac support
* Automatic WGCF setup
* Automatic WireGuard installation
* Automatic profile generation
* Automatic cleanup
* Discord-aware VPN lifecycle

## Install

curl -fsSL https://raw.githubusercontent.com/USERNAME/REPO/main/install.sh | bash

## Usage

discord-warp

## How it works

1. Starts Cloudflare WARP.
2. Launches Discord.
3. Keeps WARP active while Discord is running.
4. Disables WARP when Discord exits.

## Security

* Uses official Cloudflare WARP network.
* Uses WireGuard protocol.
* Does not open ports.
* Does not install kernel extensions.
* Does not modify firewall settings.
