-- main.lua
-- Script para "Monday Morning Misery" en Roblox
-- Licencia: Apache-2.0 License

--[[
    Copyright 2025 Nombre del autor

    Licenciado bajo la Licencia Apache, Versión 2.0 (la "Licencia");
    no puedes usar este archivo excepto en cumplimiento con la Licencia.
    Puedes obtener una copia de la Licencia en:

        http://www.apache.org/licenses/LICENSE-2.0

    A menos que lo exija la ley aplicable o se acuerde por escrito, el software
    distribuido bajo la Licencia se distribuye "TAL CUAL",
    SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ya sea explícitas o implícitas.
    Consulta la Licencia para el lenguaje específico que rige los permisos y
    limitaciones bajo la Licencia.
]]

-- Cargar la biblioteca desde GitHub
local UwUware = loadstring(game:HttpGet("https://raw.githubusercontent.com/OPENCUP/random-texts/main/ui.lua"))()

-- Crear la ventana principal
local window = UwUware:CreateWindow("Monday Morning Misery")

-- Configuración de opciones de usuario
window:AddToggle({
    text = "Toggle Autoplayer",
    flag = "IsAnimeFan",
    state = true
})

window:AddBind({
    key = Enum.KeyCode.Quote,
    text = "Close GUI",
    callback = function()
        UwUware:Close()
    end
})

window:AddButton({
    text = "Unload Script",
    callback = function()
        clear()
        UwUware.base:Destroy()
        UwUware = nil
    end
})

window:AddButton({
    text = "Copy Discord Invite",
    callback = function()
        local code = game:HttpGet("https://stavratum.github.io/invite")
        local invite = "discord.gg/" .. code
        setclipboard(invite)
    end
})

-- Servicios principales de Roblox
local replicatedstorage = game:GetService("ReplicatedStorage")
local manager = game:GetService("VirtualInputManager")
local runservice = game:GetService("RunService")
local players = game:GetService("Players")

-- Variables y configuraciones
local options = getrenv()._G.PlayerData.Options
local flags = UwUware.flags
local connections = {}
local codes = {
    [9] = {"Left", "Down", "Up", "Right", "Space", "Left2", "Down2", "Up2", "Right2"},
    [8] = {"Left", "Down", "Up", "Right", "Left2", "Down2", "Up2", "Right2"},
    [7] = {"Left", "Up", "Right", "Space", "Left2", "Down", "Right2"},
    [6] = {"Left", "Up", "Right", "Left2", "Down", "Right2"},
    [5] = {"Left", "Down", "Space", "Up", "Right"},
    [4] = {"Left", "Down", "Up", "Right"}
}

-- Función principal
function main()
    local match = getMatch()
    if not match then return end

    repeat wait(1) until rawget(match, 'Songs')

    local side = getSide(match.PlayerType)
    local arrowGui = match.ArrowGui

    local sideFrame = arrowGui[side]
    local container = sideFrame.MainArrowContainer
    local longNotes = sideFrame.LongNotes
    local notes = sideFrame.Notes

    local maxArrows = match.MaxArrows
    local controls = maxArrows < 5 and options
        or options.ExtraKeySettings[tostring(maxArrows)]

    container = sort(container)
    longNotes = sort(longNotes)
    notes = sort(notes)

    for index, holder in ipairs(notes) do
        local name = codes[maxArrows][index]
        local keycode = controls[name .. "Key"]

        table.insert(connections, holder.ChildAdded:Connect(function(note)
            if not flags.IsAnimeFan then return end
            while (note.AbsolutePosition - holder.AbsolutePosition).Magnitude >= 10 * maxArrows do
                runservice.RenderStepped:Wait()
            end
            manager:SendKeyEvent(true, keycode, false, nil)
        end))
    end
end

-- Ordenar elementos
function sort(instance)
    local children = instance:GetChildren()
    table.sort(children, function(a, b)
        return a.AbsolutePosition.X < b.AbsolutePosition.X
    end)
    return children
end

-- Obtener lado del jugador
function getSide(playerType)
    return (playerType == 1) and "Left" or "Right"
end

-- Buscar partida actual
function getMatch()
    for _,v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "MatchFolder") then
            return v
        end
    end
end

-- Limpiar conexiones
function clear()
    for _,v in ipairs(connections) do
        v:Disconnect()
    end
    table.clear(connections)
end

-- Iniciar GUI
UwUware:Init()

-- Monitorizar partida
while wait(1) do
    clear()
    main()
end
