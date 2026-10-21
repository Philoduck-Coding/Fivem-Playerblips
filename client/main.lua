local blips = {}
local blipsEnabled = false

local function notify(message)
    ESX.ShowNotification(message)
end

local function removeBlip(player)
    local blip = blips[player]
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end

    blips[player] = nil
end

local function removeAllBlips()
    for player in pairs(blips) do
        removeBlip(player)
    end
end

local function createPlayerBlip(player)
    local blip = AddBlipForCoord(player.x, player.y, player.z)

    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipAsShortRange(blip, false)
    ShowHeadingIndicatorOnBlip(blip, true)
    SetBlipCategory(blip, 7)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('[%d] %s'):format(player.id, player.name))
    EndTextCommandSetBlipName(blip)

    blips[player.id] = blip
end

local function updatePlayerBlip(player)
    local blip = blips[player.id]
    if not blip or not DoesBlipExist(blip) then
        createPlayerBlip(player)
        return
    end

    SetBlipCoords(blip, player.x, player.y, player.z)
    SetBlipRotation(blip, math.floor(player.heading + 0.5))
end

RegisterNetEvent('sd-pblips:client:notify', function(message)
    notify(message)
end)

RegisterNetEvent('sd-pblips:client:toggle', function()
    blipsEnabled = not blipsEnabled

    if blipsEnabled then
        notify('Spieler-Blips wurden aktiviert.')
        CreateThread(function()
            while blipsEnabled do
                TriggerServerEvent('sd-pblips:server:requestSnapshot')
                Wait(Config.UpdateInterval)
            end
        end)
    else
        removeAllBlips()
        notify('Spieler-Blips wurden deaktiviert.')
    end
end)

RegisterNetEvent('sd-pblips:client:snapshot', function(players)
    if not blipsEnabled then
        return
    end

    local activePlayers = {}
    local ownServerId = GetPlayerServerId(PlayerId())

    for _, player in ipairs(players) do
        if player.id ~= ownServerId then
            activePlayers[player.id] = true
            updatePlayerBlip(player)
        end
    end

    for playerId in pairs(blips) do
        if not activePlayers[playerId] then
            removeBlip(playerId)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        removeAllBlips()
    end
end)
