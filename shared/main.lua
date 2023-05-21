QRShared = QRShared or {}

-- Keybinds --
local function GetKeys()
    return QRKeybinds
end

QRShared.GetKeys = GetKeys
exports('GetKeys', GetKeys)

local function GetKey(key)
    if type(key) == 'string' then
        if not QRKeybinds[key] then print('KEYBIND DOES NOT EXIST: '..key) return end
        return QRKeybinds[tostring(key)]
    elseif type(key) == 'table' then
        local xKeybinds = {}
        for x = 1, #key do
            if not QRKeybinds[key[x]] then print('KEYBIND DOES NOT EXIST: '..key[x]) return end
            xKeybinds[key[x]] = QRKeybinds[tostring(key[x])]
        end
        return xKeybinds
    end
end

QRShared.GetKey = GetKey
exports('GetKey', GetKey)

-- Items --
local function GetItems()
    return QRItems
end

QRShared.GetItems = GetItems
exports('GetItems', GetItems)

local function GetItem(item)
    if type(item) == 'string' then
        if not QRItems[item] then print('ITEM DOES NOT EXIST: '..item) return end
        return QRItems[item]
    elseif type(item) == 'table' then
        local xItems = {}
        for x = 1, #item do
            if not QRItems[item[x]] then print('ITEM DOES NOT EXIST: '..item[x]) return end
            xItems[item[x]] = QRItems[item[x]]
        end
        return xItems
    end
end

QRShared.GetItem = GetItem
exports('GetItem', GetItem)

-- Jobs --
local function GetJobs()
    return QRJobs
end

QRShared.GetJobs = GetJobs
exports('GetJobs', GetJobs)

local function GetJob(job)
    if type(job) == 'string' then
        if not QRJobs[job] then print('JOB DOES NOT EXIST: '..job) return end
        return QRJobs[job]
    elseif type(job) == 'table' then
        local xJobs = {}
        for x = 1, #job do
            if not QRJobs[job[x]] then print('JOB DOES NOT EXIST: '..job[x]) return end
            xJobs[job[x]] = QRJobs[job[x]]
        end
        return xJobs
    end
end

QRShared.GetJob = GetJob
exports('GetJob', GetJob)

-- Gangs --
local function GetGangs()
    return QRGangs
end

QRShared.GetGangs = GetGangs
exports('GetGangs', GetGangs)

local function GetGang(gang)
    if type(gang) == 'string' then
        if not QRGangs[gang] then print('GANG DOES NOT EXIST: '..gang) return end
        return QRGangs[gang]
    elseif type(gang) == 'table' then
        local xGangs = {}
        for x = 1, #gang do
            if not QRGangs[gang[x]] then print('GANG DOES NOT EXIST: '..gang[x]) return end
            xGangs[gang[x]] = QRGangs[gang[x]]
        end
        return xGangs
    end
end

QRShared.GetGang = GetGang
exports('GetGang', GetGang)

-- Horses --
local function GetHorses()
    return QRHorses
end

QRShared.GetHorses = GetHorses
exports('GetHorses', GetHorses)

local function GetHorse(horse)
    if type(horse) == 'string' then
        if not QRHorses[horse] then print('HORSE DOES NOT EXIST: '..horse) return end
        return QRHorses[horse]
    elseif type(horse) == 'table' then
        local xHorses = {}
        for x = 1, #horse do
            if not QRHorses[horse[x]] then print('HORSE DOES NOT EXIST: '..horse[x]) return end
            xHorses[horse[x]] = QRHorses[horse[x]]
        end
        return xHorses
    end
end

QRShared.GetHorse = GetHorse
exports('GetHorse', GetHorse)

-- Vehicles --
local function GetVehicles()
    return QRVehicles
end

QRShared.GetVehicles = GetVehicles
exports('GetVehicles', GetVehicles)

local function GetVehicle(vehicle)
    if type(vehicle) == 'string' then
        if not QRVehicles[vehicle] then print('VEHICLE DOES NOT EXIST: '..vehicle) return end
        return QRVehicles[vehicle]
    elseif type(vehicle) == 'table' then
        local xVehicles = {}
        for x = 1, #vehicle do
            if not QRVehicles[vehicle[x]] then print('VEHICLE DOES NOT EXIST: '..vehicle[x]) return end
            xVehicles[vehicle[x]] = QRVehicles[vehicle[x]]
        end
        return xVehicles
    end
end

QRShared.GetVehicle = GetVehicle
exports('GetVehicle', GetVehicle)

-- Weapons --
local function GetWeapons()
    return QRWeapons
end

QRShared.GetWeapons = GetWeapons
exports('GetWeapons', GetWeapons)

local function GetWeapon(weapon)
    if type(weapon) == 'string' then
        if not QRWeapons[weapon] then print('WEAPON DOES NOT EXIST: '..weapon) return end
        return QRWeapons[weapon]
    elseif type(weapon) == 'table' then
        local xWeapons = {}
        for x = 1, #weapon do
            if not QRWeapons[weapon[x]] then print('WEAPON DOES NOT EXIST: '..weapon[x]) return end
            xWeapons[weapon[x]] = QRWeapons[weapon[x]]
        end
        return xWeapons
    end
end

QRShared.GetWeapon = GetWeapon
exports('GetWeapon', GetWeapon)

-- Other Shared Functions --
local StringCharset = {}
local NumberCharset = {}

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

function QRShared.RandomStr(length)
    if length <= 0 then return '' end
    return QRShared.RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

function QRShared.RandomInt(length)
    if length <= 0 then return '' end
    return QRShared.RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end

function QRShared.SplitStr(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

function QRShared.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function QRShared.FirstToUpper(value)
    if not value then return nil end
    return (value:gsub("^%l", string.upper))
end

function QRShared.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function QRShared.ChangeVehicleExtra(vehicle, extra, enable)
    if DoesExtraExist(vehicle, extra) then
        if enable then
            SetVehicleExtra(vehicle, extra, false)
            if not IsVehicleExtraTurnedOn(vehicle, extra) then
                QRShared.ChangeVehicleExtra(vehicle, extra, enable)
            end
        else
            SetVehicleExtra(vehicle, extra, true)
            if IsVehicleExtraTurnedOn(vehicle, extra) then
                QRShared.ChangeVehicleExtra(vehicle, extra, enable)
            end
        end
    end
end

function QRShared.SetDefaultVehicleExtras(vehicle, config)
    -- Clear Extras
    for i = 1, 20 do
        if DoesExtraExist(vehicle, i) then
            SetVehicleExtra(vehicle, i, 1)
        end
    end

    for id, enabled in pairs(config) do
        QRShared.ChangeVehicleExtra(vehicle, tonumber(id), type(enabled) == 'boolean' and enabled or true)
    end
end

-- Backwards Compatability --
QRShared.StarterItems = QRConfig.StarterItems
QRShared.MaleNoGloves = QRConfig.MaleNoGloves
QRShared.FemaleNoGloves = QRConfig.FemaleNoGloves