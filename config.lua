QRConfig = {}

QRConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
QRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
QRConfig.UpdateInterval = 5 -- how often to update player data in minutes
QRConfig.StatusInterval = 5000 -- how often to check hunger/thirst status in milliseconds

QRConfig.Money = {}
QRConfig.Money.MoneyTypes = { cash = 500, bank = 5000, bloodmoney = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
QRConfig.Money.DontAllowMinus = { 'cash', 'bloodmoney' } -- Money that is not allowed going in minus
QRConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck
QRConfig.Money.PayCheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management

QRConfig.Player = {}
QRConfig.Player.RevealMap = true
QRConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
QRConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
QRConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
}

QRConfig.Server = {} -- General server config
QRConfig.Server.Closed = false -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
QRConfig.Server.ClosedReason = "Server Closed" -- Reason message to display when people can't join the server
QRConfig.Server.Uptime = 0 -- Time the server has been up.
QRConfig.Server.Whitelist = false -- Enable or disable whitelist on the server
QRConfig.Server.WhitelistPermission = 'admin' -- Permission that's able to enter the server when the whitelist is on
QRConfig.Server.Discord = "" -- Discord invite link
QRConfig.Server.CheckDuplicateLicense = true -- Check for duplicate rockstar license on join
QRConfig.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

QRConfig.NotifyPosition = 'top-right' -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'