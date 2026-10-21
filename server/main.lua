local function containsValue(values, value)
    for _, entry in ipairs(values or {}) do
        if entry == value then
            return true
        end
    end

    return false
end

local function hasAllowedIdentifier(playerSource)
    for _, identifier in ipairs(GetPlayerIdentifiers(playerSource)) do
        if containsValue(Config.AllowedIdentifiers, identifier) then
            return true
        end
    end

    return false
end

local function isAllowed(playerSource)
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    if not xPlayer then
        return false
    end

    if containsValue(Config.AllowedGroups, xPlayer.getGroup()) then
        return true
    end

    local job = xPlayer.getJob()
    if job and containsValue(Config.AllowedJobs, job.name) then
        return true
    end

    return hasAllowedIdentifier(playerSource)
end

RegisterCommand('pblips', function(playerSource)
    if playerSource == 0 then
        print('^1[pblips]^7 Dieser Befehl kann nur von einem Spieler verwendet werden.')
        return
    end

    if not isAllowed(playerSource) then
        TriggerClientEvent('sd-pblips:client:notify', playerSource, 'Du hast keine Berechtigung für diesen Befehl.')
        return
    end

    TriggerClientEvent('sd-pblips:client:toggle', playerSource)
end, false)

RegisterNetEvent('sd-pblips:server:requestSnapshot', function()
    local playerSource = source
    if not isAllowed(playerSource) then
        return
    end

    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local targetSource = tonumber(playerId)
        local ped = GetPlayerPed(targetSource)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            players[#players + 1] = {
                id = targetSource,
                name = GetPlayerName(targetSource) or 'Unbekannt',
                x = coords.x,
                y = coords.y,
                z = coords.z,
                heading = GetEntityHeading(ped)
            }
        end
    end

    TriggerClientEvent('sd-pblips:client:snapshot', playerSource, players)
end)
