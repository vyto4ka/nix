set -gx EDITOR nvim
set -gx VISUAL nvim

# При старте терминала показываем мини-fastfetch; команда fastfetch использует полный config.jsonc
function fish_greeting
    if command -v fastfetch >/dev/null
        if test -f ~/.config/fastfetch/mini.jsonc
            fastfetch --config ~/.config/fastfetch/mini.jsonc
        else
            fastfetch
        end
    end
end

alias nrs 'nh os switch ~/nixos-config --hostname zenbook'
alias nrb 'nh os boot ~/nixos-config --hostname zenbook'
alias nru '~/nixos-config/scripts/update.sh'
alias nrc '~/nixos-config/scripts/update.sh --caelestia'

function blur --description 'Управление блюром Hyprland: blur [on|off|reset|<size> [passes]]'
    if test (count $argv) -eq 0
        set -l state (hyprctl getoption decoration:blur:enabled -j | jq -r '.bool')
        if test "$state" = true
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = false } } })' >/dev/null
            echo 'Блюр: выключен'
        else
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = true } } })' >/dev/null
            echo 'Блюр: включён'
        end
        return
    end

    switch $argv[1]
        case on 1 true
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = true } } })' >/dev/null
            echo 'Блюр: включён'
        case off 0 false
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = false } } })' >/dev/null
            echo 'Блюр: выключен'
        case reset
            hyprctl reload >/dev/null
            echo 'Блюр: сброшен к конфигу'
        case '*'
            if test (count $argv) -ge 2
                hyprctl eval "hl.config({ decoration = { blur = { enabled = true, size = $argv[1], passes = $argv[2] } } })" >/dev/null
                echo "Блюр: size=$argv[1], passes=$argv[2]"
            else
                hyprctl eval "hl.config({ decoration = { blur = { enabled = true, size = $argv[1] } } })" >/dev/null
                echo "Блюр: size=$argv[1]"
            end
    end
end

function eco --description 'Эко-режим: eco [on|60|off]'
    switch "$argv[1]"
        case off
            hyprctl reload >/dev/null
            powerprofilesctl set balanced
            echo 'Эко-режим: выключен (balanced + конфиг Hyprland)'
        case 60
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false } } }); hl.monitor({ output = "eDP-1", mode = "2880x1800@60", position = "auto", scale = 1.5 })' >/dev/null
            powerprofilesctl set power-saver
            echo 'Эко-режим: максимум (без блюра/теней, 60 Гц, power-saver)'
        case '' on
            hyprctl eval 'hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false } } })' >/dev/null
            powerprofilesctl set power-saver
            echo 'Эко-режим: включён (без блюра/теней, power-saver)'
        case '*'
            echo 'Использование: eco [on|60|off]'
    end
end
