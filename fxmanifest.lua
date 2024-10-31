fx_version 'cerulean'
game 'gta5'


author 'StevoScripts | steve'
description 'Advanced Portable Crafting System with props, blueprints and more!'
version '2.0.5'

shared_scripts {
  'config.lua',
  '@ox_lib/init.lua'
}

client_scripts {
  'resource/client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
	'resource/server.lua'
}

files {
  'locales/*.json'
}

dependencies {
  'ox_lib',
  'oxmysql',
}

lua54 'yes'
