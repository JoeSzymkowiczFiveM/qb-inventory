local itemInfos = {}

--Functions
local function SetupAttachmentItemsInfo()
	itemInfos = {
		[1] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 20x, "
			.. SharedItems["steel"]["label"] .. ": 20x, "
			.. SharedItems["rubber"]["label"] .. ": 10x."
			},
		[2] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 165x, "
			.. SharedItems["steel"]["label"] .. ": 285x, "
			.. SharedItems["rubber"]["label"] .. ": 75x."
			},
		[3] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 190x, "
			.. SharedItems["steel"]["label"] .. ": 305x, "
			.. SharedItems["rubber"]["label"] .. ": 85x, "
			.. SharedItems["smg_extendedclip"]["label"] .. ": 1x."
			},
		[4] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 205x, "
			.. SharedItems["steel"]["label"] .. ": 340x, "
			.. SharedItems["rubber"]["label"] .. ": 110x, "
			.. SharedItems["smg_extendedclip"]["label"] .. ": 2x."
			},
		[5] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 230x, "
			.. SharedItems["steel"]["label"] .. ": 365x, "
			.. SharedItems["rubber"]["label"] .. ": 130x."
			},
		[6] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 255x, "
			.. SharedItems["steel"]["label"] .. ": 390x, "
			.. SharedItems["rubber"]["label"] .. ": 145x."
			},
		[7] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 270x, "
			.. SharedItems["steel"]["label"] .. ": 435x, "
			.. SharedItems["rubber"]["label"] .. ": 155x."
			},
		[8] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 300x, "
			.. SharedItems["steel"]["label"] .. ": 469x, "
			.. SharedItems["rubber"]["label"] .. ": 170x."
		},
	}

	local items = {}
	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		local itemInfo = SharedItems[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.AttachmentCrafting["items"] = items
end

local function GetAttachmentThresholdItems()
	SetupAttachmentItemsInfo()
	local items = {}
	local curRep = QBCore.Functions.GetPlayerData().metadata["craftingrep"]["weapons"] ~= nil and QBCore.Functions.GetPlayerData().metadata["craftingrep"]["weapons"] or 0

	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		if curRep >= Config.AttachmentCrafting["items"][k].threshold then
			items[k] = Config.AttachmentCrafting["items"][k]
		end
	end
	return items
end

local function SetupMechanicItemsInfo()
	itemInfos = {
		[1] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 5x, "
			.. SharedItems["steel"]["label"] .. ": 5x."
		},
		[2] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 8x, "
			.. SharedItems["steel"]["label"] .. ": 8x."
		},
		[3] = {
			costs = SharedItems["rubber"]["label"] .. ": 200x"
		},
		[4] = {
			costs = SharedItems["aluminum"]["label"] .. ": 200x, "
			.. SharedItems["steel"]["label"] .. ": 200x, "
			.. SharedItems["metalscrap"]["label"] .. ": 200x."
		},
		[5] = {
			costs = SharedItems["aluminum"]["label"] .. ": 125x, "
			.. SharedItems["steel"]["label"] .. ": 125x, "
			.. SharedItems["metalscrap"]["label"] .. ": 125x."
		},
		[6] = {
			costs = SharedItems["aluminum"]["label"] .. ": 200x, "
			.. SharedItems["steel"]["label"] .. ": 200x, "
			.. SharedItems["metalscrap"]["label"] .. ": 200x."
		},
		[7] = {
			costs = SharedItems["aluminum"]["label"] .. ": 400x, "
			.. SharedItems["steel"]["label"] .. ": 400x, "
			.. SharedItems["metalscrap"]["label"] .. ": 400x."
		},
		[8] = {
			costs = SharedItems["steel"]["label"] .. ": 500x, "
			.. SharedItems["metalscrap"]["label"] .. ": 500x."

		},
	}

	local items = {}
	for k, item in pairs(Config.MechanicCrafting["items"]) do
		local itemInfo = SharedItems[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.MechanicCrafting["items"] = items
end

local function GetMechanicThresholdItems()
	SetupMechanicItemsInfo()
	local items = {}
	local curRep = QBCore.Functions.GetPlayerData().metadata["craftingrep"]["mechanic"] ~= nil and QBCore.Functions.GetPlayerData().metadata["craftingrep"]["mechanic"] or 0
	for k, item in pairs(Config.MechanicCrafting["items"]) do
		if curRep >= Config.MechanicCrafting["items"][k].threshold then
			items[k] = Config.MechanicCrafting["items"][k]
		end
	end
	return items
end

local function ItemsToItemInfo()
	itemInfos = {
		[1] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 10x."
		},
		[2] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 30x, "
			..SharedItems["plastic"]["label"] .. ": 42x."
		},
		[3] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 30x, "
			..SharedItems["plastic"]["label"] .. ": 45x, "
			..SharedItems["aluminum"]["label"] .. ": 28x."
		},
		[4] = {
			costs = SharedItems["transmitter"]["label"] .. ": 1x, "
			..SharedItems["electronickit"]["label"] .. ": 2x, "
			..SharedItems["plastic"]["label"] .. ": 52x, "
			..SharedItems["steel"]["label"] .. ": 40x."
		},
		[5] = {costs = SharedItems["metalscrap"]["label"] .. ": 10x, "
			..SharedItems["plastic"]["label"] .. ": 50x, "
			..SharedItems["aluminum"]["label"] .. ": 30x, "
			..SharedItems["iron"]["label"] .. ": 17x, "
			..SharedItems["electronickit"]["label"] .. ": 1x."
		},
		[6] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 36x, "
			..SharedItems["steel"]["label"] .. ": 24x, "
			..SharedItems["aluminum"]["label"] .. ": 28x."}
			,
		[7] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 32x, "
			..SharedItems["steel"]["label"] .. ": 43x, "
			..SharedItems["plastic"]["label"] .. ": 61x."
		},
		[8] = {
			costs = SharedItems["metalscrap"]["label"] .. ": 50x, "
			..SharedItems["steel"]["label"] .. ": 37x, "
			..SharedItems["copper"]["label"] .. ": 26x."
		},
		[9] = {
			costs = SharedItems["glass"]["label"] .. ": 35, "
			..SharedItems["steel"]["label"] .. ": 65, " 
			..SharedItems["copper"]["label"] .. ": 95."
		},
		[10] = {
			costs = SharedItems["iron"]["label"] .. ": 33x, "
			..SharedItems["steel"]["label"] .. ": 44x, "
			..SharedItems["plastic"]["label"] .. ": 55x, "
			..SharedItems["aluminum"]["label"] .. ": 22x."
		},
		[11] = {
			costs = SharedItems["transmitter"]["label"] .. ": 1x, "
			..SharedItems["electronickit"]["label"] .. ": 1x, "
			..SharedItems["glass"]["label"] .. ": 10x, "
			..SharedItems["plastic"]["label"] .. ": 10, "
			..SharedItems["copper"]["label"] .. ": 10x."
		},
		[12] = {
			costs = SharedItems["transmitter"]["label"] .. ": 2x, "
			..SharedItems["electronickit"]["label"] .. ": 2x, "
			..SharedItems["screwdriverset"]["label"] .. ": 3x, "
			..SharedItems["plastic"]["label"] .. ": 50x, "
			..SharedItems["aluminum"]["label"] .. ": 100x."
		},
		[13] = {
			costs = SharedItems["iron"]["label"] .. ": 50x, "
			..SharedItems["steel"]["label"] .. ": 50x, "
			..SharedItems["screwdriverset"]["label"] .. ": 3x, "
			..SharedItems["advancedlockpick"]["label"] .. ": 2x."
		},
	}

	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		local itemInfo = SharedItems[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.CraftingItems = items
end

local function GetThresholdItems()
	ItemsToItemInfo()
	local items = {}
	local curRep = QBCore.Functions.GetPlayerData().metadata["craftingrep"]["general"] ~= nil and QBCore.Functions.GetPlayerData().metadata["craftingrep"]["general"] or 0

	for k, item in pairs(Config.CraftingItems) do
		if curRep >= Config.CraftingItems[k].threshold then
			items[k] = Config.CraftingItems[k]
		end
	end
	return items
end

RegisterNetEvent('qb-crafting:client:OpenCrafting')
AddEventHandler('qb-crafting:client:OpenCrafting', function(data)
    local PlayerPos = GetEntityCoords(cache.ped)
	local type = data.parameter
	local object = data.entity

	if type == "crafting" then
		if DoesEntityExist(object) then
			local crafting = {}
			crafting.label = "Crafting"
			crafting.items = GetThresholdItems()
			TriggerServerEvent("inventory:server:OpenInventory", type, math.random(1, 99), crafting)
		end
	elseif type == "attachment_crafting" then
		if #(PlayerPos - Config.AttachmentCrafting["coords"]) < 5.0 then
			local crafting = {}
			crafting.label = "Attachment Crafting"
			crafting.items = GetAttachmentThresholdItems()
			TriggerServerEvent("inventory:server:OpenInventory", type, math.random(1, 99), crafting)
		end
	elseif type == "mechanic_crafting" then
		for k, v in ipairs(Config.MechanicCrafting["coords"]) do
			if #(PlayerPos - v) < 5.0 then
				if PlayerJob.name == "mechanic" then
					local crafting = {}
					crafting.label = "Mechanic Crafting"
					crafting.items = GetMechanicThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", type, math.random(1, 99), crafting)
				else
					QBCore.Functions.Notify('You\'re not on duty..', 'error')
				end
				break
			end
		end
		
	end     
end)

--[[ function IsNearMechanicCrafting(PlayerPos)
	local response = false
	for k, v in ipairs(Config.MechanicCraftingLocations) do
		if #(PlayerPos - v) < 5.0 then
			response = true
		end
	end
	return response
end ]]