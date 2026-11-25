local home = os.getenv("HOME")

-- Перекрываем апстримный input.lua раскладкой us,ru по Win+Space
-- и убираем мыло в XWayland-окнах на OLED 2880x1800 (scale 1.5)
hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:win_space_toggle",
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Стартовый масштаб встроенной OLED-панели до применения профиля hyprdynamicmonitors,
-- чтобы избежать скачка масштаба 1.0 -> 1.5 в первую секунду входа
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "auto",
    scale    = 1.5,
})

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Чтение ~/.config/hypr/monitors.conf, генерируемого hyprdynamicmonitors (и его TUI),
-- с переводом директив monitor=... в нативные вызовы hl.monitor() для Hyprland 0.57+ Lua
local function apply_dynamic_monitors(conf_path)
    local f = io.open(conf_path, "r")
    if not f then
        return
    end

    for raw_line in f:lines() do
        local line = trim(raw_line:gsub("#.*$", ""))
        local rhs = line:match("^monitor%s*=%s*(.+)$")
        if rhs then
            local parts = {}
            for token in rhs:gmatch("[^,]+") do
                parts[#parts + 1] = trim(token)
            end

            local output = parts[1]
            local mode = parts[2]
            if output and mode then
                if mode == "disable" or mode == "disabled" then
                    hl.monitor({
                        output   = output,
                        disabled = true,
                    })
                else
                    local spec = {
                        output   = output,
                        mode     = mode,
                        position = parts[3] or "auto",
                        scale    = tonumber(parts[4]) or parts[4] or 1,
                    }

                    local i = 5
                    while i <= #parts do
                        local key = parts[i]
                        local val = parts[i + 1]
                        if key == "transform" and val then
                            spec.transform = tonumber(val) or val
                            i = i + 2
                        elseif key == "mirror" and val then
                            spec.mirror = val
                            i = i + 2
                        elseif key == "bitdepth" and val then
                            spec.bitdepth = tonumber(val) or val
                            i = i + 2
                        elseif key == "vrr" and val then
                            spec.vrr = tonumber(val) or val
                            i = i + 2
                        else
                            i = i + 1
                        end
                    end

                    hl.monitor(spec)
                end
            end
        end
    end

    f:close()
end

apply_dynamic_monitors(home .. "/.config/hypr/monitors.conf")

-- Однократная первичная инициализация цветовой схемы строго внутри живой D-Bus сессии
-- (чтобы dconf write успешно выставил тему GTK, иконки и color-scheme)
hl.on("hyprland.start", function()
    hl.exec_cmd("xdg-user-dirs-update")
    hl.exec_cmd(
        'test -f "${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json" || caelestia scheme set -n caelestia'
    )
end)
