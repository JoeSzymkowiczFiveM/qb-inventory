# qb-inventory
This is a version of qbus v3 inventory that I continued to mess around with over the years after the initial qbus v3 leak, adding individual, item degradation and context menu, among other things. This is the continuation of a project I did that used a thread to degrade the items. After that, I kept working on it, which led to changes to the core that, at the time, I didn't feel like bundling. I'm now tired of sitting on this, and hopefully it will benefit some people still on qb-inventory. Below are the functions you will need to integrate to the core, or whereever your AddItem and RemoveItem functions are.


## Item Degradation.
Items naturally degrade over time if the `degrade` property on items in the shared items list are greater than 0. Items with a degrade amount of 1 will degrade from 100 to 0 over the course of 28 days. The closer the amount gets to 0, the longer it takes for it to degrade, and a property of 0 will not degrade at all. Add the following the property to every item in your shared items list.
```["degrade"] = 1,```


### Special Note
This script is not plug-and-play and is probably horribly exploitable, in it's current form. I'm simply providing the code to show how I implemented a threadless item degradation system in my version of qb-inventory. I use mongodb and have left those queries in place, as I cba to put in any effort to make this work with whatever frameworks or versions are out there. It is up to YOU to make this code work in your server. I will not be providing support for this. Best of luck.


## Core Server Functions
### Player
```
function fcomp_default(a, b)
    return a < b
end

function table.bininsert(t, value, fcomp)
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
    table.insert( t,(iMid+iState),value )
    return (iMid+iState)
end

self.Functions.AddItem = function(item, amount, slot, info, created, hideItemBox)
    local totalWeight = QBCore.Player.GetTotalWeight(self.PlayerData.items)
    local itemInfo = Items[item:lower()]
    local amount = tonumber(amount)
    local slot = tonumber(slot) ~= nil and tonumber(slot) or QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)

    if itemInfo == nil then 
        --TriggerClientEvent('chatMessage', self.PlayerData.source, "SYSTEM",  "warning", "No item found??") 
        TriggerClientEvent('chat:addMessage', self.PlayerData.source, {
            template = '<div class="chat-message nonemergency"><i class="fas fa-exclamation"></i><b> SYSTEM: </b>{0}</div>',
            args = { "No item found??" }
        })
        return 
    end
    
    if itemInfo["type"] == "weapon" and info == nil then
        info = {
            serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4)),
        }
    end

    if ( itemInfo['name'] == 'backpack_small' or itemInfo['name'] == 'backpack_medium' or itemInfo['name'] == 'backpack_large' ) and itemInfo["type"] == 'item' and info == nil then
        info = { 
            type = 'bag',
            serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4)),
        }
    end

    if itemInfo["type"] == 'item' and info == nil then --probably dont need anymore.
        info = { quality = 100 }
    end

    if (totalWeight + (itemInfo["weight"] * amount)) <= QBCore.Config.Player.MaxWeight then
        if (slot ~= nil and self.PlayerData.items[slot] ~= nil) and (self.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo["type"] == "item" and not itemInfo["unique"]) then
            self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount + amount

            for i=1, amount do
                table.bininsert(self.PlayerData.items[slot].created, created ~= nil and created[i] or os.time())
            end
            TriggerClientEvent("inventory:client:CheckPickupItem", self.PlayerData.source, item:lower(), slot)
            self.Functions.UpdatePlayerData()
            if amount > 20 then
                TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
            end
            --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " added!", "success")
            if not hideItemBox then
                TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, 'add') --save this for later
            end
            return true
        elseif (not itemInfo["unique"] and slot or slot ~= nil and self.PlayerData.items[slot] == nil) then
            local newCreated = {}
            for i=1, amount do
                table.bininsert(newCreated, created ~= nil and created[i] or os.time())
            end

            self.PlayerData.items[slot] = {name = itemInfo["name"], created = newCreated, degrade = itemInfo['degrade'], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = slot, combinable = itemInfo["combinable"], canModify = itemInfo["canModify"] ~= nil and itemInfo["canModify"] or false}
            TriggerClientEvent("inventory:client:CheckPickupItem", self.PlayerData.source, item:lower(), slot)
            self.Functions.UpdatePlayerData()
            if amount > 20 then
                TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
            end
            --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " added!", "success")
            if not hideItemBox then
                TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, 'add') --save this for later
            end
            return true
        elseif (itemInfo["unique"]) or (not slot or slot == nil) or (itemInfo["type"] == "weapon") then
            for i = 1, QBConfig.Player.MaxInvSlots - 1, 1 do
                if self.PlayerData.items[i] == nil then

                    local newCreated = {}
                    for i=1, amount do
                        --print(i .. " : " .. created[i])
                        table.bininsert(newCreated, created ~= nil and created[i] or os.time())
                    end

                    self.PlayerData.items[i] = {name = itemInfo["name"], created = newCreated, degrade = itemInfo['degrade'], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = i, combinable = itemInfo["combinable"], canModify = itemInfo["canModify"] ~= nil and itemInfo["canModify"] or false}
                    TriggerClientEvent("inventory:client:CheckPickupItem", self.PlayerData.source, item:lower(), slot)
                    self.Functions.UpdatePlayerData()
                    if amount > 20 then
                        TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..i.."], itemname: " .. self.PlayerData.items[i].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[i].amount)
                    end
                    --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " added!", "success")
                    if not hideItemBox then
                        TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, 'add') --save this for later
                    end
                    return true
                end
            end
        end
    end
    return false
end

function self.Functions.RemoveItem(item, amount, slot, hideItemBox)
    local itemInfo = Items[item:lower()]
    local amount = tonumber(amount)
    local slot = tonumber(slot)
    if slot ~= nil then
        if self.PlayerData.items[slot] ~= nil and self.PlayerData.items[slot].amount > amount then
            self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amount

            local new = {}
            for i=amount+1, #self.PlayerData.items[slot].created do
                table.insert(new, self.PlayerData.items[slot].created[i])
            end

            self.PlayerData.items[slot].created = new

            self.Functions.UpdatePlayerData()
            --TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
            --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " deleted!", "error")
            if not hideItemBox then
                TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, self.PlayerData.items[slot], "remove")
            end
            return true
        else
            self.PlayerData.items[slot] = nil
            self.Functions.UpdatePlayerData()
            --TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
            --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " deleted!", "error")
            if not hideItemBox then
                TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, "remove")
            end
            return true
        end
    else
        local slots = QBCore.Player.GetSlotsByItem(self.PlayerData.items, item)
        local amountToRemove = amount
        if slots ~= nil then
            for _, slot in pairs(slots) do
                if self.PlayerData.items[slot].amount > amountToRemove then
                    self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amountToRemove

                    local new = {}
                    for i=amount+1, #self.PlayerData.items[slot].created do
                        table.insert(new, self.PlayerData.items[slot].created[i])
                    end

                    self.PlayerData.items[slot].created = new

                    self.Functions.UpdatePlayerData()
                    --TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
                    --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " deleted!", "error")
                    if not hideItemBox then
                        TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, "remove")
                    end
                    return true
                elseif self.PlayerData.items[slot].amount == amountToRemove then
                    self.PlayerData.items[slot] = nil
                    self.Functions.UpdatePlayerData()
                    --TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
                    --TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " deleted!", "error")
                    if not hideItemBox then
                        TriggerClientEvent('inventory:client:ItemBox', self.PlayerData.source, itemInfo, "remove")
                    end
                    return true
                end
            end
        end
    end
    return false
end
```

### Player
```
function QBCore.Functions.CheckDegraded(item)
	local StartDate = item.created[1]
    
    --get Decay rate
    --local DecayRate = QBCore.Shared.Items[item.name:lower()]["degrade"]
	if item.degrade == 0 then
		return 100
	end
	
	local DecayRate = item.degrade

    --if decay rate set to nil, item wont decay
    --[[ if DecayRate == nil then 
        DecayRate = 0
    end ]]

    -- calculate percentage
	--local TimeAllowed = 60 * 60 * 24 * 28-- 28 days by default
	local TimeAllowed = 2419200
    local TimeExtra = math.ceil((TimeAllowed * DecayRate))
	local dateNow = os.time()
	local percentDone = 100 - math.floor(100 - (100 - ((dateNow - StartDate) / TimeExtra) * 100))
    --local percentDone = 100 - math.ceil((((dateNow - StartDate) / TimeExtra) * 100))

	--var quality = 100 + (100 - ((dateNow - StartDate) / TimeExtra) * 100) / 1000;
    --if (quality > 100) { quality = 100 } else if (quality < 0) { quality = 0 }

	--[[ if DecayRate == 0 then
		percentDone = 100
	end ]]
	if percentDone < 0 then
		percentDone = 0
	end
    return percentDone
end
```
![image](https://github.com/JoeSzymkowiczFiveM/qb-inventory/assets/70592880/fa9e45db-035f-452e-8060-f95ad2179b8c)


## Preview

[Durability Stacking](https://streamable.com/746zrk)

[Right Click Context Menu Options](https://streamable.com/mqlgcf)

## Discord
[Joe Szymkowicz FiveM Development](https://discord.gg/5vPGxyCB4z)
