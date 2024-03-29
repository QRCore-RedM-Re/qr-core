QRCore.Functions = {}

-- Player

function QRCore.Functions.GetPlayerData(cb)
    if not cb then return QRCore.PlayerData end
    cb(QRCore.PlayerData)
end

function QRCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity)
    return vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

function QRCore.Functions.HasItem(items, amount)
    return exports['qr-inventory']:HasItem(items, amount)
end

-- Utility
function QRCore.Functions.DrawText(x, y, width, height, scale, r, g, b, a, text)
    -- Use local function instead
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function QRCore.Functions.DrawText3D(x, y, z, text)
    local onScreen, _x , _y = GetScreenCoordFromWorldCoord(x, y, z)

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str, _x, _y)
    local factor = (string.len(text)) / 150
end

QRCore.Functions.RequestAnimDict = lib.requestAnimDict

function QRCore.Functions.PlayAnim(animDict, animName, upperbodyOnly, duration)
    local flags = upperbodyOnly and 16 or 0
    local runTime = duration or -1
    QRCore.Functions.RequestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animName, 8.0, 1.0, runTime, flags, 0.0, false, false, true)
    RemoveAnimDict(animDict)
end

QRCore.Functions.LoadModel = lib.requestModel

QRCore.Functions.LoadAnimSet = lib.requestAnimSet

RegisterNUICallback('getNotifyConfig', function(_, cb)
    cb(QRCore.Config.Notify)
end)

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType|DeprecatedNotificationType informs default styling. Defaults to 'inform'.
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000.
function QRCore.Functions.Notify(text, notifyType, duration)
    notifyType = notifyType or 'inform'
    if notifyType == 'primary' then notifyType = 'inform' end
    duration = duration or 5000
    local position = QRConfig.NotifyPosition
    if type(text) == "table" then
        local title = text.text or 'Placeholder'
        local description = text.caption or 'Placeholder'
        lib.notify({ title = title, description = description, duration = duration, type = notifyType, position = position})
    else
        lib.notify({ description = text, duration = duration, type = notifyType, position = position})
    end
end

-- Use Native Notifications --
function QRCore.Functions.LoadTexture(dict)
    local callback = false
    if Citizen.InvokeNative(0x7332461FC59EB7EC, dict) then
        lib.requestStreamedTextureDict(dict, 100)
        callback = true
    end
    return callback
end

-- Native Notifications --
function QRCore.Functions.NativeNotify(id, text, duration, subtext, dict, icon, color)
    local display = tostring(text) or 'Placeholder'
	local subdisplay = tostring(subtext) or 'Placeholder'
	local length = tonumber(duration) or 4000
	local dictionary = tostring(dict) or 'generic_textures'
	local image = tostring(icon) or 'tick'
	local colour = tostring(color) or 'COLOR_WHITE'

    local notifications = {
        [1] = function() return exports['qr-core']:ShowTooltip(display, length) end,
        [2] = function() return exports['qr-core']:DisplayRightText(display, length) end,
        [3] = function() return exports['qr-core']:ShowObjective(display, length) end,
        [4] = function() return exports['qr-core']:ShowBasicTopNotification(display, length) end,
        [5] = function() return exports['qr-core']:ShowSimpleCenterText(display, length) end,
        [6] = function() return exports['qr-core']:ShowLocationNotification(display, subdisplay, length) end,
        [7] = function() return exports['qr-core']:ShowTopNotification(display, subdisplay, length) end,
        [8] = function() if not QRCore.Functions.LoadTexture(dictionary) then QRCore.Functions.LoadTexture('generic_textures') end
            return exports['qr-core']:ShowAdvancedLeftNotification(display, subdisplay, dictionary, image, length) end,
        [9] = function() if not QRCore.Functions.LoadTexture(dictionary) then QRCore.Functions.LoadTexture('generic_textures') end
            return exports['qr-core']:ShowAdvancedRightNotification(display, dictionary, image, colour, length) end
    }

    if not notifications[id] then
        print('Invalid Notify ID')
        return nil
    else
        return notifications[id]()
    end
end

function QRCore.Debug(resource, obj, depth)
    TriggerServerEvent('QRCore:DebugSomething', resource, obj, depth)
end

-- Callback Functions --

-- Client Callback
function QRCore.Functions.CreateClientCallback(name, cb)
    QRCore.ClientCallbacks[name] = cb
end

function QRCore.Functions.TriggerClientCallback(name, cb, ...)
    if not QRCore.ClientCallbacks[name] then return end
    QRCore.ClientCallbacks[name](cb, ...)
end

-- Server Callback
function QRCore.Functions.TriggerCallback(name, cb, ...)
    QRCore.ServerCallbacks[name] = cb
    TriggerServerEvent('QRCore:Server:TriggerCallback', name, ...)
end

function QRCore.Functions.Progressbar(_, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        disable = {
            move = disableControls?.disableMovement,
            car = disableControls?.disableCarMovement,
            combat = disableControls?.disableCombat,
            mouse = disableControls?.disableMouse,
        },
        anim = {
            dict = animation?.animDict,
            clip = animation?.anim,
            flags = animation?.flags
        },
        prop = {
            model = prop?.model,
            pos = prop?.coords,
            rot = prop?.rotation,
        },
    }) then
        if onFinish then
            onFinish()
        end
    else
        if onCancel then
            onCancel()
        end
    end
end

-- Getters

function QRCore.Functions.GetVehicles()
    return GetGamePool('CVehicle')
end

function QRCore.Functions.GetObjects()
    return GetGamePool('CObject')
end

function QRCore.Functions.GetPlayers()
    return GetActivePlayers()
end

function QRCore.Functions.GetPeds(ignoreList)
    local pedPool = GetGamePool('CPed')
    local peds = {}
    ignoreList = ignoreList or {}
    for i = 1, #pedPool, 1 do
        local found = false
        for j = 1, #ignoreList, 1 do
            if ignoreList[j] == pedPool[i] then
                found = true
            end
        end
        if not found then
            peds[#peds + 1] = pedPool[i]
        end
    end
    return peds
end

function QRCore.Functions.GetClosestPed(coords, ignoreList)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local ped, pedCoords = lib.getClosestPed(coords, 50)
    local closestDistance = pedCoords and #(pedCoords - coords) or nil
    return ped, closestDistance
end

function QRCore.Functions.IsWearingGloves()
    local armIndex = GetPedDrawableVariation(cache.ped, 3)
    local model = GetEntityModel(cache.ped)
    if model == `mp_m_freemode_01` then
        if QRConfig.MaleNoGloves[armIndex] then
            return false
        end
    else
        if QRConfig.FemaleNoGloves[armIndex] then
            return false
        end
    end
    return true
end

function QRCore.Functions.GetClosestPlayer(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local playerId, _, playerCoords = lib.getClosestPlayer(coords, 50, false)
    local closestDistance = playerCoords and #(playerCoords - coords) or nil
    return playerId, closestDistance
end

function QRCore.Functions.GetPlayersFromCoords(coords, distance)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local players = lib.getNearbyPlayers(coords, distance or 5, true)

    -- This is for backwards compatability as beforehand it only returned the PlayerId, where Lib returns PlayerPed, PlayerId and PlayerCoords
    for i = 1, #players do
        players[i] = players[i].id
    end

    return players
end

function QRCore.Functions.GetClosestVehicle(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local vehicle, vehicleCoords = lib.getClosestVehicle(coords, 50, true)
    local closestDistance = vehicleCoords and #(vehicleCoords - coords) or nil
    return vehicle, closestDistance
end

function QRCore.Functions.GetClosestObject(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local closestObject, objectCoords = lib.getClosestObject(coords, 50)
    local closestDistance = objectCoords and #(objectCoords - coords) or nil
    return closestObject, closestDistance
end

function QRCore.Functions.GetClosestBone(entity, list)
    local playerCoords, bone, coords, distance = GetEntityCoords(cache.ped)
    for _, element in pairs(list) do
        local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
        local boneDistance = #(playerCoords - boneCoords)
        if not coords then
            bone, coords, distance = element, boneCoords, boneDistance
        elseif distance > boneDistance then
            bone, coords, distance = element, boneCoords, boneDistance
        end
    end
    if not bone then
        bone = {id = GetEntityBoneIndexByName(entity, "bodyshell"), type = "remains", name = "bodyshell"}
        coords = GetWorldPositionOfEntityBone(entity, bone.id)
        distance = #(coords - playerCoords)
    end
    return bone, coords, distance
end

function QRCore.Functions.GetBoneDistance(entity, boneType, boneIndex)
    local bone
    if boneType == 1 then
        bone = GetPedBoneIndex(entity, boneIndex)
    else
        bone = GetEntityBoneIndexByName(entity, boneIndex)
    end
    local boneCoords = GetWorldPositionOfEntityBone(entity, bone)
    local playerCoords = GetEntityCoords(cache.ped)
    return #(boneCoords - playerCoords)
end

function QRCore.Functions.AttachProp(ped, model, boneId, x, y, z, xR, yR, zR, vertex)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    local bone = GetPedBoneIndex(ped, boneId)
    QRCore.Functions.LoadModel(modelHash)
    local prop = CreateObject(modelHash, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(prop, ped, bone, x, y, z, xR, yR, zR, 1, 1, 0, 1, not vertex and 2 or 0, 1)
    SetModelAsNoLongerNeeded(modelHash)
    return prop
end

-- Vehicle

function QRCore.Functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelInCdimage(model) then return end
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    isnetworked = isnetworked == nil or isnetworked
    QRCore.Functions.LoadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then TaskWarpPedIntoVehicle(cache.ped, veh, -1) end
    if cb then cb(veh) end
end

function QRCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function QRCore.Functions.GetPlate(vehicle)
    if vehicle == 0 then return end
    return QRCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
end

function QRCore.Functions.GetVehicleLabel(vehicle)
    if vehicle == nil or vehicle == 0 then return end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

function QRCore.Functions.SpawnClear(coords, radius)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    local vehicles = GetGamePool('CVehicle')
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if distance <= radius then
            closeVeh[#closeVeh + 1] = vehicles[i]
        end
    end
    if #closeVeh > 0 then return false end
    return true
end

QRCore.Functions.GetVehicleProperties = lib.getVehicleProperties

QRCore.Functions.SetVehicleProperties = lib.setVehicleProperties

QRCore.Functions.LoadParticleDictionary = lib.requestNamedPtfxAsset

function QRCore.Functions.StartParticleAtCoord(dict, ptName, looped, coords, rot, scale, alpha, color, duration)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    QRCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    SetPtfxAssetNextCall(dict)
    local particleHandle
    if looped then
        particleHandle = StartParticleFxLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)
        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end
        SetParticleFxLoopedAlpha(particleHandle, alpha or 10.0)
        if duration then
            Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        StartParticleFxNonLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)
    end
    return particleHandle
end

function QRCore.Functions.StartParticleOnEntity(dict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration)
    QRCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    local particleHandle, boneID
    if bone and GetEntityType(entity) == 1 then
        boneID = GetPedBoneIndex(entity, bone)
    elseif bone then
        boneID = GetEntityBoneIndexByName(entity, bone)
    end
    if looped then
        if bone then
            particleHandle = StartParticleFxLoopedOnEntityBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            particleHandle = StartParticleFxLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end
        if evolution then
            SetParticleFxLoopedEvolution(particleHandle, evolution.name, evolution.amount, false)
        end
        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end
        SetParticleFxLoopedAlpha(particleHandle, alpha)
        if duration then
            Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        if bone then
            StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end
    end
    return particleHandle
end

function QRCore.Functions.GetStreetNametAtCoords(coords)
    local streetname1, streetname2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return { main = GetStreetNameFromHashKey(streetname1), cross = GetStreetNameFromHashKey(streetname2) }
end

function QRCore.Functions.GetZoneAtCoords(coords)
    return GetLabelText(GetNameOfZone(coords))
end

function QRCore.Functions.GetCardinalDirection(entity)
    entity = DoesEntityExist(entity) and entity or cache.ped
    if DoesEntityExist(entity) then
        local heading = GetEntityHeading(entity)
        if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
            return "North"
        elseif (heading >= 45 and heading < 135) then
            return "West"
        elseif (heading >= 135 and heading < 225) then
            return "South"
        elseif (heading >= 225 and heading < 315) then
            return "East"
        end
    else
        return "Cardinal Direction Error"
    end
end

function QRCore.Functions.GetCurrentTime()
    local obj = {}
    obj.min = GetClockMinutes()
    obj.hour = GetClockHours()

    if obj.hour <= 12 then
        obj.ampm = "AM"
    elseif obj.hour >= 13 then
        obj.ampm = "PM"
        obj.formattedHour = obj.hour - 12
        obj.hour = obj.formattedHour
    end

    if obj.min <= 9 then
        obj.formattedMin = "0" .. obj.min
        obj.min = obj.formattedMin
    end

    obj.time = (obj.hour..":"..obj.min.." "..obj.ampm)

    return obj
end

function QRCore.Functions.GetTemperature()
	-- Get Temperatures
	local UseMetric = ShouldUseMetricTemperature()
	local temperature
	local temperatureUnit
    local playerCoords = GetEntityCoords(cache.ped)

	if UseMetric then
		temperature = math.floor(GetTemperatureAtCoords(playerCoords))
		temperatureUnit = 'C'
	else
		temperature = math.floor(GetTemperatureAtCoords(playerCoords) * 9/5 + 32)
		temperatureUnit = 'F'
	end

	return string.format('%d °%s', temperature, temperatureUnit)
end

function QRCore.Functions.GetGroundZCoord(coords)
    if not coords then return end

    local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
    if retval then
        return vector3(coords.x, coords.y, groundZ)
    else
        print('Couldn\'t find Ground Z Coordinates given 3D Coordinates', coords)
        return coords
    end
end
