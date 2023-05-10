CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * QRCore.Config.UpdateInterval
            TriggerServerEvent('QRCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (QRCore.PlayerData.metadata.hunger <= 0 or QRCore.PlayerData.metadata.thirst <= 0) and not QRCore.PlayerData.metadata.isdead then
                local currentHealth = GetEntityHealth(cache.ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(cache.ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(QRCore.Config.StatusInterval)
    end
end)
