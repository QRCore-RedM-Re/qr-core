-- Player load and unload handling
-- New method for checking if logged in across all scripts (optional)
-- if LocalPlayer.state['isLoggedIn'] then

-- Player Spawned --
AddEventHandler('playerSpawned', function()
    Wait(2000)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, Lang:t("loading.text1"), Lang:t("loading.text2"), Lang:t("loading.text3")) -- Loading Screen Text
    ShutdownLoadingScreen() -- Stop Loading Screen
    DisplayRadar(false) -- Hide Radar
    SetMinimapHideFow(false) -- Hide Map
    Citizen.InvokeNative(0xA63FCAD3A6FEC6D2, cache.ped, QRConfig.Player.EnableEagleEye) -- Enable Eagle Eye
    TriggerEvent("qr-multicharacter:client:chooseChar")
end)

-- Player Load / Unload --
RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function()
    LocalPlayer.state:set('isLoggedIn', true, false)
    if QRConfig.Player.RevealMap then
        SetMinimapHideFow(true)
        DisplayRadar(true)
    end
end)

RegisterNetEvent('QRCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

-- Player Data --
RegisterNetEvent('QRCore:Player:SetPlayerData', function(val)
    QRCore.PlayerData = val
end)

RegisterNetEvent('QRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('QRCore:UpdatePlayer')
end)

-- Notify --
RegisterNetEvent('QRCore:Notify', function(text, type, length)
    QRCore.Functions.Notify(text, type, length)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('QRCore:Client:UseItem', function(item)
    QRCore.Debug(string.format("%s triggered QRCore:Client:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qr-inventory for the right use on this event.", GetInvokingResource(), GetPlayerServerId(PlayerId())))
    QRCore.Debug(item)
end)

-- Client Callback
RegisterNetEvent('QRCore:Client:TriggerClientCallback', function(name, ...)
    QRCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QRCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
RegisterNetEvent('QRCore:Client:TriggerCallback', function(name, ...)
    if QRCore.ServerCallbacks[name] then
        QRCore.ServerCallbacks[name](...)
        QRCore.ServerCallbacks[name] = nil
    end
end)

-- Listen to Shared Being Updated --
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


-----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- COMMAND EVENTS -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

-- Teleport to Plyer --
RegisterNetEvent('QRCore:Command:TeleportToPlayer', function(coords)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
end)

-- Teleport to Coords Command --
RegisterNetEvent('QRCore:Command:TeleportToCoords', function(x, y, z, h)
    SetEntityCoords(cache.ped, x, y, z)
    SetEntityHeading(cache.ped, h or GetEntityHeading(cache.ped))
end)

-- Teleport to Waypoint --
RegisterNetEvent('QRCore:Command:GoToMarker', function()
    local PlayerPedId = PlayerPedId
    local GetEntityCoords = GetEntityCoords
    local GetGroundZAndNormalFor_3dCoord = GetGroundZAndNormalFor_3dCoord

    if not IsWaypointActive() then
        QRCore.Functions.Notify(Lang:t("error.no_waypoint"), "error", 5000)
        return 'marker'
    end

    --Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do Wait(0) end

    local ped, coords <const> = cache.ped, GetWaypointCoords()
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
        while Citizen.InvokeNative(0xCF45DF50C7775F2A) do
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
        QRCore.Functions.Notify(Lang:t("error.tp_error"), "error", 5000)
    end

    -- If Z coord was found, set coords in found coords.
    SetEntityCoords(ped, x, y, groundZ)
    QRCore.Functions.Notify(Lang:t("success.teleported_waypoint"), "success", 5000)
end)

-- Spawn Wagon --
RegisterNetEvent('QRCore:Command:SpawnVehicle', function(WagonName)
    local hash = GetHashKey(WagonName)
    if not IsModelInCdimage(hash) then return end

    lib.requestModel(hash)

    if cache.vehicle then
        DeleteVehicle(cache.vehicle)
        while DoesEntityExist(cache.vehicle) do Wait(100) end
    elseif cache.mount then
        DeletePed(cache.mount)
        while DoesEntityExist(cache.mount) do Wait(100) end
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(cache.ped), GetEntityHeading(cache.ped), true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, vehicle, 0) -- Place horse on ground properly
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1) -- Spawn the player onto "drivers" seat
	Citizen.InvokeNative(0x283978A15512B2FE, vehicle, true) -- Set random outfit variation / skin
	NetworkSetEntityInvisibleToNetwork(vehicle, true)
end)

-- Spawn Horse --
RegisterNetEvent('QRCore:Command:SpawnHorse', function(HorseName)
    local horseModel = QRHorses[HorseName]['model']
    local hash = GetHashKey(horseModel)
    local hashp = GetHashKey("PLAYER")
    if not IsModelInCdimage(horseModel) then return end

    lib.requestModel(horseModel)

    if cache.mount then
        DeletePed(cache.mount)
        while DoesEntityExist(cache.mount) do Wait(100) end
    elseif cache.vehicle then
        DeleteVehicle(cache.vehicle)
        while DoesEntityExist(cache.vehicle) do Wait(100) end
    end

    local Horse = CreatePed(horseModel, GetEntityCoords(cache.ped), GetEntityHeading(cache.ped), true, false)
    Citizen.InvokeNative(0x9587913B9E772D29, Horse, 0) -- Place horse on ground properly
    Citizen.InvokeNative(0xADB3F206518799E8, Horse, hashp) -- Default Relationship
    Citizen.InvokeNative(0xCC97B29285B1DC3B, Horse, 1) -- Horse Mood
    Citizen.InvokeNative(0x028F76B6E78246EB, cache.ped, Horse, 0) -- On Saddle
	Citizen.InvokeNative(0x283978A15512B2FE, Horse, true) -- Set random outfit variation / skin
	NetworkSetEntityInvisibleToNetwork(Horse, true)
end)

-- Delete Wagons --
RegisterNetEvent('QRCore:Command:DeleteVehicle', function()
    if cache.vehicle then
        SetEntityAsMissionEntity(cache.vehicle, true, true)
        DeleteVehicle(cache.vehicle)
    else
        local pcoords = GetEntityCoords(cache.ped)
        local vehicle, dist = QRCore.Functions.GetClosestVehicle(pcoords)
        if not vehicle or dist > 10 then return end

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end
end)

-- Delete Horse --
RegisterNetEvent('QRCore:Command:DeleteHorse', function()
    if cache.mount then
        SetEntityAsMissionEntity(cache.mount, true, true)
        DeletePed(cache.mount)
    else
        local pcoords = GetEntityCoords(cache.ped)
        local ped, dist = QRCore.Functions.GetClosestPed(pcoords)
        if not ped or dist > 10 then return end

        local model = GetEntityModel(ped)
        if not IsPedAPlayer(ped) and Citizen.InvokeNative(0x772A1969F649E902, model) == 1 then
            SetEntityAsMissionEntity(ped, true, true)
            DeletePed(ped)
        end
    end
end)

-- /Me /Do /Try Commands --
local RDisplaying = 1

RegisterNetEvent('QRCore:triggerDisplay')
AddEventHandler('QRCore:triggerDisplay', function(text, source, type, custom)
    local offset = 0.4 + (RDisplaying * 0.14)
    local target = GetPlayerFromServerId(source)
    if target == -1 then return end
    Display(GetPlayerFromServerId(source), text, offset, type, custom)
end)

function Display(mePlayer, text, offset, type, custom)
    local displaying = true
    local _type = type

    CreateThread(function()
        Wait(QRConfig.ShowDoMeTryLength * 1000)
        displaying = false
    end)
    CreateThread(function()
        RDisplaying = RDisplaying + 1
        while displaying do
            Wait(1)
            local coordsMe = GetPedBoneCoords(GetPlayerPed(mePlayer), 53684, 0.0, 0.0, 0.0)
            local coords = GetEntityCoords(cache.ped, false)
            local dist = #(coordsMe - coords)
            if dist < 15.0 then
                DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z'] + offset, text, _typ , custom)
            else
                if dist > 25 then
                    Wait(500)
                end
            end
        end
        RDisplaying = RDisplaying - 1
    end)
end

function DrawTexture(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11)
    if not HasStreamedTextureDictLoaded(textureStreamed) then
        RequestStreamedTextureDict(textureStreamed, false);
    else
        DrawSprite(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11);
    end
end

function DrawText3D(x, y, z, text, me, custom)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local _me = me
    if onScreen and ((_x > 0 and _x < 1) or (_y > 0 and _y < 1)) then
        SetTextScale(0.30, 0.30)
        SetTextFontForCurrentCommand(7)
        Citizen.InvokeNative(1758329440 & 0xFFFFFFFF, true)
        SetTextDropshadow(3, 0, 0, 0, 255)
        if _me == "me" then
            SetTextColor(255, 255, 255, 165)
        elseif _me == "do" then
            SetTextColor(145, 209, 144, 165)
        elseif _me == "try" then
            SetTextColor(32, 151, 247, 165)
        end
        SetTextCentre(1)
        onScreen, _x, _y = GetHudScreenPositionFromWorldPosition(x, y, z)
        DisplayText(str, _x, _y)
        if not custom then
            local factor = (string.len(text)) / 170
            local texture
            if string.len(text) < 20 then
                texture = "score_timer_bg_small"
            elseif string.len(text) < 40 then
                texture = "score_timer_large_black_bg"
            else
                texture = "score_timer_extralong"
            end
            DrawTexture("scoretimer_ink_backgrounds", texture, _x, _y + 0.0120, 0.015 + factor, 0.051, 0.0, 0, 0, 0, 180, false);
        end
    end
end
