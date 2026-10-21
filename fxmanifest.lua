fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Philoduckcoding'
description 'Player blips toggle for ESX Legacy'
version '1.0.0'
contact 'moin@duckspace.ninja'

-- Shop: www.tebex.duckspace.ninja
dependency 'es_extended'

shared_script 'config.lua'
shared_script '@es_extended/imports.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'
