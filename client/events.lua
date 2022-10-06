-- Player load and unload handling
-- New method for checking if logged in across all scripts (optional)
-- if LocalPlayer.state['isLoggedIn'] then
RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    if QBConfig.EnablePVP then
        Citizen.InvokeNative(0xF808475FA571D823, true)
        SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
    end
    if QBConfig.Player.RevealMap then
		SetMinimapHideFow(true)
	end
end)

RegisterNetEvent('QRCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

RegisterNetEvent('QRCore:Client:PvpHasToggled', function(pvp_state)
    NetworkSetFriendlyFireOption(pvp_state)
end)

-- QRCore Teleport Events
RegisterNetEvent('QRCore:Command:TeleportToPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('QRCore:Command:TeleportToCoords', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z)
end)

RegisterNetEvent('QRCore:Command:GoToMarker', function()
    local PlayerPedId = PlayerPedId
    local GetEntityCoords = GetEntityCoords
    local GetGroundZAndNormalFor_3dCoord = GetGroundZAndNormalFor_3dCoord

    if not IsWaypointActive() then
        Notify(9, 'No Waypoint Set', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        return 'marker'
    end

    --Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = PlayerPedId(), GetWaypointCoords()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end
        Citizen.InvokeNative(0x387AD749E3B69B70, x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while Citizen.InvokeNative(0xCF45DF50C7775F2A) do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        Citizen.InvokeNative(0x5A8B01199C3E79C3)
        SetEntityCoords(ped, x, y, z - 1000)
        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        --found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
        found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z)
        if found then
            Wait(0)
            SetEntityCoords(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetEntityCoords(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        Notify(9, 'Error teleporting', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end

    -- If Z coord was found, set coords in found coords.
    SetEntityCoords(ped, x, y, groundZ)
    Notify(9, 'Teleported', 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
end)

-- Vehicle | Horse Events

RegisterNetEvent('QRCore:Command:SpawnVehicle', function(model)
    local vehicle = exports['qr-core']:SpawnVehicle(model)
	TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
end)

RegisterNetEvent('QRCore:Command:DeleteVehicle', function()
	local ped = PlayerPedId()
	local vehicle = exports['qr-core']:GetClosestVehicle()
	if IsPedInAnyVehicle(ped) then vehicle = GetVehiclePedIsIn(ped, false) end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end)

RegisterNetEvent('QRCore:Command:GetCoords', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped, false)
    local heading = GetEntityHeading(ped)
    AddTextEntry("FMMC_KEY_TIP12", "Coords")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP12", "", vector4(pos.x, pos.y, pos.z, heading), "", "", "", 150)
end)

RegisterNetEvent('QRCore:Command:SpawnHorse', function(HorseName)
    local ped = PlayerPedId()
    local hash = tostring(HorseName)
    if hash then
        local animalHash = GetHashKey(hash)
        if not IsModelValid(animalHash) then return end
        while not HasModelLoaded(animalHash) do Wait(100) end
		local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.5))
        local npc = CreatePed(animalHash, x, y, z, GetEntityHeading(ped) + 90, 1, 0)
        SetRandomOutfitVariation(npc, true)
        SetPedScale(npc, num)
		while not IsPedReadyToRender(npc) do Wait(0) end
		Citizen.InvokeNative(0x704C908E9C405136, npc)
		Citizen.InvokeNative(0xAAB86462966168CE, npc, 1)
        Wait(500)
    else
		Notify(9, 'Model not found', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

-- Other stuff

RegisterNetEvent('QRCore:Player:SetPlayerData', function(val)
    QRCore.PlayerData = val
end)

RegisterNetEvent('QRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('QRCore:UpdatePlayer')
end)

RegisterNetEvent('QRCore:Notify', function(id, text, duration, subtext, dict, icon, color)
    Notify(id, text, duration, subtext, dict, icon, color)
end)

RegisterNetEvent('QRCore:Client:UseItem', function(item)
    TriggerServerEvent('QRCore:Server:UseItem', item)
end)

RegisterNetEvent('QRCore:Client:TriggerCallback', function(name, ...)
    if QRCore.ServerCallbacks[name] then
        QRCore.ServerCallbacks[name](...)
        QRCore.ServerCallbacks[name] = nil
    end
end)

-- Listen to Shared being updated
RegisterNetEvent('QRCore:Client:OnSharedUpdate', function(tableName, key, value)
    QRCore.Shared[tableName][key] = value
    TriggerEvent('QRCore:Client:UpdateObject')
end)

RegisterNetEvent('QRCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QRCore.Shared[tableName][key] = value
    end
    TriggerEvent('QRCore:Client:UpdateObject')
end)
