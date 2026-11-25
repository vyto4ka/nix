# NixOS для Zenbook

Конфигурация NixOS (`nixos-unstable`) с окружением Hyprland (UWSM, Lua), оболочкой Caelestia (`caelestia-shell` + `caelestia-cli` + `caelestia-dots`), экраном входа SilentSDDM и запасной сессией KDE Plasma 6.

## Быстрое развёртывание поверх чистой NixOS

Требования к базовой системе: установленная консольная NixOS с активным загрузчиком GRUB, работающим интернетом и созданным пользователем `vyto4ka` с заданным паролем.

```bash
nix-shell -p git --run "git clone https://github.com/vyto4ka/nix ~/nixos-config && cd ~/nixos-config && ./install.sh"
sudo reboot
```

Репозиторий клонируется строго в `~/nixos-config`: на этот путь указывают живые симлинки переопределений Caelestia (`home/caelestia/`) и пользовательских конфигов (`config/`).

## Подготовка перед установкой (dual-boot с Windows 11)

1. Сохранить ключ восстановления BitLocker и отключить быстрый запуск (Fast Startup) в Windows.
2. Скопировать папку `C:\Windows\Fonts` на внешний носитель, а после загрузки в NixOS перенести шрифты в `~/.local/share/fonts/` и выполнить `fc-cache -fv` (подхватываются системно и внутри FHS-окружения OnlyOffice).
3. Выписать адреса обоих шлюзов Cisco AnyConnect.

## Повседневное управление и обновление

Обновление всех инпутов флейка и пересборка системы:

```bash
~/nixos-config/scripts/update.sh
```

Синхронное обновление только `caelestia-shell` и `caelestia-dots`:

```bash
~/nixos-config/scripts/update.sh --caelestia
```

Быстрое применение локальных правок без обновления `flake.lock` (сокращения в `fish`):

```bash
nrs   # nh os switch ~/nixos-config --hostname zenbook
nrb   # nh os boot ~/nixos-config --hostname zenbook
```

## Пользовательские конфиги (`~/.config/`)

Файлы из каталога `config/` в корне репозитория автоматически раскладываются модулем `home/dotfiles.nix` в `~/.config/` пофайловыми живыми симлинками (`mkOutOfStoreSymlink`). Подкаталоги внутри `~/.config/` остаются обычными записываемыми директориями, а файлы с совпадающим путём переопределяют дефолтные конфиги других модулей.

- Добавление или удаление файла: `git add config/...` и `nrs`.
- Дальнейшие правки содержимого уже подключённых файлов применяются сразу без пересборки.

## Мониторы и режим Clamshell

Управление мониторами ведёт демон `hyprdynamicmonitors` (`--enable-lid-events`), а `home/caelestia/hypr-user.lua` транслирует сгенерированный `~/.config/hypr/monitors.conf` в нативные вызовы `hl.monitor()` для Hyprland 0.57+.

Для фиксации двух офисных мониторов на USB-C хабе строго по EDID (`description`), чтобы порядок экранов не зависел от плавающих имён `DP-*`, запустите при подключённом доке:

```bash
hyprdynamicmonitors tui --enable-lid-events
```

## Сеть и VPN

- **Keqdroid:** установлен из ветки `nix` (`Lemonochka/keqdroid`), режим TUN поднимается через `polkit` и `hyprpolkitagent`.
- **Cisco AnyConnect:** подключён плагин `networkmanager-openconnect` (с поддержкой WebKitGTK SSO) и агент `nm-applet --indicator`. Для шлюза с SSO-окном в настройках соединения укажите `User Agent: AnyConnect`.
- Одновременная работа обоих туннелей обеспечивается `networking.firewall.checkReversePath = "loose"` и `services.resolved.enable = true`.

## Основные сочетания клавиш

- `SUPER` : лаунчер приложений Caelestia
- `SUPER + A` : отдельный воркспейс AyuGram (`special:ayugram`)
- `Win + Пробел` : переключение раскладки `us,ru`
- `SUPER + T` : терминал `foot`
- `SUPER + W` : браузер `zen-beta`
- `SUPER + C` : редактор `codium`
- `SUPER + E` : файловый менеджер `thunar`
- `SUPER + SHIFT + Q` : скриншот области с фризом экрана в буфер обмена (`hyprshot`)
- `SUPER + L` : блокировка экрана Caelestia
