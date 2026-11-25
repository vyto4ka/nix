#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EXPECTED_DIR="/home/vyto4ka/nixos-config"
HOST_DIR="${REPO_DIR}/hosts/zenbook"
TARGET_USER="vyto4ka"

log() {
  printf '[install] %s\n' "$*"
}

die() {
  printf '[install] ОШИБКА: %s\n' "$*" >&2
  exit 1
}

if [[ "${EUID}" -eq 0 ]]; then
  die "Запускайте скрипт от обычного пользователя (${TARGET_USER}), а не от root."
fi

if [[ ! -f /etc/NIXOS ]]; then
  die "Скрипт предназначен для запуска внутри установленной базовой NixOS."
fi

if [[ "${REPO_DIR}" != "${EXPECTED_DIR}" ]]; then
  die "Репозиторий должен лежать строго в ${EXPECTED_DIR} (сейчас: ${REPO_DIR}), так как на этот путь ссылаются живые симлинки Caelestia."
fi

log "Проверка сетевого соединения..."
if ! getent hosts cache.nixos.org >/dev/null 2>&1 && ! ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
  die "Нет сетевого доступа. Подключите интернет перед установкой."
fi

log "Проверка пользователя ${TARGET_USER} и наличия пароля..."
if ! id "${TARGET_USER}" >/dev/null 2>&1; then
  die "Пользователь ${TARGET_USER} не найден в базовой системе."
fi

PASS_STATUS="$(sudo passwd -S "${TARGET_USER}" 2>/dev/null | awk '{print $2}' || true)"
if [[ "${PASS_STATUS}" != "P" && "${PASS_STATUS}" != "PS" ]]; then
  die "У пользователя ${TARGET_USER} не задан пароль (статус: ${PASS_STATUS:-неизвестен}). Задайте его через 'sudo passwd ${TARGET_USER}'."
fi

eval_nixos_opt() {
  local attr="$1"
  nix-instantiate --eval --strict --json '<nixpkgs/nixos>' -A "config.${attr}" 2>/dev/null
}

log "Проверка активного загрузчика GRUB в базовой NixOS..."
GRUB_ENABLED="$(eval_nixos_opt 'boot.loader.grub.enable' || echo 'false')"
if [[ "${GRUB_ENABLED}" != "true" ]]; then
  die "В базовой NixOS не активен загрузчик GRUB (boot.loader.grub.enable = ${GRUB_ENABLED})."
fi

if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
  die "Не найден /etc/nixos/hardware-configuration.nix."
fi

mkdir -p "${HOST_DIR}"
log "Копирование /etc/nixos/hardware-configuration.nix -> hosts/zenbook/hardware-configuration.nix..."
cp -f /etc/nixos/hardware-configuration.nix "${HOST_DIR}/hardware-configuration.nix"

log "Считывание параметров загрузчика и stateVersion базовой ОС..."
STATE_VERSION="$(eval_nixos_opt 'system.stateVersion')"
GRUB_DEVICE="$(eval_nixos_opt 'boot.loader.grub.device')"
GRUB_EFI_SUPPORT="$(eval_nixos_opt 'boot.loader.grub.efiSupport')"
GRUB_EFI_REMOVABLE="$(eval_nixos_opt 'boot.loader.grub.efiInstallAsRemovable')"
EFI_MOUNT_POINT="$(eval_nixos_opt 'boot.loader.efi.efiSysMountPoint')"
EFI_CAN_TOUCH="$(eval_nixos_opt 'boot.loader.efi.canTouchEfiVariables')"

cat > "${HOST_DIR}/local-boot.nix" <<EOF
# Сгенерировано автоматически скриптом install.sh из базовой установки NixOS.
{
  system.stateVersion = ${STATE_VERSION};

  boot.loader = {
    grub = {
      device = ${GRUB_DEVICE};
      efiSupport = ${GRUB_EFI_SUPPORT};
      efiInstallAsRemovable = ${GRUB_EFI_REMOVABLE};
    };
    efi = {
      efiSysMountPoint = ${EFI_MOUNT_POINT};
      canTouchEfiVariables = ${EFI_CAN_TOUCH};
    };
  };
}
EOF

log "Индексация локальных файлов хоста для Nix Flakes..."
git -C "${REPO_DIR}" add -f \
  hosts/zenbook/hardware-configuration.nix \
  hosts/zenbook/local-boot.nix

log "Сборка конфигурации .#zenbook для следующей загрузки (nixos-rebuild boot)..."
nixos-rebuild boot \
  --flake "${REPO_DIR}#zenbook" \
  --sudo \
  --option experimental-features "nix-command flakes"

log "Готово. Новое поколение зарегистрировано в GRUB без обрыва текущей сессии."
log "Перезагрузите ноутбук командой: sudo reboot"
