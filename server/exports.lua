-- Add or change (a) method(s) in the QRCore.Functions table
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    QRCore.Functions[methodName] = handler

    TriggerEvent('QRCore:Server:UpdateObject')

    return true, "success"
end

QRCore.Functions.SetMethod = SetMethod
exports("SetMethod", SetMethod)

-- Add or change (a) field(s) in the QRCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= "string" then
        return false, "invalid_field_name"
    end

    QRCore[fieldName] = data

    TriggerEvent('QRCore:Server:UpdateObject')

    return true, "success"
end

QRCore.Functions.SetField = SetField
exports("SetField", SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if QRJobs[jobName] then
        return false, "job_exists"
    end

    QRJobs[jobName] = job

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if QRJobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        QRJobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end

QRCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not QRJobs[jobName] then
        return false, "job_not_exists"
    end

    QRJobs[jobName] = nil

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not QRJobs[jobName] then
        return false, "job_not_exists"
    end

    QRJobs[jobName] = job

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if QRItems[itemName] then
        return false, "item_exists"
    end

    QRItems[itemName] = item

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not QRItems[itemName] then
        return false, "item_not_exists"
    end
    QRItems[itemName] = item
    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if QRItems[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        QRItems[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end

QRCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not QRItems[itemName] then
        return false, "item_not_exists"
    end

    QRItems[itemName] = nil

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if QRGangs[gangName] then
        return false, "gang_exists"
    end

    QRGangs[gangName] = gang

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            message = "invalid_gang_name"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if QRGangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        QRGangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end

QRCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not QRGangs[gangName] then
        return false, "gang_not_exists"
    end

    QRGangs[gangName] = nil

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not QRGangs[gangName] then
        return false, "gang_not_exists"
    end

    QRGangs[gangName] = gang

    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end

QRCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(("%s called QRcore version check: %s"):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

QRCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        QRCore.Functions.GetIdentifier(playerId, 'license'),
        QRCore.Functions.GetIdentifier(playerId, 'discord'),
        QRCore.Functions.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', {discord = QRCore.Config.Server.Discord}))
    TriggerEvent("qr-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)
