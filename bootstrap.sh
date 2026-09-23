#!/usr/bin/env bash
set -euo pipefail

printf '\n🛠️  Bootstrapping Developer Workstation\n'
printf '========================================\n\n'

if [[ ! -f /etc/os-release ]]; then
  echo "Unsupported operating system: /etc/os-release not found."
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

# This bootstrap targets Debian and Debian-derived distributions that use apt.
if ! command -v apt-get >/dev/null 2>&1; then
  echo "This bootstrap requires a Debian-based Linux distribution with apt-get."
  exit 1
fi

if [[ "${ID:-}" != "debian" && "${ID_LIKE:-}" != *debian* ]]; then
  echo "This system does not identify itself as Debian or Debian-derived."
  echo "Detected: ID=${ID:-unknown} ID_LIKE=${ID_LIKE:-unknown}"
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "This setup currently targets x86_64 Linux."
  exit 1
fi

echo "→ Installing base system dependencies..."
sudo apt-get update
sudo apt-get install -y \
  curl \
  wget \
  ca-certificates \
  gnupg \
  build-essential \
  xz-utils \
  git

if ! command -v docker >/dev/null 2>&1; then
  echo "→ Installing Docker Engine from the distribution repositories..."
  sudo apt-get install -y docker.io
  sudo systemctl enable --now docker
else
  echo "✓ Docker already installed"
fi

if ! getent group docker >/dev/null 2>&1; then
  sudo groupadd docker
fi

if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  echo "→ Adding $USER to docker group..."
  sudo usermod -aG docker "$USER"
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "→ Installing Nix (multi-user daemon mode)..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
else
  echo "✓ Nix already installed"
fi

if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

mkdir -p "$HOME/.config/nix"
if [[ -f "$HOME/.config/nix/nix.conf" ]]; then
  if ! grep -q '^experimental-features = .*nix-command.*flakes' "$HOME/.config/nix/nix.conf"; then
    printf '\nexperimental-features = nix-command flakes\n' >> "$HOME/.config/nix/nix.conf"
  fi
else
  printf 'experimental-features = nix-command flakes\n' > "$HOME/.config/nix/nix.conf"
fi

echo "→ Applying Home Manager configuration..."
nix run github:nix-community/home-manager -- \
  switch \
  --flake ".#$USER"

printf '\n========================================\n'
printf '🛠️  Developer workstation ready\n'
printf '========================================\n\n'
printf 'Installed/configured:\n'
printf '  ✓ Nix + Home Manager\n'
printf '  ✓ Docker\n'
printf '  ✓ VS Code\n'
printf '  ✓ Node.js + pnpm\n'
printf '  ✓ Python + uv\n'
printf '  ✓ Git + GitHub CLI\n'
printf '  ✓ tmux + zsh + starship\n'
printf '  ✓ Kubernetes + Helm + k9s\n'
printf '  ✓ Terraform\n'
printf '  ✓ PostgreSQL / Redis clients\n'
printf '  ✓ protobuf / grpcurl\n'
printf '  ✓ modern CLI and debugging tools\n\n'
printf 'Log out and back in once so Docker group membership takes effect.\n'
