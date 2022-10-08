QRCore.Commands = {}
QRCore.Commands.List = {}
QRCore.Commands.IgnoreList = { -- Ignore old perm levels while keeping backwards compatibility
    ['god'] = true, -- We don't need to create an ace because god is allowed all commands
    ['user'] = true -- We don't need to create an ace because builtin.everyone
}

CreateThread(function() -- Add ace to node for perm checking
    local permissions = QRConfig.Server.Permissions
    for i=1, #permissions do
        local permission = permissions[i]
        ExecuteCommand(('add_ace QRcore.%s %s allow'):format(permission, permission))
    end
end)

-- Register & Refresh Commands

function QRCore.Commands.Add(name, help, arguments, argsrequired, callback, permission, ...)
    local restricted = true -- Default to restricted for all commands
    if not permission then permission = 'user' end -- some commands don't pass permission level
    if permission == 'user' then restricted = false end -- allow all users to use command

    RegisterCommand(name, function(source, args, rawCommand) -- Register command within fivem
        if argsrequired and #args < #arguments then
            return TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", Lang:t("error.missing_args2")}
            })
        end
        callback(source, args, rawCommand)
    end, restricted)

    local extraPerms = ... and table.pack(...) or nil
    if extraPerms then
        extraPerms[extraPerms.n + 1] = permission -- The `n` field is the number of arguments in the packed table
        extraPerms.n += 1
        permission = extraPerms
        for i = 1, permission.n do
            if not QRCore.Commands.IgnoreList[permission[i]] then -- only create aces for extra perm levels
                ExecuteCommand(('add_ace QRcore.%s command.%s allow'):format(permission[i], name))
            end
        end
        permission.n = nil
    else
        permission = tostring(permission:lower())
        if not QRCore.Commands.IgnoreList[permission] then -- only create aces for extra perm levels
            ExecuteCommand(('add_ace QRcore.%s command.%s allow'):format(permission, name))
        end
    end

    QRCore.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function QRCore.Commands.Refresh(source)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(QRCore.Commands.List) do
            local hasPerm = IsPlayerAceAllowed(tostring(src), 'command.'..command)
            if hasPerm then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            else
                TriggerClientEvent('chat:removeSuggestion', src, '/'..command)
            end
        end
        TriggerClientEvent('chat:addSuggestions', src, suggestions)
    end
end

-- Teleport
QRCore.Commands.Add('tp', Lang:t("command.tp.help"), { { name = Lang:t("command.tp.params.x.name"), help = Lang:t("command.tp.params.x.help") }, { name = Lang:t("command.tp.params.y.name"), help = Lang:t("command.tp.params.y.help") }, { name = Lang:t("command.tp.params.z.name"), help = Lang:t("command.tp.params.z.help") } }, false, function(source, args)
    if args[1] and not args[2] and not args[3] then
        if tonumber(args[1]) then
        local target = GetPlayerPed(tonumber(args[1]))
        if target ~= 0 then
            local coords = GetEntityCoords(target)
            TriggerClientEvent('QRCore:Command:TeleportToPlayer', source, coords)
        else
            TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
        end
    else
            local location = QRShared.Locations[args[1]]
            if location then
                TriggerClientEvent('QRCore:Command:TeleportToCoords', source, location.x, location.y, location.z, location.w)
            else
                TriggerClientEvent('QRCore:Notify', source, Lang:t('error.location_not_exist'), 'error')
            end
        end
    else
        if args[1] and args[2] and args[3] then
            local x = tonumber((args[1]:gsub(",",""))) + .0
            local y = tonumber((args[2]:gsub(",",""))) + .0
            local z = tonumber((args[3]:gsub(",",""))) + .0
            if x ~= 0 and y ~= 0 and z ~= 0 then
                TriggerClientEvent('QRCore:Command:TeleportToCoords', source, x, y, z)
            else
                TriggerClientEvent('QRCore:Notify', source, Lang:t('error.wrong_format'), 'error')
            end
        else
            TriggerClientEvent('QRCore:Notify', source, Lang:t('error.missing_args'), 'error')
        end
    end
end, 'admin')

QRCore.Commands.Add('tpm', Lang:t("command.tpm.help"), {}, false, function(source)
    TriggerClientEvent('QRCore:Command:GoToMarker', source)
end, 'admin')

QRCore.Commands.Add('togglepvp', Lang:t("command.togglepvp.help"), {}, false, function()
    QRConfig.Server.PVP = not QRConfig.Server.PVP
    TriggerClientEvent('QRCore:Client:PvpHasToggled', -1, QRConfig.Server.PVP)
end, 'admin')

-- Permissions

QRCore.Commands.Add('addpermission', Lang:t("command.addpermission.help"), { { name = Lang:t("command.addpermission.params.id.name"), help = Lang:t("command.addpermission.params.id.help") }, { name = Lang:t("command.addpermission.params.permission.name"), help = Lang:t("command.addpermission.params.permission.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        QRCore.Functions.AddPermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

QRCore.Commands.Add('removepermission', Lang:t("command.removepermission.help"), { { name = Lang:t("command.removepermission.params.id.name"), help = Lang:t("command.removepermission.params.id.help") }, { name = Lang:t("command.removepermission.params.permission.name"), help = Lang:t("command.removepermission.params.permission.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        QRCore.Functions.RemovePermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

-- Open & Close Server

QRCore.Commands.Add('openserver', Lang:t("command.openserver.help"), {}, false, function(source)
    if not QRCore.Config.Server.Closed then
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.server_already_open'), 'error')
        return
    end
    if QRCore.Functions.HasPermission(source, 'admin') then
        QRCore.Config.Server.Closed = false
        TriggerClientEvent('QRCore:Notify', source, Lang:t('success.server_opened'), 'success')
    else
        QRCore.Functions.Kick(source, Lang:t("error.no_permission"), nil, nil)
    end
end, 'admin')

QRCore.Commands.Add('closeserver', Lang:t("command.closeserver.help"), {{ name = Lang:t("command.closeserver.params.reason.name"), help = Lang:t("command.closeserver.params.reason.help")}}, false, function(source, args)
    if QRCore.Config.Server.Closed then
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.server_already_closed'), 'error')
        return
    end
    if QRCore.Functions.HasPermission(source, 'admin') then
        local reason = args[1] or 'No reason specified'
        QRCore.Config.Server.Closed = true
        QRCore.Config.Server.ClosedReason = reason
        for k in pairs(QRCore.Players) do
            if not QRCore.Functions.HasPermission(k, QRCore.Config.Server.WhitelistPermission) then
                QRCore.Functions.Kick(k, reason, nil, nil)
            end
        end
        TriggerClientEvent('QRCore:Notify', source, Lang:t('success.server_closed'), 'success')
    else
        QRCore.Functions.Kick(source, Lang:t("error.no_permission"), nil, nil)
    end
end, 'admin')

-- Vehicle

QRCore.Commands.Add('car', Lang:t("command.car.help"), {{ name = Lang:t("command.car.params.model.name"), help = Lang:t("command.car.params.model.help") }}, true, function(source, args)
    TriggerClientEvent('QRCore:Command:SpawnVehicle', source, args[1])
end, 'admin')

QRCore.Commands.Add('dv', Lang:t("command.dv.help"), {}, false, function(source)
    TriggerClientEvent('QRCore:Command:DeleteVehicle', source)
end, 'admin')

-- Money

QRCore.Commands.Add('givemoney', Lang:t("command.givemoney.help"), { { name = Lang:t("command.givemoney.params.id.name"), help = Lang:t("command.givemoney.params.id.help") }, { name = Lang:t("command.givemoney.params.moneytype.name"), help = Lang:t("command.givemoney.params.moneytype.help") }, { name = Lang:t("command.givemoney.params.amount.name"), help = Lang:t("command.givemoney.params.amount.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

QRCore.Commands.Add('setmoney', Lang:t("command.setmoney.help"), { { name = Lang:t("command.setmoney.params.id.name"), help = Lang:t("command.setmoney.params.id.help") }, { name = Lang:t("command.setmoney.params.moneytype.name"), help = Lang:t("command.setmoney.params.moneytype.help") }, { name = Lang:t("command.setmoney.params.amount.name"), help = Lang:t("command.setmoney.params.amount.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Job

QRCore.Commands.Add('job', Lang:t("command.job.help"), {}, false, function(source)
    local PlayerJob = QRCore.Functions.GetPlayer(source).PlayerData.job
    TriggerClientEvent('QRCore:Notify', source, Lang:t('info.job_info', {value = PlayerJob.label, value2 = PlayerJob.grade.name, value3 = PlayerJob.onduty}))
end, 'user')

QRCore.Commands.Add('setjob', Lang:t("command.setjob.help"), { { name = Lang:t("command.setjob.params.id.name"), help = Lang:t("command.setjob.params.id.help") }, { name = Lang:t("command.setjob.params.job.name"), help = Lang:t("command.setjob.params.job.help") }, { name = Lang:t("command.setjob.params.grade.name"), help = Lang:t("command.setjob.params.grade.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Gang

QRCore.Commands.Add('gang', Lang:t("command.gang.help"), {}, false, function(source)
    local PlayerGang = QRCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('QRCore:Notify', source, Lang:t('info.gang_info', {value = PlayerGang.label, value2 = PlayerGang.grade.name}))
end, 'user')

QRCore.Commands.Add('setgang', Lang:t("command.setgang.help"), { { name = Lang:t("command.setgang.params.id.name"), help = Lang:t("command.setgang.params.id.help") }, { name = Lang:t("command.setgang.params.gang.name"), help = Lang:t("command.setgang.params.gang.help") }, { name = Lang:t("command.setgang.params.grade.name"), help = Lang:t("command.setgang.params.grade.help") } }, true, function(source, args)
    local Player = QRCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QRCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Out of Character Chat

QRCore.Commands.Add('ooc', Lang:t("command.ooc.help"), {}, false, function(source, args)
    local message = table.concat(args, ' ')
    local Players = QRCore.Functions.GetPlayers()
    local Player = QRCore.Functions.GetPlayer(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for _, v in pairs(Players) do
        if v == source then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 0, 0, 255},
                multiline = true,
                args = {'OOC | '.. GetPlayerName(source), message}
            })
        elseif #(playerCoords - GetEntityCoords(GetPlayerPed(v))) < 20.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 0, 0, 255},
                multiline = true,
                args = {'OOC | '.. GetPlayerName(source), message}
            })
        elseif QRCore.Functions.HasPermission(v, 'admin') then
            if QRCore.Functions.IsOptin(v) then
                TriggerClientEvent('chat:addMessage', v, {
                    color = { 0, 0, 255},
                    multiline = true,
                    args = {'Proxmity OOC | '.. GetPlayerName(source), message}
                })
                TriggerEvent('qr-log:server:CreateLog', 'ooc', 'OOC', 'white', '**' .. GetPlayerName(source) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. source .. ') **Message:** ' .. message, false)
            end
        end
    end
end, 'user')

-- Me command

QRCore.Commands.Add('me', Lang:t("command.me.help"), {{name = Lang:t("command.me.params.message.name"), help = Lang:t("command.me.params.message.help")}}, false, function(source, args)
    if #args < 1 then TriggerClientEvent('QRCore:Notify', source, Lang:t('error.missing_args2'), 'error') return end
    local ped = GetPlayerPed(source)
    local pCoords = GetEntityCoords(ped)
    local msg = table.concat(args, ' '):gsub('[~<].-[>~]', '')
    local Players = QRCore.Functions.GetPlayers()
    for i=1, #Players do
        local Player = Players[i]
        local target = GetPlayerPed(Player)
        local tCoords = GetEntityCoords(target)
        if target == ped or #(pCoords - tCoords) < 20 then
            TriggerClientEvent('QRCore:Command:ShowMe3D', Player, source, msg)
        end
    end
end, 'user')

-- IDs

QRCore.Commands.Add("id", "Check Your ID #", {}, false, function(source)
	TriggerClientEvent('QRCore:Notify', source, "ID: "..source, 'primary')
end, 'user')

QRCore.Commands.Add("cid", "Check Your Citizen ID #", {}, false, function(source)
    local src = source
	local Player = QRCore.Functions.GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid
	TriggerClientEvent('QRCore:Notify', source, "Citizen ID: "..Playercid, 'primary')
end, 'user')
