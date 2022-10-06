-- Single add job function which should only be used if you planning on adding a single job
exports('AddJob', function(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if QRCore.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    QRCore.Shared.Jobs[jobName] = job
    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1,'Jobs', jobName, job)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Jobs
exports('AddJobs', function(jobs)
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

        if QRCore.Shared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        QRCore.Shared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end)

-- Single add item
exports('AddItem', function(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if QRCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    QRCore.Shared.Items[itemName] = item
    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Items
exports('AddItems', function(items)
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

        if QRCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        QRCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end)

-- Single Add Gang
exports('AddGang', function(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end
    if QRCore.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    QRCore.Shared.Gangs[gangName] = gang
    TriggerClientEvent('QRCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Gangs
exports('AddGangs', function(gangs)
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

        if QRCore.Shared.Gangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end
        QRCore.Shared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QRCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('QRCore:Server:UpdateObject')
    return true, message, nil
end)