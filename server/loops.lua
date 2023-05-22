-- Update Player Loop --
CreateThread(function()
    local timeout = 60000 * QRCore.Config.UpdateInterval
    while true do
        Wait(timeout)

        for src, Player in pairs(QRCore.Players) do
            if Player then
                local newHunger = Player.PlayerData.metadata.hunger - QRCore.Config.Player.HungerRate
                local newThirst = Player.PlayerData.metadata.thirst - QRCore.Config.Player.ThirstRate
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
            end
        end
    end
end)

-- Paycheck Loop --
CreateThread(function()
    while true do
        Wait(60000 * QRCore.Config.Money.PayCheckTimeOut)

        for _, Player in pairs(QRCore.Players) do
            if Player then
                local payment = QRJobs[Player.PlayerData.job.name]['grades'][tonumber(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (QRJobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if QRCore.Config.Money.PayCheckSociety then
                        local account = exports['qr-management']:GetAccount(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('QRCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                Player.Functions.AddMoney('bank', payment)
                                exports['qr-management']:RemoveMoney(Player.PlayerData.job.name, payment)
                                TriggerClientEvent('QRCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            Player.Functions.AddMoney('bank', payment)
                            TriggerClientEvent('QRCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        Player.Functions.AddMoney('bank', payment)
                        TriggerClientEvent('QRCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
end)