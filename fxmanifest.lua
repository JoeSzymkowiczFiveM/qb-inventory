fx_version 'cerulean'
game 'gta5'

description 'Qbus:Inventory'

use_fxv2_oal 'yes'
lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
}

server_scripts {
	--'@oxmysql/lib/MySQL.lua',
	'@mongodb/lib/MongoDB.lua',
	"config.lua",
	"server/main.lua",
	--"server/weapons.lua",
	--"server/weapons_items.lua",
}

client_scripts {
	"config.lua",
	"client/main.lua",
	"client/crafting.lua",
	"client/weapons.lua",
	"client/bags.lua",
	"client/backitems.lua",
	"client/masks.lua",
	"client/targets.lua",
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
	'html/images/*.webp',
	'html/images/*.png',
	'html/images/*.jpg',
	'html/images/*.gif',
	'html/ammo_images/*.png',
	'html/attachment_images/*.png',
	'html/*.ttf',
}

-- exports {
--     'InInventory'
-- }