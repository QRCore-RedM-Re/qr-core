fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'qr-core'

shared_scripts {
    'config.lua',
    'shared/*.lua',
    'locale/en.lua',
    'locale/*.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/nativenotify.js',
    'client/drawtext.lua',
	'client/prompts.lua',
    'client/zones.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua',
    'server/loops.lua',
    'server/debug.lua'
}

dependency 'oxmysql'

lua54 'yes'
