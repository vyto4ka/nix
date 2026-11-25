#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="all"
ACTION="switch"

usage() {
  cat <<'EOF'
Использование: ./scripts/update.sh [--all | --caelestia] [--switch | --boot]

Опции:
  --all        Обновить все инпуты флейка (включая синхронное обновление caelestia-shell и caelestia-dots) [по умолчанию]
  --caelestia  Синхронно обновить только caelestia-shell и caelestia-dots
  --switch     Применить конфигурацию немедленно через nh os switch [по умолчанию]
  --boot       Применить конфигурацию для следующей загрузки через nh os boot
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --all) MODE="all" ;;
    --caelestia) MODE="caelestia" ;;
    --switch) ACTION="switch" ;;
    --boot) ACTION="boot" ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Неизвестный аргумент: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "${MODE}" == "caelestia" ]]; then
  printf '[update] Синхронное обновление caelestia-shell и caelestia-dots...\n'
  nix flake update caelestia-shell caelestia-dots --flake "${REPO_DIR}"
else
  printf '[update] Обновление всех инпутов флейка...\n'
  nix flake update --flake "${REPO_DIR}"
fi

# Убеждаемся, что локальные файлы хоста остаются видимыми для дерева Flakes
for local_file in \
  hosts/zenbook/hardware-configuration.nix \
  hosts/zenbook/local-boot.nix; do
  if [[ -f "${REPO_DIR}/${local_file}" ]]; then
    git -C "${REPO_DIR}" add -f "${local_file}"
  fi
done

if command -v nh >/dev/null 2>&1; then
  nh os "${ACTION}" "${REPO_DIR}" --hostname zenbook
else
  sudo nixos-rebuild "${ACTION}" --flake "${REPO_DIR}#zenbook"
fi
