QBCore = exports['qb-core']:GetCoreObject()
local SharedItems = QBCore.Functions.GetSharedItems()
SharedWeapons = QBCore.Functions.GetSharedWeapons()

MongoDB.ready(function()
	MongoDB.Sync.delete({collection = 'stashes', query = { ["items"] = { ["$size"] = 0 } } })
end)

local Drops = {}
local Trunks = {}
local Gloveboxes = {}
local Stashes = {}
local ShopItems = {}

--[[ RegisterServerEvent("inventory:server:LoadDrops")
AddEventHandler('inventory:server:LoadDrops', function()
	local src = source
	if next(Drops) ~= nil then
		TriggerClientEvent("inventory:client:AddDropItem", -1, dropId, source)
		TriggerClientEvent("inventory:client:AddDropItem", src, Drops)
	end
end) ]]

local function fcomp_default(a, b)
	return a < b
end

local function SplitStr(str, delimiter)
	local result = { }
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
		result[#result+1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
	result[#result+1] = string.sub(str, from)
    return result
end

local StringCharset = {}
local NumberCharset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(StringCharset, string.char(i)) end
for i = 97, 122 do table.insert(StringCharset, string.char(i)) end

local function RandomStr(length)
	if length <= 0 then return '' end
    return RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

local function RandomInt(length)
	if length <= 0 then return '' end
    return RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end

local function bininsert(t, value, fcomp)
	-- Initialise compare function
	local fcomp = fcomp or fcomp_default
	--  Initialise numbers
	local iStart,iEnd,iMid,iState = 1,#t,1,0
	-- Get insert position
	while iStart <= iEnd do
		-- calculate middle
		iMid = math.floor( (iStart+iEnd)/2 )
		-- compare
		if fcomp( value,t[iMid] ) then
		iEnd,iState = iMid - 1,0
		else
		iStart,iState = iMid + 1,1
		end
	end
	table.insert(t, (iMid+iState), value)
	return (iMid+iState)
end

-- Stash Items
local function GetStashItems(stashId)
	local items = {}
	--local result = MySQL.query.await('SELECT * FROM stashitems WHERE stash = ?', {stashId})
	local result = MongoDB.Sync.findOne({collection = 'stashes', query = {stash = stashId}})
	if result[1] ~= nil then
		if result[1]["items"] ~= nil then
			--result[1].items = json.decode(result[1].items)
			if result[1]["items"] ~= nil then
				for k, item in pairs(result[1]["items"]) do
					local itemInfo = SharedItems[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"],
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						slot = item.slot,
						created = item.created ~= nil and item.created or nil,
						degrade = item.degrade ~= nil and item.degrade or itemInfo["degrade"],
					}
				end
			end
		end
	end
	return items
end

-- QBCore.Functions.CreateCallback('qb-inventory:server:GetStashItems', function(source, cb, stashId)
-- 	cb(GetStashItems(stashId))
-- end)

lib.callback.register('qb-inventory:server:GetStashItems', function(source, stashId)
    return GetStashItems(stashId)
end)

local function SaveStashItems(stashId, items)
	if Stashes[stashId].label == "Stash-None" or not items then return end

	for slot, item in pairs(items) do
		item.description = nil
	end

	--[[ MySQL.Async.insert('INSERT INTO stashitems (stash, items) VALUES (:stash, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['stash'] = stashId,
		['items'] = json.encode(items)
	}) ]]
	MongoDB.Sync.updateOne({collection = 'stashes' ,query = {stash = stashId}, update = { ["$set"] = { stash = stashId, items = items } }, options = { upsert = true }})
	
	Stashes[stashId].isOpen = false
end

local function AddToStash(stashId, slot, otherslot, itemName, amount, info, created)
	local amount = tonumber(amount)
	local ItemData = SharedItems[itemName]

	if not ItemData.unique then
		if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount + amount

			for i=1, amount do 
				if created[i] ~= nil then
					bininsert(Stashes[stashId].items[slot].created, created[i])
				end
			end
		else
			local itemInfo = SharedItems[itemName:lower()]

			local createdTable = {}
			for i=1, amount do
				if created[i] ~= nil then --created is nil in a scenario? wtf
					bininsert(createdTable, created[i])
				end
			end

			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
				created = createdTable,
				degrade = itemInfo["degrade"],
			}
		end
	else
		if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
			local itemInfo = SharedItems[itemName:lower()]
			Stashes[stashId].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = otherslot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		else
			local itemInfo = SharedItems[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		end
	end
end

local function RemoveFromStash(stashId, slot, itemName, amount)
	local amount = tonumber(amount)
	if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
		if Stashes[stashId].items[slot].amount > amount then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount - amount

			local newTable = {}
			for i=amount+1, #Stashes[stashId].items[slot].created do
				table.insert(newTable, Stashes[stashId].items[slot].created[i])
			end

			Stashes[stashId].items[slot].created = newTable
		else
			Stashes[stashId].items[slot] = nil
			if next(Stashes[stashId].items) == nil then
				Stashes[stashId].items = {}
			end
		end
	else
		Stashes[stashId].items[slot] = nil
		if Stashes[stashId].items == nil then
			Stashes[stashId].items[slot] = nil
		end
	end
end

-- Trunk items
function GetOwnedVehicleItems(plate)
	local items = {}
	--local result = MySQL.query.await('SELECT * FROM trunkitems WHERE plate = ?', {plate})
	local result = MongoDB.Sync.findOne({collection = 'vehicles', query = {plate = plate, ["trunk"] = { ["$exists"] = true } }})
	if result[1] ~= nil then
		if result[1]["trunk"] ~= nil then
			--result[1]["trunk"]["items"] = json.decode(result[1].items)
			if result[1]["trunk"]["items"] ~= nil then 
				for k, item in pairs(result[1]["trunk"]["items"]) do
					local itemInfo = SharedItems[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"], 
						type = itemInfo["type"], 
						unique = itemInfo["unique"], 
						useable = itemInfo["useable"], 
						image = itemInfo["image"],
						slot = item.slot,
						created = item.created ~= nil and item.created or nil,
						degrade = item.degrade ~= nil and item.degrade or itemInfo["degrade"],
					}
				end
			end
		end
	end
	return items
end

local function SaveOwnedVehicleItems(plate, items)
	if Trunks[plate].label ~= "Trunk-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			--[[ MySQL.Async.insert('INSERT INTO trunkitems (plate, items) VALUES (:plate, :items) ON DUPLICATE KEY UPDATE items = :items', {
				['plate'] = plate,
				['items'] = json.encode(items)
			}) ]]
			
			MongoDB.Sync.updateOne({collection = 'vehicles', query = {plate = plate}, update = { ["$set"] = { ["trunk.items"] = items } }, options = { upsert = true }})
			Trunks[plate].isOpen = false
		end
	end
end

local function AddToTrunk(plate, slot, otherslot, itemName, amount, info, created)
	local amount = tonumber(amount)
	local ItemData = SharedItems[itemName]

	if not ItemData.unique then
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount + amount
			
			for i=1, amount do 
				if created[i] ~= nil then
					bininsert(Trunks[plate].items[slot].created, created[i])
				end
			end
		else
			local itemInfo = SharedItems[itemName:lower()]

			local createdTable = {}
			for i=1, amount do
				if created[i] ~= nil then
					bininsert(createdTable, created[i])
				end
			end

			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
				created = createdTable,
				degrade = itemInfo["degrade"],
			}
		end
	else
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			local itemInfo = SharedItems[itemName:lower()]
			Trunks[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = otherslot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		else
			local itemInfo = SharedItems[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		end
	end
end

local function RemoveFromTrunk(plate, slot, itemName, amount)
	if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
		if Trunks[plate].items[slot].amount > amount then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount - amount

			local newTable = {}
			for i=amount+1, #Trunks[plate].items[slot].created do
				table.insert(newTable, Trunks[plate].items[slot].created[i])
			end

			Trunks[plate].items[slot].created = newTable
		else
			Trunks[plate].items[slot] = nil
			if next(Trunks[plate].items) == nil then
				Trunks[plate].items = {}
			end
		end
	else
		Trunks[plate].items[slot]= nil
		if Trunks[plate].items == nil then
			Trunks[plate].items[slot] = nil
		end
	end
end

-- Glovebox items
local function GetOwnedVehicleGloveboxItems(plate)
	local items = {}
	--local result = MySQL.query.await('SELECT * FROM gloveboxitems WHERE plate = ?', {plate})
	local result = MongoDB.Sync.findOne({collection = 'vehicles', query = {plate = plate, ["glovebox"] = { ["$exists"] = true } }})
	if result[1] ~= nil then 
		if result[1]["glovebox"]["items"] ~= nil then
			--result[1]["glovebox"]["items"] = json.decode(result[1].items)
			if result[1]["glovebox"]["items"] ~= nil then 
				for k, item in pairs(result[1]["glovebox"]["items"]) do
					local itemInfo = SharedItems[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"], 
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						slot = item.slot,
						created = item.created ~= nil and item.created or nil,
						degrade = item.degrade ~= nil and item.degrade or itemInfo["degrade"],
					}
				end
			end
		end
	end
	return items
end

local function SaveOwnedGloveboxItems(plate, items)
	if Gloveboxes[plate].label ~= "Glovebox-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			--[[ MySQL.Async.insert('INSERT INTO gloveboxitems (plate, items) VALUES (:plate, :items) ON DUPLICATE KEY UPDATE items = :items', {
				['plate'] = plate,
				['items'] = json.encode(items)
			}) ]]
			MongoDB.Sync.updateOne({collection = 'vehicles', query = {plate = plate}, update = { ["$set"] = { ["glovebox.items"] = items } }, options = { upsert = true }})
			Gloveboxes[plate].isOpen = false
		end
	end
end

local function AddToGlovebox(plate, slot, otherslot, itemName, amount, info, created)
	local amount = tonumber(amount)
	local ItemData = SharedItems[itemName]

	if not ItemData.unique then
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount + amount

			for i=1, amount do 
				if created[i] ~= nil then
					bininsert(Gloveboxes[plate].items[slot].created, created[i])
				end
			end
		else
			local itemInfo = SharedItems[itemName:lower()]

			local createdTable = {}
			for i=1, amount do
				if created[i] ~= nil then
					bininsert(createdTable, created[i])
				end
			end

			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				image = itemInfo["image"],
				slot = slot,
				created = createdTable,
				degrade = itemInfo["degrade"],
			}
		end
	else
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			local itemInfo = SharedItems[itemName:lower()]
			Gloveboxes[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				image = itemInfo["image"],
				slot = otherslot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		else
			local itemInfo = SharedItems[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				image = itemInfo["image"],
				slot = slot,
				created = created ~= nil and created or nil,
				degrade = itemInfo["degrade"],
			}
		end
	end
end

local function RemoveFromGlovebox(plate, slot, itemName, amount)
	if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
		if Gloveboxes[plate].items[slot].amount > amount then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount - amount

			local newTable = {}
			for i=amount+1, #Gloveboxes[plate].items[slot].created do
				table.insert(newTable, Gloveboxes[plate].items[slot].created[i])
			end

			Gloveboxes[plate].items[slot].created = newTable
		else
			Gloveboxes[plate].items[slot] = nil
			if next(Gloveboxes[plate].items) == nil then
				Gloveboxes[plate].items = {}
			end
		end
	else
		Gloveboxes[plate].items[slot]= nil
		if Gloveboxes[plate].items == nil then
			Gloveboxes[plate].items[slot] = nil
		end
	end
end

-- Drop items
local function AddToDrop(dropId, slot, itemName, amount, info, created)
	local amount = tonumber(amount)
	
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount + amount

		for i=1, amount do 
			if created[i] ~= nil then
				bininsert(Drops[dropId].items[slot].created, created[i])
			end
		end
	else
		local itemInfo = SharedItems[itemName:lower()]

		local createdTable = {}
		for i=1, amount do
			if created[i] ~= nil then
				bininsert(createdTable, created[i])
			end
		end

		Drops[dropId].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info ~= nil and info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = slot,
			id = dropId,
			created = createdTable,
			degrade = itemInfo["degrade"],
		}

	end
end

local function RemoveFromDrop(dropId, slot, itemName, amount)
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		if Drops[dropId].items[slot].amount > amount then
			Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount - amount

			local newTable = {}
			for i=amount+1, #Drops[dropId].items[slot].created do
				table.insert(newTable, Drops[dropId].items[slot].created[i])
			end

			Drops[dropId].items[slot].created = newTable
		else
			Drops[dropId].items[slot] = nil
			if next(Drops[dropId].items) == nil then
				Drops[dropId].items = {}
				--TriggerClientEvent("inventory:client:RemoveDropItem", -1, dropId)
			end
		end
	else
		Drops[dropId].items[slot] = nil
		if Drops[dropId].items == nil then
			Drops[dropId].items[slot] = nil
			--TriggerClientEvent("inventory:client:RemoveDropItem", -1, dropId)
		end
	end
end

local function CreateDropId()
	if Drops ~= nil then
		local id = math.random(10000, 99999)
		local dropid = id
		while Drops[dropid] ~= nil do
			id = math.random(10000, 99999)
			dropid = id
		end
		return dropid
	else
		local id = math.random(10000, 99999)
		local dropid = id
		return dropid
	end
end

local function CreateNewDrop(source, fromSlot, toSlot, itemAmount, fromcreated)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local itemData = Player.Functions.GetItemBySlot(fromSlot)
	local sourcePed = GetPlayerPed(src)
	local sourceCoords = GetEntityCoords(sourcePed)

	local coords = GetEntityCoords(GetPlayerPed(source))
	if Player.Functions.RemoveItem(itemData.name, itemAmount, itemData.slot) then
		TriggerClientEvent("inventory:client:CheckDroppedItem", src, itemData.name, fromSlot)
		local itemInfo = SharedItems[itemData.name:lower()]
		local dropId = CreateDropId()
		Drops[dropId] = {}
		Drops[dropId].coords = coords
		Drops[dropId].items = {}

		local newCreated = {}
		for i=1, itemAmount do
			if fromcreated[i] ~= nil then
				bininsert(newCreated, fromcreated[i])
			end
		end

		Drops[dropId].items[toSlot] = {
			name = itemInfo["name"],
			amount = itemAmount,
			info = itemData.info ~= nil and itemData.info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = toSlot,
			id = dropId,
			created = newCreated,
			degrade = itemInfo["degrade"],
		}
		--TriggerEvent("qb-log:server:CreateLog", "drop", "New Item Drop", "red", "**".. GetPlayerName(source) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..source.."*) dropped new item; name: **"..itemData.name.."**, amount: **" .. itemAmount .. "**")
		TriggerClientEvent("inventory:client:DropItemAnim", src)
		TriggerClientEvent("inventory:client:AddDropItem", -1, dropId, src, sourceCoords)
	else
		TriggerClientEvent("QBCore:Notify", src, "You don\'t have this item!", "error")
		return
	end
end

RegisterServerEvent('inventory:server:addTrunkItems', function(plate, items)
	Trunks[plate] = {}
	Trunks[plate].items = items
end)

RegisterServerEvent('inventory:server:combineItem', function(item, fromItem, toItem)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName(fromItem) ~= nil then
		if Player.Functions.GetItemByName(toItem) ~= nil then
			Player.Functions.AddItem(item, 1)
			Player.Functions.RemoveItem(fromItem, 1)
			Player.Functions.RemoveItem(toItem, 1)
		else
			TriggerClientEvent('QBCore:Notify', src, "You\'re missing " .. toItem, 'error')
			return false
		end
	else
		TriggerClientEvent('QBCore:Notify', src, "You\'re missing " .. fromItem, 'error')
		return false
	end
end)

RegisterServerEvent('inventory:server:CraftItems', function(itemName, itemCosts, amount, toSlot, points, securityToken)
	if not exports['salty_tokenizer']:secureServerEvent(GetCurrentResourceName(), source, securityToken) then
		return false
	end

	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	
	local amount = tonumber(amount)
	local points = tonumber(points)
	local multiplier = amount * points
	local rep = tonumber(Player.PlayerData.metadata["craftingrep"]["general"])
	local newRep = rep + multiplier
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.Functions.RemoveItem(k, (v*amount))
		end
		Player.Functions.AddItem(itemName, amount, toSlot)
		Player.Functions.AddCraftingReputation("general", newRep)
		Wait(1000)
		TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent('inventory:server:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points, securityToken)
	if not exports['salty_tokenizer']:secureServerEvent(GetCurrentResourceName(), source, securityToken) then
		return false
	end

	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local amount = tonumber(amount)
	local points = tonumber(points)
	local multiplier = amount * points
	local rep = tonumber(Player.PlayerData.metadata["craftingrep"]["weapons"])
	local newRep = rep + multiplier
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.Functions.RemoveItem(k, (v*amount))
		end
		Player.Functions.AddItem(itemName, amount, toSlot)
		Player.Functions.AddCraftingReputation("weapons", newRep)
		TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent('inventory:server:MechanicCraft', function(itemName, itemCosts, amount, toSlot, points, securityToken)
	if not exports['salty_tokenizer']:secureServerEvent(GetCurrentResourceName(), source, securityToken) then
		return false
	end

	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local amount = tonumber(amount)
	local points = tonumber(points)
	local multiplier = amount * points
	local newRep = 1 + multiplier
	if tonumber(Player.PlayerData.metadata["craftingrep"]["mechanic"]) ~= nil then
		newRep = tonumber(Player.PlayerData.metadata["craftingrep"]["mechanic"]) + multiplier
	end
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.Functions.RemoveItem(k, (v*amount))
		end
		Player.Functions.AddItem(itemName, amount, toSlot)
		Player.Functions.AddCraftingReputation("mechanic", newRep)
		TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent('inventory:server:SetIsOpenState', function(IsOpen, type, id)
	if not IsOpen then
		if type == "stash" then
			Stashes[id].isOpen = false
		elseif type == "trunk" then
			Trunks[id].isOpen = false
		elseif type == "glovebox" then
			Gloveboxes[id].isOpen = false
		end
	end
end)

local function IsVehicleOwned(plate)
	local response = false
	--local result = MySQL.Sync.fetchScalar('SELECT plate from player_vehicles WHERE plate = ?', {plate})
	local result = MongoDB.Sync.findOne({collection = 'vehicles', query = {plate = plate} })
	if result[1] then
		response = true
	end
	return response
end

local function hasCraftItems(source, CostItems, amount)
	local Player = QBCore.Functions.GetPlayer(source)
	for k, v in pairs(CostItems) do
		if Player.Functions.GetItemByName(k) ~= nil then
			if Player.Functions.GetItemByName(k).amount < (v * amount) then
				return false
			end
		else
			return false
		end
	end
	return true
end

-- Shop Items
local function SetupShopItems(shopItems)
	local items = {}
	if shopItems ~= nil and next(shopItems) ~= nil then
		for k, item in pairs(shopItems) do
			local itemInfo = SharedItems[item.name:lower()]
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info ~= nil and item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				price = item.price,
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

RegisterServerEvent('inventory:server:OpenInventory', function(name, id, other)
	local src = source
	local ply = Player(src)
	local Player = QBCore.Functions.GetPlayer(src)

	if not ply.state.inv_busy then
		if name ~= nil and id ~= nil then
			local secondInv = {}
			if name == "stash" then
				if Stashes[id] ~= nil then
					if Stashes[id].isOpen then
						local Target = QBCore.Functions.GetPlayer(Stashes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Stashes[id].isOpen, name, id, Stashes[id].label)
						else
							Stashes[id].isOpen = false
						end
					end
				end
				local maxweight = 1000000
				local slots = 50
				if other ~= nil then 
					maxweight = other.maxweight ~= nil and other.maxweight or 1000000
					slots = other.slots ~= nil and other.slots or 50
				end
				secondInv.name = "stash-"..id
				secondInv.label = "Stash-"..id
				secondInv.maxweight = maxweight
				secondInv.inventory = {}
				secondInv.slots = slots
				if Stashes[id] ~= nil and Stashes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Stash-None"
					secondInv.maxweight = 1000000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local stashItems = GetStashItems(id)
					if next(stashItems) ~= nil then
						secondInv.inventory = stashItems
						Stashes[id] = {}
						Stashes[id].items = stashItems
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
					else
						Stashes[id] = {}
						Stashes[id].items = {}
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
					end
				end
			elseif name == "trunk" then
				if Trunks[id] ~= nil then
					if Trunks[id].isOpen then
						local Target = QBCore.Functions.GetPlayer(Trunks[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
						else
							Trunks[id].isOpen = false
						end
					end
				end
				secondInv.name = "trunk-"..id
				secondInv.label = "Trunk-"..id
				secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
				
				if (SplitStr(id, "MINE")[2] ~= nil) then --special logic for mining truck
					secondInv.maxweight = 300000
				end

				secondInv.inventory = {}
				secondInv.slots = other.slots ~= nil and other.slots or 50

				if (Trunks[id] ~= nil and Trunks[id].isOpen) or (SplitStr(id, "POL")[2] ~= nil and Player.PlayerData.job.name ~= "police") then
					secondInv.name = "none-inv"
					secondInv.label = "Trunk-None"
					secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					if id ~= nil then 
						local ownedItems = GetOwnedVehicleItems(id)
						if IsVehicleOwned(id) and next(ownedItems) ~= nil then
							secondInv.inventory = ownedItems
							Trunks[id] = {}
							Trunks[id].items = ownedItems
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						elseif Trunks[id] ~= nil and not Trunks[id].isOpen then
							secondInv.inventory = Trunks[id].items
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						else
							Trunks[id] = {}
							Trunks[id].items = {}
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						end
					end
				end
			elseif name == "glovebox" then
				if Gloveboxes[id] ~= nil then
					if Gloveboxes[id].isOpen then
						local Target = QBCore.Functions.GetPlayer(Gloveboxes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Gloveboxes[id].isOpen, name, id, Gloveboxes[id].label)
						else
							Gloveboxes[id].isOpen = false
						end
					end
				end
				secondInv.name = "glovebox-"..id
				secondInv.label = "Glovebox-"..id
				secondInv.maxweight = 10000
				secondInv.inventory = {}
				secondInv.slots = 5
				if Gloveboxes[id] ~= nil and Gloveboxes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Glovebox-None"
					secondInv.maxweight = 10000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local ownedItems = GetOwnedVehicleGloveboxItems(id)
					if Gloveboxes[id] ~= nil and not Gloveboxes[id].isOpen then
						secondInv.inventory = Gloveboxes[id].items
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					elseif IsVehicleOwned(id) and next(ownedItems) ~= nil then
						secondInv.inventory = ownedItems
						Gloveboxes[id] = {}
						Gloveboxes[id].items = ownedItems
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					else
						Gloveboxes[id] = {}
						Gloveboxes[id].items = {}
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					end
				end
			elseif name == "shop" then
				secondInv.name = "itemshop-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = SetupShopItems(other.items)
				ShopItems[id] = {}
				ShopItems[id].items = other.items
				secondInv.slots = #other.items
			elseif name == "traphouse" then
				secondInv.name = "traphouse-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = other.slots
			elseif name == "crafting" then
				secondInv.name = "crafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "attachment_crafting" then
				secondInv.name = "attachment_crafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "mechanic_crafting" then
				secondInv.name = "mechanic_crafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "otherplayer" then
				local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(id))
				if OtherPlayer ~= nil then
					secondInv.name = "otherplayer-"..id
					secondInv.label = "Player-"..id
					secondInv.maxweight = QBCore.Config.Player.MaxWeight
					secondInv.inventory = OtherPlayer.PlayerData.items
					if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
						secondInv.slots = QBCore.Config.Player.MaxInvSlots
					-- else this is for hidden slot stuff, disabling since no hidden slot
					-- 	secondInv.slots = QBCore.Config.Player.MaxInvSlots - 1
					end
					Wait(250)
				end
			else
				if Drops[id] ~= nil and not Drops[id].isOpen then
					secondInv.name = id
					secondInv.label = "Dropped-"..tostring(id)
					secondInv.maxweight = 100000
					secondInv.inventory = Drops[id].items
					secondInv.slots = 30
					Drops[id].isOpen = src
					Drops[id].label = secondInv.label
				else
					secondInv.name = "none-inv"
					secondInv.label = "Dropped-None"
					secondInv.maxweight = 100000
					secondInv.inventory = {}
					secondInv.slots = 0
					--Drops[id].label = secondInv.label
				end
			end
			TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.PlayerData.items, secondInv)
		else
			TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.PlayerData.items)
		end
	end
end)

RegisterServerEvent('inventory:server:SaveInventory', function(type, id)
	if type == "trunk" then
		if (IsVehicleOwned(id)) then
			SaveOwnedVehicleItems(id, Trunks[id].items)
		else
			Trunks[id].isOpen = false
		end
	elseif type == "glovebox" then
		if (IsVehicleOwned(id)) then
			SaveOwnedGloveboxItems(id, Gloveboxes[id].items)
		else
			Gloveboxes[id].isOpen = false
		end
	elseif type == "stash" then
		SaveStashItems(id, Stashes[id].items)
	elseif type == "drop" then
		if Drops[id] ~= nil then
			Drops[id].isOpen = false
			if Drops[id].items == nil or next(Drops[id].items) == nil then
				Drops[id] = nil
				TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
			end
		end
	end
end)

RegisterServerEvent('inventory:server:UseItemSlot', function(slot)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local itemData = Player.Functions.GetItemBySlot(slot)

	if itemData ~= nil then
		local itemInfo = SharedItems[itemData.name]
		if QBCore.Functions.CheckDegraded(itemData) > 0 then
			if itemData.type == "weapon" then
				TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
				
			elseif itemData.useable then
				--TriggerClientEvent("QBCore:Client:UseItem", src, itemData)
				if itemData ~= nil and itemData.amount > 0 then
					if QBCore.Functions.CanUseItem(itemData.name) then
						QBCore.Functions.UseItem(src, itemData)
						TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
					end
				end
			end
		else
			TriggerClientEvent('QBCore:Notify', src, "This item is broken..", "error")
		end
	end
end)

RegisterServerEvent('inventory:server:UseItem', function(inventory, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if inventory == "player" or inventory == "hotbar" then
		local itemData = Player.Functions.GetItemBySlot(item.slot)
		if itemData ~= nil then
			local itemInfo = SharedItems[itemData.name]
			if QBCore.Functions.CheckDegraded(itemData) > 0 then
				--TriggerClientEvent("QBCore:Client:UseItem", src, itemData)
				if QBCore.Functions.CanUseItem(itemData.name) then
					QBCore.Functions.UseItem(src, itemData)
					TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
				end
			else
				TriggerClientEvent('QBCore:Notify', src, "This item is broken..", "error")
			end
		end
	end
end)

RegisterServerEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local fromSlot = tonumber(fromSlot)
	local toSlot = tonumber(toSlot)

	if (fromInventory == "player" or fromInventory == "hotbar") and (SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
		return
	end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = Player.Functions.GetItemBySlot(fromSlot)
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot, true)
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot, true)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created, true)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created, true)
			elseif SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(SplitStr(toInventory, "-")[2])
				local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, fromSlot)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
					end
				else
					local itemInfo = SharedItems[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** to player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info, fromItemData.created)
			elseif SplitStr(toInventory, "-")[1] == "trunk" then
				print("1.3.1")
				local plate = SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = SharedItems[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
			elseif SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = SharedItems[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
			elseif SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						--RemoveFromStash(stashId, fromSlot, itemInfo["name"], toAmount)
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
					end
				else
					local itemInfo = SharedItems[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "stash", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
			elseif SplitStr(toInventory, "-")[1] == "traphouse" then
				-- Traphouse
				local traphouseId = SplitStr(toInventory, "-")[2]
				local toItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, toSlot)
				local IsItemValid = exports['qb-traphouses']:CanItemBeSaled(fromItemData.name:lower())
				if IsItemValid then
					Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
					if toItemData ~= nil then
						local itemInfo = SharedItems[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount)
							Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
							TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
						end
					else
						local itemInfo = SharedItems[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "traphouse", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
					end
					local itemInfo = SharedItems[fromItemData.name:lower()]
					exports['qb-traphouses']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
				else
					TriggerClientEvent('QBCore:Notify', src, "You can\'t sell this item..", 'error')
				end
			else
				-- drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					CreateNewDrop(src, fromSlot, toSlot, fromAmount, fromItemData.created)
				else
					local toItemData = Drops[toInventory].items[toSlot]
					Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckDroppedItem", src, fromItemData.name, fromSlot)
					if toItemData ~= nil then
						local itemInfo = SharedItems[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info, toItemData.created)
							RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
							TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
						end
					else
						local itemInfo = SharedItems[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "drop", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
					end
					local itemInfo = SharedItems[fromItemData.name:lower()]
					AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
				end
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "You don\'t have this item!", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(SplitStr(fromInventory, "-")[2])
		local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
		local fromItemData = OtherPlayer.PlayerData.items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckDroppedItem", OtherPlayer.PlayerData.source, fromItemData.name, fromSlot)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, toSlot)
						OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info, toItemData.created)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info, fromItemData.created)
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				local itemInfo = SharedItems[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
						--TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						--TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
				end
				SaveStashItems(stashId, Stashes[stashId].items)
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				local itemInfo = SharedItems[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
				local toItemData = Stashes[stashId].items[toSlot]
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "traphouse" then
		local traphouseId = SplitStr(fromInventory, "-")[2]
		local fromItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, fromSlot)
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						exports['qb-traphouses']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				local toItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, toSlot)
				exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						exports['qb-traphouses']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
						exports['qb-traphouses']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
					end
				end
				local itemInfo = SharedItems[fromItemData.name:lower()]
				exports['qb-traphouses']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif SplitStr(fromInventory, "-")[1] == "itemshop" then
		local shopType = SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = SharedItems[itemData.name:lower()]
		--local bankBalance = Player.PlayerData.money["bank"]
		local price = tonumber((itemData.price*fromAmount))

		if SplitStr(shopType, "_")[1] == "Dealer" then
			if SplitStr(itemData.name, "_")[1] == "weapon" then
				price = tonumber(itemData.price)
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					itemData.info.serie = tostring(RandomInt(2) ..RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4))
					Player.Functions.AddItem(itemData.name, 1, toSlot, itemData.info, itemData.created)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
					TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " purchased!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item purchased", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
				else
					TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
				end
			else
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info, itemData.created)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
					TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " purchased!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item purchased", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
				else
					TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
				end
			end
		elseif SplitStr(shopType, "_")[1] == "Itemshop" then
			if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
				Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info, itemData.created)
				TriggerClientEvent('qb-shops:client:UpdateShop', src, SplitStr(shopType, "_")[2], itemData, fromAmount)
				TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
				--TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
			end
		else
			if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
				Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info, itemData.created)
				TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
				--TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
			end
		end
	elseif fromInventory == "crafting" then
		local itemData = Config.CraftingItems[fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('QBCore:Notify', src, "You don\'t have the right items..", "error")
		end
	elseif fromInventory == "attachment_crafting" then
		local itemData = Config.AttachmentCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('QBCore:Notify', src, "You don\'t have the right items..", "error")
		end
	elseif fromInventory == "mechanic_crafting" then
		local itemData = Config.MechanicCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:MechanicCraft", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('QBCore:Notify', src, "You don\'t have the right items..", "error")
		end
	else
		-- drop
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = SharedItems[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
						--TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
					else
						--TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData.created)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, fromItemData.created)
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = SharedItems[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = SharedItems[toItemData.name:lower()]
						RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info, toItemData.created)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				
				TriggerClientEvent("inventory:client:CheckDroppedItem", src, itemInfo["name"], fromSlot)
			end
		else
			TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	end
end)

--[[ local function escape_str(s)
	local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	for i, c in ipairs(in_char) do
		s = s:gsub(c, '\\' .. out_char[i])
	end
	return s
end ]]

--[[ QBCore.Commands.Add("inv", "Open your inventory", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
	TriggerClientEvent("inventory:client:OpenInventory", source, Player.PlayerData.items)
end) ]]

QBCore.Commands.Add("resetinv", "Reset inventory (in case of -None)", {{name="type", help="stash/trunk/glovebox"},{name="id/plate", help="ID of stash or license plate"}}, true, function(source, args)
	local src = source
	local invType = args[1]:lower()
	table.remove(args, 1)
	local invId = table.concat(args, " ")
	if invType ~= nil and invId ~= nil then 
		if invType == "trunk" then
			if Trunks[invId] ~= nil then 
				Trunks[invId].isOpen = false
			end
		elseif invType == "glovebox" then
			if Gloveboxes[invId] ~= nil then 
				Gloveboxes[invId].isOpen = false
			end
		elseif invType == "stash" then
			if Stashes[invId] ~= nil then 
				Stashes[invId].isOpen = false
			end
		else
			TriggerClientEvent('QBCore:Notify', src,  "Not a valid type..", "error")
		end
	else
		TriggerClientEvent('QBCore:Notify', src,  "Arguments not filled out correctly..", "error")
	end
end, "god")

-- QBCore.Commands.Add("setnui", "Zet nui aan/ui (0/1)", {}, true, function(source, args)
--     if tonumber(args[1]) == 1 then
--         TriggerClientEvent("inventory:client:EnableNui", src)
--     else
--         TriggerClientEvent("inventory:client:DisableNui", src)
--     end
-- end)

QBCore.Commands.Add("trunkpos", "Shows trunk position", {}, false, function(source, args)
	local src = source
	TriggerClientEvent("inventory:client:ShowTrunkPos", src)
end)

QBCore.Commands.Add("robplayer", "Rob another player", {}, false, function(source, args)
	local src = source
	TriggerClientEvent("police:client:RobPlayer", src)
end)

QBCore.Commands.Add("giveitem", "Give item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}, {name="created", help="Created time of item"}}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	local amount = tonumber(args[3]) ~= nil and tonumber(args[3]) or 0
	local itemData = SharedItems[tostring(args[2]):lower()]
	local created = tonumber(args[4]) ~= nil and tonumber(args[4]) or os.time()
	--	local PlayerJob = Player.PlayerData.job.grade.name
	--local profilePicture = Player.PlayerData.metadata["phone"]["profilepicture"]
	if Player ~= nil then
		if amount > 0 then
			if itemData ~= nil then
				-- check iteminfo
				local info = {}
				if itemData["name"] == "id_card" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.nationality = Player.PlayerData.charinfo.nationality
				elseif itemData["name"] == "lspd_badge" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.nationality = Player.PlayerData.charinfo.nationality
					info.rank = Player.PlayerData.job.grade.name
					info.callsign = Player.PlayerData.metadata.callsign
				elseif itemData["name"] == "driver_license" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.type = "A1-A2-A | AM-B | C1-C-CE"
				elseif itemData["name"] == "weapons_license" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.type = "1/2/3"
				elseif itemData["name"] == "pilots_license" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.type = "L/H/R"
				elseif itemData["name"] == "harness" then
					info.uses = 20
				elseif itemData["name"] == "markedbills" then
					info.worth = math.random(5000, 10000)
				elseif itemData["name"] == "methlabkey" then
					info = exports["qb-meth"]:GenerateRandomLab()
				elseif itemData["name"] == "cokelabkey" then
					info = exports["qb-coke"]:GenerateRandomLab()
				elseif itemData['name'] == 'backpack_small' or itemData['name'] == 'backpack_medium' or itemData['name'] == 'backpack_large' then
					amount = 1
					info.type = 'bag'
					info.serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4))
				elseif itemData["name"] == "phone" then
					info.number = tostring(RandomInt(10))
				elseif itemData["name"] == "vpn" then
					info.serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(3) .. RandomInt(2) .. RandomStr(4))
				elseif itemData["name"] == "vehicle_keys" then					
					print("ASDF")
				elseif itemData["type"] == "weapon" then
					amount = 1
					info.ammo = 0
					info.serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4))
				end

				local createdTable = {}
				for i=1, amount do
					createdTable[#createdTable+1] = created
					--table.insert(createdTable, created)
				end

				if Player.Functions.AddItem(itemData["name"], amount, false, info, createdTable) then
					TriggerClientEvent('QBCore:Notify', src, "You have given " ..GetPlayerName(tonumber(args[1])).." " .. itemData["label"] .. " ("..amount.. ")", "success")
				else
					TriggerClientEvent('QBCore:Notify', src,  "Can\'t give item!", "error")
				end
			else
				--TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Item doesn\'t exist!")
				TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist!", "error")
			end
		else
			--TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Amount must be higher than 0!")
			TriggerClientEvent("QBCore:Notify", src, "Amount must be higher than 0!", "error")
		end
	else
		--TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
		TriggerClientEvent("QBCore:Notify", src, "Player is not online!", "error")
	end
end, "god")

QBCore.Commands.Add("randomitems", "Get some random items (for testing)", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local filteredItems = {}
	for k, v in pairs(SharedItems) do
		if SharedItems[k]["type"] ~= "weapon" then
			table.insert(filteredItems, v)
		end
	end
	for i = 1, 10, 1 do
		local randitem = filteredItems[math.random(1, #filteredItems)]
		local amount = math.random(1, 10)
		if randitem["unique"] then
			amount = 1
		end
		Player.Functions.AddItem(randitem["name"], amount)
        Wait(500)
	end
end, "god")

QBCore.Functions.CreateUseableItem("snowball", function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(item.slot)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("inventory:client:UseSnowball", source, itemData.amount)
    end
end)

QBCore.Functions.CreateUseableItem('backpack_small', function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local slot = Player.Functions.GetItemBySlot(item.slot)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local backpackId = item.info.serie
		TriggerClientEvent('qb-backpack:client:openBackpack', src, backpackId, item.name)  
	end
end)

QBCore.Functions.CreateUseableItem('backpack_medium', function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local slot = Player.Functions.GetItemBySlot(item.slot)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local backpackId = item.info.serie
		TriggerClientEvent('qb-backpack:client:openBackpack', src, backpackId, item.name)  
	end
end)

QBCore.Functions.CreateUseableItem('backpack_large', function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local slot = Player.Functions.GetItemBySlot(item.slot)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local backpackId = item.info.serie
		TriggerClientEvent('qb-backpack:client:openBackpack', src, backpackId, item.name)  
	end
end)

-- QBCore.Functions.CreateCallback('qb-backpack:verifyBackpack', function(source, cb)
-- 	local src = source
-- 	local Player = QBCore.Functions.GetPlayer(src)

-- 	if Player.Functions.GetItemByName('backpack_small') ~= nil then
-- 		local invType = 'backpack_small'
-- 		cb(invType)
-- 	elseif Player.Functions.GetItemByName('backpack_medium') ~= nil then
-- 		local invType = 'backpack_medium'
-- 		cb(invType)
-- 	elseif Player.Functions.GetItemByName('backpack_large') ~= nil then
-- 		local invType = 'backpack_large'
-- 		cb(invType)
-- 	end
-- end)

lib.callback.register('qb-backpack:verifyBackpack', function(source)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName('backpack_small') ~= nil then
		return 'backpack_small'
	elseif Player.Functions.GetItemByName('backpack_medium') ~= nil then
		return 'backpack_medium'
	elseif Player.Functions.GetItemByName('backpack_large') ~= nil then
		return 'backpack_large'
	else
		return nil
	end
end)

--WEAPONS
local WeaponAmmo = {}

--Functions
local function IsWeaponBlocked(WeaponName)
    local retval = false
    for _, name in pairs(Config.DurabilityBlockedWeapons) do
        if name == WeaponName then
            retval = true
            break
        end 
    end
    return retval
end

local function AlreadyHasAttachmentClass(type, attachments)
    local retval = false
    for k, v in pairs(attachments) do
        if v.type == type then
            retval = true
        end
    end
    return retval
end

local function HasAttachment(component, attachments)
    local retval = false
    local key = nil
    for k, v in pairs(attachments) do
        if v.component == component then
            key = k
            retval = true
        end
    end
    return retval, key
end

local function GetAttachmentItem(weapon, component)
    local retval = nil
    for k, v in pairs(Config.WeaponAttachments[weapon]) do
        if v.component == component then
            retval = v.item
        end
    end
    return retval
end

local function IsThrowable(weaponName)
    local response = false
    local items = { 
        [1] = "weapon_grenade", 
        [2] = "weapon_molotov", 
        [3] = "weapon_bzgas", 
        [4] = "weapon_smokegrenade", 
        [5] = "weapon_ball", 
        [6] = "weapon_flare", 
        [7] = "weapon_proxmine", 
        [8] = "weapon_snowball", 
        [9] = "weapon_pipebomb" ,
    }

    --for _, v in ipairs(items) do
    for k = 1, #items, 1 do
        v = items[k]
        if v == weaponName then
            response = true
            break
        end
    end

    return response
end

lib.callback.register('weapons:server:GetConfig', function(source)
    return Config.WeaponRepairPoints
end)

-- QBCore.Functions.CreateCallback("weapons:server:GetConfig", function(source, cb)
--     cb(Config.WeaponRepairPoints)
-- end)

RegisterServerEvent("weapons:server:AddWeaponAmmo")
AddEventHandler('weapons:server:AddWeaponAmmo', function(CurrentWeaponData, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(amount)

    if CurrentWeaponData ~= nil then
        if Player.PlayerData.items[CurrentWeaponData.slot] ~= nil then
            Player.PlayerData.items[CurrentWeaponData.slot].info.ammo = amount
        end
        Player.Functions.SetInventory(Player.PlayerData.items, true)
    end
end)

RegisterServerEvent("weapons:server:UpdateWeaponAmmo")
AddEventHandler('weapons:server:UpdateWeaponAmmo', function(CurrentWeaponData, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(amount)

    if CurrentWeaponData ~= nil then
        if Player.PlayerData.items[CurrentWeaponData.slot] ~= nil then
            Player.PlayerData.items[CurrentWeaponData.slot].info.ammo = amount
        end

        Player.Functions.SetInventory(Player.PlayerData.items, true)
        
        if IsThrowable(CurrentWeaponData.name) then 
            Player.Functions.RemoveItem(CurrentWeaponData.name, 1, CurrentWeaponData.slot)
        end
    end
end)

QBCore.Functions.CreateCallback("weapon:server:GetWeaponAmmo", function(source, cb, WeaponData)
    local Player = QBCore.Functions.GetPlayer(source)
    local retval = 0
    if WeaponData ~= nil then
        if Player ~= nil then
            local ItemData = Player.Functions.GetItemBySlot(WeaponData.slot)
            if ItemData ~= nil then
                retval = ItemData.info.ammo ~= nil and ItemData.info.ammo or 0
            end
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('weapons:server:RemoveAttachment', function(source, cb, AttachmentData, ItemData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local AttachmentComponent = Config.WeaponAttachments[ItemData.name:upper()][AttachmentData.attachment]

    if #AttachmentComponent > 0 then
        for k, v in pairs(AttachmentComponent) do
            if AttachmentData.item == v.item then
                AttachmentComponent = v
            end
        end
    end

    if Inventory[ItemData.slot] ~= nil then
        if Inventory[ItemData.slot].info.attachments ~= nil and next(Inventory[ItemData.slot].info.attachments) ~= nil then
            local HasAttach, key = HasAttachment(AttachmentComponent.component, Inventory[ItemData.slot].info.attachments)
            if HasAttach then
                table.remove(Inventory[ItemData.slot].info.attachments, key)
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                Player.Functions.AddItem(AttachmentComponent.item, 1)
                TriggerClientEvent("QBCore:Notify", src, "You removed "..AttachmentComponent.label.." from your weapon!", "error")
                cb(Inventory[ItemData.slot].info.attachments)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("weapons:server:RepairWeapon", function(source, cb, RepairPoint, data) --reset the created amount instead of resetting the quality datapoint
    local src = source
	if not Config.WeaponRepairPoints[RepairPoint].IsRepairing then
		local Player = QBCore.Functions.GetPlayer(src)
		local Timeout = math.random(500000, 600000) --10 minutes
		local WeaponData = SharedWeapons[joaat(data.name)]
		local WeaponClass = (SplitStr(WeaponData.ammotype, "_")[2]):lower()

		local itemData = Player.Functions.GetItemBySlot(data.slot)
		local ItemQuality = QBCore.Functions.CheckDegraded(itemData)
		if Player.PlayerData.items[data.slot] ~= nil then
			if ItemQuality < 100 then
				if Player.Functions.RemoveMoney('cash', Config.WeaponRepairCosts[WeaponClass]) then
					Config.WeaponRepairPoints[RepairPoint].IsRepairing = true
					Config.WeaponRepairPoints[RepairPoint].RepairingData = {
						CitizenId = Player.PlayerData.citizenid,
						WeaponData = Player.PlayerData.items[data.slot],
						Ready = false,
					}
					if Player.Functions.RemoveItem(data.name, 1, data.slot) then
						TriggerClientEvent("QBCore:Notify", src, "I\'ll email you when it\'s done. Leave before someone sees you.", "success", 5500)
						TriggerClientEvent("inventory:client:CheckDroppedItem", src, data.name, data.slot)
						TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)

						SetTimeout(Timeout, function()
							Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
							Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready = true
							TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
							TriggerEvent('qb-phone:server:sendNewMailToOffline', Player.PlayerData.citizenid, {
								sender = "Cliff",
								subject = "Weapon Repair",
								message = "Your "..WeaponData.label.." is fixed u can pick it up at the spot. You have 10 minutes to get to the shop, to pick up your firearm.<br><br> Thanks for supporting freedom"
							})
							SetTimeout(10 * 60000, function() --10 minutes
								if Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready then
									Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
									Config.WeaponRepairPoints[RepairPoint].RepairingData = {}
									TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
								end
							end)
						end)
						cb(true)
					end
				else
					cb(false)
				end
			else
				TriggerClientEvent("QBCore:Notify", src, "This weapon is not damaged..", "error")
				cb(false)
			end
		else
			TriggerClientEvent('QBCore:Notify', src, "You didn\'t have a weapon..", "error")
			TriggerClientEvent('weapons:client:SetCurrentWeapon', src, {}, false)
			cb(false)
		end
	end
end)

-- QBCore.Functions.CreateCallback('inventory:server:GetCurrentDrops', function(_, cb)
-- 	cb(Drops)
-- end)

lib.callback.register('inventory:server:GetCurrentDrops', function(source)
    return Drops
end)

QBCore.Functions.CreateUseableItem("pistol_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_PISTOL", 12, item)
end)

QBCore.Functions.CreateUseableItem("rifle_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_RIFLE", 30, item)
end)

QBCore.Functions.CreateUseableItem("smg_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_SMG", 20, item)
end)

QBCore.Functions.CreateUseableItem("shotgun_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_SHOTGUN", 10, item)
end)

QBCore.Functions.CreateUseableItem("mg_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_MG", 30, item)
end)

QBCore.Functions.CreateUseableItem("sniper_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_SNIPER", 30, item)
end)

QBCore.Functions.CreateUseableItem("stungun_ammo", function(source, item)
    TriggerClientEvent("weapon:client:AddAmmo", source, "AMMO_STUNGUN", 2, item)
end)

-- RegisterServerEvent('weapons:server:UpdateWeaponQuality')
-- AddEventHandler('weapons:server:UpdateWeaponQuality', function(data)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     local WeaponData = SharedWeapons[GetHashKey(data.name)]
--     local WeaponSlot = Player.PlayerData.items[data.slot]
--     local DecreaseAmount = Config.DurabilityMultiplier[data.name]
    
--     if not IsWeaponBlocked(WeaponData.name) then
--         if WeaponSlot.info.quality ~= nil then
--             if WeaponSlot.info.quality - DecreaseAmount > 0 then
--                 WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
--             else
--                 WeaponSlot.info.quality = 0
--                 TriggerClientEvent('inventory:client:UseWeapon', src, data)
--                 TriggerClientEvent('QBCore:Notify', src, "Your weapon is broken, u need to repair it before u can use it again.", "error")
--             end
--         else
--             WeaponSlot.info.quality = 100
--             if WeaponSlot.info.quality - DecreaseAmount > 0 then
--                 WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
--             else
--                 WeaponSlot.info.quality = 0
--                 TriggerClientEvent('inventory:client:UseWeapon', src, data)
--                 TriggerClientEvent('QBCore:Notify', src, "Your weapon is broken, u need to repair it before u can use it again.", "error")
--             end
--         end
--         Player.Functions.SetInventory(Player.PlayerData.items)
--     end
-- end)

RegisterServerEvent('weapons:server:UpdateWeaponQuality')
AddEventHandler('weapons:server:UpdateWeaponQuality', function(data, RepeatAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local WeaponData = SharedWeapons[joaat(data.name)]
    local WeaponSlot = Player.PlayerData.items[data.slot]
    local DecreaseAmount = Config.DurabilityMultiplier[data.name]

    if WeaponSlot ~= nil then
        if not IsWeaponBlocked(WeaponData.name) then
            if WeaponSlot.info.quality ~= nil then
                for i = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('inventory:client:UseWeapon', src, data)
                        TriggerClientEvent('QBCore:Notify', src, "Your weapon is broken, you need to repair it before you can use it again.", "error")
                        break
                    end
                end
            else
                WeaponSlot.info.quality = 100
                for i = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('inventory:client:UseWeapon', src, data)
                        TriggerClientEvent('QBCore:Notify', src, "Your weapon is broken, you need to repair it before you can use it again.", "error")
                        break
                    end
                end
            end
        end
    end

    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

QBCore.Commands.Add("repairweapon", "Repair weapon command for staf", {{name="hp", help="HP of ur weapon"}}, true, function(source, args)
    TriggerClientEvent('weapons:client:SetWeaponQuality', source, tonumber(args[1]))
end, "god")

RegisterServerEvent("weapons:server:SetWeaponQuality", function(data, hp)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local WeaponData = SharedWeapons[joaat(data.name)]
    local WeaponSlot = Player.PlayerData.items[data.slot]
    local DecreaseAmount = Config.DurabilityMultiplier[data.name]
    WeaponSlot.info.quality = hp
    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

RegisterServerEvent("weapons:server:TakeBackWeapon", function(k)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.citizenid ~= Config.WeaponRepairPoints[k].RepairingData.CitizenId then return end
    local itemdata = Config.WeaponRepairPoints[k].RepairingData.WeaponData

    --itemdata.info.quality = 100
    Player.Functions.AddItem(itemdata.name, 1, false, itemdata.info)
    Config.WeaponRepairPoints[k].IsRepairing = false
    Config.WeaponRepairPoints[k].RepairingData = {}
    TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[k], k)
end)

RegisterServerEvent("weapons:server:EquipAttachment", function(ItemData, CurrentWeaponData, AttachmentData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local GiveBackItem = nil

    if Inventory[CurrentWeaponData.slot] ~= nil then
        if Inventory[CurrentWeaponData.slot].info.attachments ~= nil and next(Inventory[CurrentWeaponData.slot].info.attachments) ~= nil then
            local AlreadyHasClass = AlreadyHasAttachmentClass(AttachmentData.type, Inventory[CurrentWeaponData.slot].info.attachments)
            
            if not AlreadyHasClass then
                local HasAttach, key = HasAttachment(AttachmentData.component, Inventory[CurrentWeaponData.slot].info.attachments)
                if not HasAttach then
                    if CurrentWeaponData.name == "weapon_compactrifle" then
                        local component = "COMPONENT_COMPACTRIFLE_CLIP_03"
                        if AttachmentData.component == "COMPONENT_COMPACTRIFLE_CLIP_03" then
                            component = "COMPONENT_COMPACTRIFLE_CLIP_02"
                        end
                        for k, v in pairs(Inventory[CurrentWeaponData.slot].info.attachments) do
                            if v.component == component then
                                local has, key = HasAttachment(component, Inventory[CurrentWeaponData.slot].info.attachments)
                                local item = GetAttachmentItem(CurrentWeaponData.name:upper(), component)
                                GiveBackItem = tostring(item):lower()
                                table.remove(Inventory[CurrentWeaponData.slot].info.attachments, key)
                            end
                        end
                    end
					Inventory[CurrentWeaponData.slot].info.attachments[#Inventory[CurrentWeaponData.slot].info.attachments+1] = {
                        component = AttachmentData.component,
                        label = AttachmentData.label,
                        type = AttachmentData.type,
                    }

                    TriggerClientEvent("addAttachment", src, AttachmentData.component)
                    Player.Functions.SetInventory(Player.PlayerData.items, true)
                    Player.Functions.RemoveItem(ItemData.name, 1)
                else
                    TriggerClientEvent("QBCore:Notify", src, "You already have "..AttachmentData.label:lower().." on your weapon.", "error", 3500)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "You already have an attachment of that type active.", "error", 3500)
            end
        else
            Inventory[CurrentWeaponData.slot].info.attachments = {}
            AlreadyHasAttachmentClass(AttachmentData.type, Inventory[CurrentWeaponData.slot].info.attachments)
            table.insert(Inventory[CurrentWeaponData.slot].info.attachments, {
                component = AttachmentData.component,
                label = AttachmentData.label,
                type = AttachmentData.type,
            })
            TriggerClientEvent("addAttachment", src, AttachmentData.component)
            Player.Functions.SetInventory(Player.PlayerData.items, true)
            Player.Functions.RemoveItem(ItemData.name, 1)

        end
    end

    if GiveBackItem ~= nil then
        Player.Functions.AddItem(GiveBackItem, 1, false)
        GiveBackItem = nil
    end
end)

CreateThread(function()
    for _, v in pairs(Config.WeaponAttachments) do --improve this, it's bad
        for type, s in pairs(v) do
            --for k, c in pairs(s) do
			for i=1, #s do
				local c = s[i]
                if c.item ~= nil then
                    QBCore.Functions.CreateUseableItem(c.item, function(source, item)
                        --local Player = QBCore.Functions.GetPlayer(source) --do i need this?
                        TriggerClientEvent("weapons:client:EquipAttachment", source, item, type)
                    end)
                end
            end
        end
    end

	for k, v in pairs(Config.Masks) do
        local itemName = 'mask_'..k
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            local src = source
            TriggerClientEvent('masks:client:applyMask', src, k)
        end)
    end
end)

local allowedModifyItems = {
	['id_card'] = {true}
}

RegisterServerEvent("qb-inventory:server:modifyItem", function(slot, item)
	if allowedModifyItems[item] == nil then return end
	local Player = QBCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(slot)
	if item ~= itemData.name then return end
	if item == 'id_card' then
		TriggerClientEvent('qb-idcard:client:editPic', source, slot, item)
	end
	-- local PlayerItem = Player.Functions.GetItemByName(item)
	-- if Player.PlayerData.citizenid ~= PlayerItem.info.citizenid then return end
	-- PlayerItem.info['picURL'] = url
    -- Player.PlayerData.items[PlayerItem.slot] = PlayerItem
    -- Player.Functions.SetPlayerData("items", Player.PlayerData.items)
end)

RegisterServerEvent("weapons:client:SetCurrentWeaponTint", function(slot, item, tintIndex)
	local Player = QBCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(slot)
	if item ~= itemData.name then return end
	--insert removeitem check if making an item
	itemData.info['tint'] = tintIndex
    Player.PlayerData.items[itemData.slot] = itemData
    Player.Functions.SetPlayerData("items", Player.PlayerData.items)
end)