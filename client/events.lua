-- Player load and unload handling
-- New method for checking if logged in across all scripts (optional)
-- if LocalPlayer.state['isLoggedIn'] then
local time = 7000 -- Duration of the display of the text : 1000ms = 1sec


RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    if QRConfig.Player.RevealMap then SetMinimapHideFow(true) end
end)

RegisterNetEvent('QRCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

-- Teleport Commands

RegisterNetEvent('QRCore:Command:TeleportToPlayer', function(coords) -- #MoneSuer | Fixed Teleport Command
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('QRCore:Command:TeleportToCoords', function(x, y, z, h) -- #MoneSuer | Fixed Teleport Command
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z)
end)

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


-- HORSE / WAGON

RegisterNetEvent('QRCore:Command:SpawnVehicle', function(WagonName)
    local ped = PlayerPedId()
    local hash = GetHashKey(WagonName)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1) -- Spawn the player onto "drivers" seat
	Citizen.InvokeNative(0x283978A15512B2FE, vehicle, true) -- Set random outfit variation / skin
	NetworkSetEntityInvisibleToNetwork(vehicle, true)
end)

RegisterNetEvent('QRCore:Command:SpawnHorse', function(HorseName)
    local ped = PlayerPedId()
    local horseModel = QRCore.Shared.Horses[HorseName]['model']
    local hash = GetHashKey(horseModel)
    local hashp = GetHashKey("PLAYER")
    if not IsModelInCdimage(horseModel) then return end
    RequestModel(horseModel)
    while not HasModelLoaded(horseModel) do
        Wait(0)
    end

    local Horse = CreatePed(horseModel, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    Citizen.InvokeNative(0xADB3F206518799E8, Horse, hashp) -- Relationship
    Citizen.InvokeNative(0xCC97B29285B1DC3B, Horse, 1) -- Horse Mood
    Citizen.InvokeNative(0x028F76B6E78246EB, ped, Horse, 0) -- On Saddle
	Citizen.InvokeNative(0x283978A15512B2FE, Horse, true) -- Set random outfit variation / skin
	NetworkSetEntityInvisibleToNetwork(Horse, true)
end)

RegisterNetEvent('QRCore:Command:DeleteVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    if veh ~= 0 then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
    else
        local pcoords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        for _, v in pairs(vehicles) do
            if #(pcoords - GetEntityCoords(v)) <= 5.0 then
                SetEntityAsMissionEntity(v, true, true)
                DeleteVehicle(v)
            end
        end
    end
end)

RegisterNetEvent('QRCore:Command:DeleteHorse', function()
    local ped = PlayerPedId()
    local pedcoords = GetEntityCoords(ped)
    local onmount = Citizen.InvokeNative(0x460BC76A0E10655E, ped)
    if onmount then
        local horse = QRCore.Functions.GetClosestPed(GetEntityCoords(ped))
        DeletePed(horse)
    else
        local pcoords = GetEntityCoords(ped)
        local horse = GetGamePool('CPed')
        for _, v in pairs(horse) do
            local horseModel = GetEntityModel(v)
            if #(GetEntityCoords(v) - pcoords) <= 5.0 and not IsPedAPlayer(v) and (Citizen.InvokeNative(0x772A1969F649E902, horseModel) == 1) then
                SetEntityAsMissionEntity(v, true, true)
				DeletePed(v)
				SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

-- Other stuff

RegisterNetEvent('QRCore:Player:SetPlayerData', function(val)
    QRCore.PlayerData = val
end)

RegisterNetEvent('QRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('QRCore:UpdatePlayer')
end)

RegisterNetEvent('QRCore:Notify', function(text, type, length)
    QRCore.Functions.Notify(text, type, length)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('QRCore:Client:UseItem', function(item)
    QRCore.Debug(string.format("%s triggered QRCore:Client:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qr-inventory for the right use on this event.", GetInvokingResource(), GetPlayerServerId(PlayerId())))
    QRCore.Debug(item)
end)

-- Callback Events --

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

-- Me command
local RDisplaying = 1

RegisterNetEvent('QRCore:triggerDisplay')
AddEventHandler('QRCore:triggerDisplay', function(text, source, type, custom)
    local offset = 0.4 + (RDisplaying * 0.14)
    local target = GetPlayerFromServerId(source)
    if target == -1 then
        return
    end
    Display(GetPlayerFromServerId(source), text, offset, type, custom)
end)

function Display(mePlayer, text, offset, type, custom)
    local displaying = true
    local _type = type

    Citizen.CreateThread(function()
        Wait(time)
        displaying = false
    end)
    Citizen.CreateThread(function()
        RDisplaying = RDisplaying + 1
        while displaying do
            Wait(1)
            local coordsMe = GetPedBoneCoords(GetPlayerPed(mePlayer), 53684, 0.0, 0.0, 0.0)
            local coords = GetEntityCoords(PlayerPedId(), false)
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
