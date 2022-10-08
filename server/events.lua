-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not QRCore.Players[src] then return end
    local Player = QRCore.Players[src]
    TriggerEvent('qr-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' ..'\n **Reason:** ' .. reason)
    Player.Functions.Save()
    QRCore.Player_Buckets[Player.PlayerData.license] = nil
    QRCore.Players[src] = nil
end)

-- Player Connecting

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if QRCore.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'QRadmin.join') then
            deferrals.done(QRCore.Config.Server.ClosedReason)
        end
    end

    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- Mandatory wait
    Wait(2500)

    deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))

    local isBanned, Reason = QRCore.Functions.IsPlayerBanned(src)
    local isLicenseAlreadyInUse = QRCore.Functions.IsLicenseInUse(license)
    local isWhitelist, whitelisted = QRCore.Config.Server.Whitelist, QRCore.Functions.IsWhitelisted(src)

    Wait(2500)

    deferrals.update(string.format(Lang:t('info.join_server'), name))

    if not license then
      deferrals.done(Lang:t('error.no_valid_license'))
    elseif isBanned then
        deferrals.done(Reason)
    elseif isLicenseAlreadyInUse and QRCore.Config.Server.CheckDuplicateLicense then
        deferrals.done(Lang:t('error.duplicate_license'))
    elseif isWhitelist and not whitelisted then
      deferrals.done(Lang:t('error.not_whitelisted'))
    end

    deferrals.done()

    -- Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('QRCore:Server:CloseServer', function(reason)
    local src = source
    if QRCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        QRCore.Config.Server.Closed = true
        QRCore.Config.Server.ClosedReason = reason
        for k in pairs(QRCore.Players) do
            if not QRCore.Functions.HasPermission(k, QRCore.Config.Server.WhitelistPermission) then
                QRCore.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        QRCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

RegisterNetEvent('QRCore:Server:OpenServer', function()
    local src = source
    if QRCore.Functions.HasPermission(src, 'admin') then
        QRCore.Config.Server.Closed = false
    else
        QRCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('QRCore:Server:TriggerClientCallback', function(name, ...)
    if QRCore.ClientCallbacks[name] then
        QRCore.ClientCallbacks[name](...)
        QRCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('QRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    QRCore.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('QRCore:UpdatePlayer', function()
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - QRCore.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - QRCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterNetEvent('QRCore:Server:SetMetaData', function(meta, data)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    if not Player then return end
    if meta == 'hunger' or meta == 'thirst' then
        if data > 100 then
            data = 100
        end
    end
    Player.Functions.SetMetaData(meta, data)
    TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)

RegisterNetEvent('QRCore:ToggleDuty', function()
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('QRCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('QRCore:Notify', src, Lang:t('info.on_duty'))
    end
    TriggerClientEvent('QRCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('QRCore:Server:UseItem', function(item)
    print(string.format("%s triggered QRCore:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qb-inventory for the right use on this event.", GetInvokingResource(), source))
    QRCore.Debug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('QRCore:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered QRCore:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('QRCore:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered QRCore:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: qr-adminmenu)

RegisterNetEvent('QRCore:CallCommand', function(command, args)
    local src = source
    if not QRCore.Commands.List[command] then return end
    local Player = QRCore.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = QRCore.Functions.HasPermission(src, "command."..QRCore.Commands.List[command].name)
    if hasPerm then
        if QRCore.Commands.List[command].argsrequired and #QRCore.Commands.List[command].arguments ~= 0 and not args[#QRCore.Commands.List[command].arguments] then
            TriggerClientEvent('QRCore:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            QRCore.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('QRCore:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
QRCore.Functions.CreateCallback('QRCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
QRCore.Functions.CreateCallback('QRCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
    local veh = Citizen.InvokeNative(CreateAutomobile, model, coords, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)