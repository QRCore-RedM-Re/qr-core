-- Event Handler

AddEventHandler('playerDropped', function()
    local src = source
    if not QRCore.Players[src] then return end
    local Player = QRCore.Players[src]
    TriggerEvent('qr-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..')
    Player.Functions.Save()
    QRCore.Players[src] = nil
end)

local function IsPlayerBanned(source)
    local retval = false
    local message = ''
    local plicense = GetIdentifier(source, 'license')
    local result = MySQL.Sync.fetchSingle('SELECT * FROM bans WHERE license = ?', { plicense })
    if result then
        if os.time() < result.expire then
            retval = true
            local timeTable = os.date('*t', tonumber(result.expire))
            message = 'You have been banned from the server:\n' .. result[1].reason .. '\nYour ban expires ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
        else
            MySQL.Async.execute('DELETE FROM bans WHERE id = ?', { result[1].id })
        end
    end
    return retval, message
end

local function IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                local playerLicense = id
                if playerLicense == license then
                    return true
                end
            end
        end
    end
    return false
end

-- Player Connecting

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local license
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    -- mandatory wait!
    Wait(0)

    if QBConfig.ServerClosed then
        if not IsPlayerAceAllowed(player, 'whitelisted') then
            deferrals.done(QBConfig.ServerClosedReason)
        end
    end

    deferrals.update(string.format('Hello %s. Validating Your Rockstar License', name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- mandatory wait!
    Wait(2500)

    deferrals.update(string.format('Hello %s. We are checking if you are banned.', name))

    local isBanned, Reason = IsPlayerBanned(player)
    local isLicenseAlreadyInUse = IsLicenseInUse(license)

    Wait(2500)

    deferrals.update(string.format('Welcome %s to {Server Name}.', name))

    if not license then
        deferrals.done('No Valid Rockstar License Found')
    elseif isBanned then
        deferrals.done(Reason)
    elseif isLicenseAlreadyInUse then
        deferrals.done('Duplicate Rockstar License Found')
    else
        deferrals.done()
        if QBConfig.UseConnectQueue then
            Wait(1000)
            TriggerEvent('connectqueue:playerConnect', name, setKickReason, deferrals)
        end
    end
    --Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

-- Player

RegisterNetEvent('QRCore:UpdatePlayer', function()
    local Player = GetPlayer(source)
    if Player then
        local newHunger = Player.PlayerData.metadata['hunger'] - QBConfig.Player.HungerRate
        local newThirst = Player.PlayerData.metadata['thirst'] - QBConfig.Player.ThirstRate
        if newHunger <= 0 then
            newHunger = 0
        end
        if newThirst <= 0 then
            newThirst = 0
        end
        Player.Functions.SetMetaData('thirst', newThirst)
        Player.Functions.SetMetaData('hunger', newHunger)
        TriggerClientEvent('hud:client:UpdateNeeds', source, newHunger, newThirst)
        Player.Functions.Save()
    end
end)

RegisterNetEvent('QRCore:Server:SetMetaData', function(meta, data)
    local Player = GetPlayer(source)
    if meta == 'hunger' or meta == 'thirst' then
        if data > 100 then
            data = 100
        end
    end
    if Player then
        Player.Functions.SetMetaData(meta, data)
    end
    TriggerClientEvent('hud:client:UpdateNeeds', source, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)

RegisterNetEvent('QRCore:ToggleDuty', function()
    local Player = GetPlayer(source)
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('QRCore:Notify', source, 9, Lang:t('info.off_duty'), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('QRCore:Notify', source, 9, Lang:t('info.on_duty'), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
    end
    TriggerClientEvent('QRCore:Client:SetDuty', source, Player.PlayerData.job.onduty)
end)

-- Items
RegisterNetEvent('QRCore:Server:UseItem', function(item)
    if item and item.amount > 0 then
        if QRCore.UseableItems[item.name] then
            QRCore.UseableItems[item.name](source, item)
        end
    end
end)

RegisterNetEvent('QRCore:Server:RemoveItem', function(itemName, amount, slot)
    local Player = GetPlayer(source)
    Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterNetEvent('QRCore:Server:AddItem', function(itemName, amount, slot, info)
    local Player = GetPlayer(source)
    Player.Functions.AddItem(itemName, amount, slot, info)
end)

-- Xp Events

RegisterNetEvent('QRCore:Player:SetLevel', function(source, skill)
	local Player = GetPlayer(source)
	local Skill = tostring(skill)
	local currentXp = Player.PlayerData.metadata["xp"][Skill]
	local Level = 0
	for k, v in pairs(QBConfig.Levels[Skill]) do
		if currentXp >= v then
			Player.PlayerData.metadata["levels"][Skill] = k
		end
	end
end)

RegisterNetEvent('QRCore:Player:GiveXp', function(source, skill, amount) -- adding QRCore xp if you dont want to import the playerdata or for standalone scripts
	local Player = GetPlayer(source)
	if Player then
		if Player.PlayerData.metadata["xp"][skill] then
			Player.Functions.AddXp(skill, amount)
		end
	end
end)

RegisterNetEvent('QRCore:Player:RemoveXp', function(source, skill, amount) -- removing QRCore xp if you dont want to import the playerdata or for standalone scripts
	local Player = GetPlayer(source)
	if Player then
		if Player.PlayerData.metadata["xp"][skill] then
			Player.Functions.RemoveXp(skill, amount)
		end
	end
end)

RegisterNetEvent('QRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('QRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

CreateCallback('QRCore:HasItem', function(source, cb, items, amount)
    local retval = false
    local Player = GetPlayer(source)
    if Player then
        if type(items) == 'table' then
            local count = 0
            local finalcount = 0
            for k, v in pairs(items) do
                if type(k) == 'string' then
                    finalcount = 0
                    for i, _ in pairs(items) do
                        if i then
                            finalcount = finalcount + 1
                        end
                    end
                    local item = Player.Functions.GetItemByName(k)
                    if item then
                        if item.amount >= v then
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                else
                    finalcount = #items
                    local item = Player.Functions.GetItemByName(v)
                    if item then
                        if amount then
                            if item.amount >= amount then
                                count = count + 1
                                if count == finalcount then
                                    retval = true
                                end
                            end
                        else
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                end
            end
        else
            local item = Player.Functions.GetItemByName(items)
            if item then
                if amount then
                    if item.amount >= amount then
                        retval = true
                    end
                else
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)
