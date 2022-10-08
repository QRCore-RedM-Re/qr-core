QRCore = {}
QRCore.Config = QRConfig
QRCore.Shared = QRShared
QRCore.ClientCallbacks = {}
QRCore.ServerCallbacks = {}

exports('GetCoreObject', function()
    return QRCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local QRCore = exports['qr-core']:GetCoreObject()
