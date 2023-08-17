QBCore = exports['qb-core']:GetCoreObject()
SharedItems = QBCore.Functions.GetSharedItems()

--local inInventory = false
--hotbarOpen = false
local currentOtherInventory = nil

local Drops = {}
local DropsNear = {}
local CurrentDrop = 0

local CurrentVehicle = nil
local CurrentGlovebox = nil
local CurrentStash = nil
local isCrafting = false

local showTrunkPos = false

local dropsThreadStarted = false
local DropsInRange = 0

PlayerJob = {}
PlayerData = {}

--local blur = false

--[[ CreateThread(function()
    while true do
        GLOBAL_PED = PlayerPedId()
        Wait(5000)
    end
end) ]]

--[[ local objectDumps = {
	{ objectID = 666561306, Description = "Blue Dumpster" },
	{ objectID = 218085040, Description = "Light Blue Dumpster" },
	{ objectID = -58485588, Description = "Gray Dumpster" },
	{ objectID = 682791951, Description = "Big Blue Dumpster" },
	{ objectID = -206690185, Description = "Big Green Dumpster" },
	{ objectID = 364445978, Description = "Big Green Skip Bin" },
    { objectID = 143369, Description = "Small Bin" },
    { objectID = 1511880420, Description = "Small Bin" },
} ]]

--Functions
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

local function IsBackEngine(vehModel)
    for _, model in pairs(BackEngineVehicles) do
        if GetHashKey(model) == vehModel then
            return true
        end
    end
    return false
end

local function CloseTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    lib.requestAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorShut(vehicle, 5, false)
    end
end

local function IsCustomTrunkPosition(vehModel)
    for model, info in pairs(Config.CustomTrunkPosition) do
        if model == vehModel then
            return true
        end
    end
    return false
end

local function OpenTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    lib.requestAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

local function OpenInventory()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if LocalPlayer.state.isLoggedIn and not PlayerData.metadata["isdead"] and not PlayerData.metadata["ishandcuffed"] then
                local curVeh = nil
                local ped = cache.ped
                
                if cache.vehicle then
                    --local vehicle = GetVehiclePedIsIn(ped, false)
                    local vehicle = cache.vehicle
                    --CurrentGlovebox = GetVehicleNumberPlateText(vehicle)
                    CurrentGlovebox = exports["qb-fakeplates"]:GetRealPlate(vehicle)
                    curVeh = vehicle
                    CurrentVehicle = nil

                else
                    local vehicle = QBCore.Functions.GetClosestVehicle()
                    if vehicle ~= 0 and vehicle ~= nil then
                        local pos = GetEntityCoords(ped)
                        local minimum, maximum = GetModelDimensions(GetEntityModel(vehicle))
                        local ratio = math.abs(minimum.y/maximum.y)
                        local offset = minimum.y - (maximum.y + minimum.y)*ratio
                        local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, offset, 0)
                        if (IsBackEngine(GetEntityModel(vehicle))) then
                            trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, math.abs(offset), 0)
                        end
                        if #(pos - trunkpos) < 1.5 and not IsPedInAnyVehicle(ped) then
                            if GetVehicleDoorLockStatus(vehicle) < 2 then
                                CurrentVehicle = exports["qb-fakeplates"]:GetRealPlate(vehicle)
                                curVeh = vehicle
                                CurrentGlovebox = nil
                            else
                                QBCore.Functions.Notify("Vehicle Locked", "error")
                                return
                            end
                        else
                            CurrentVehicle = nil
                        end
                    else
                        CurrentVehicle = nil
                    end
                end

                if CurrentVehicle ~= nil then
                    local maxweight = 0
                    local slots = 0
                    if GetVehicleClass(curVeh) == 0 then
                        maxweight = 38000
                        slots = 30
                    elseif GetVehicleClass(curVeh) == 1 then
                        maxweight = 50000
                        slots = 40
                    elseif GetVehicleClass(curVeh) == 2 then
                        maxweight = 110000
                        slots = 50
                    elseif GetVehicleClass(curVeh) == 3 then
                        maxweight = 90000
                        slots = 35
                    elseif GetVehicleClass(curVeh) == 4 then
                        maxweight = 90000
                        slots = 30
                    elseif GetVehicleClass(curVeh) == 5 then
                        maxweight = 60000
                        slots = 25
                    elseif GetVehicleClass(curVeh) == 6 then
                        maxweight = 60000
                        slots = 25
                    elseif GetVehicleClass(curVeh) == 7 then
                        maxweight = 30000
                        slots = 25
                    elseif GetVehicleClass(curVeh) == 8 then
                        maxweight = 30000
                        slots = 15
                    elseif GetVehicleClass(curVeh) == 9 then
                        maxweight = 110000
                        slots = 35
                    elseif GetVehicleClass(curVeh) == 10 then
                        maxweight = 200000
                        slots = 35
                    elseif GetVehicleClass(curVeh) == 11 then
                        maxweight = 200000
                        slots = 55
                    elseif GetVehicleClass(curVeh) == 12 then
                        maxweight = 120000
                        slots = 35
                    else
                        maxweight = 60000
                        slots = 35
                    end
                    local other = {
                        maxweight = maxweight,
                        slots = slots,
                    }
                    TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                    OpenTrunk()
                elseif CurrentGlovebox ~= nil then
                    TriggerServerEvent("inventory:server:OpenInventory", "glovebox", CurrentGlovebox)
                elseif CurrentDrop and CurrentDrop ~= 0 then
                    TriggerServerEvent("inventory:server:OpenInventory", "drop", CurrentDrop)
                --[[ elseif BinFound ~= nil then
                    local x = tonumber(BinFound.x)
                    local y = tonumber(BinFound.y)
                    x = string.gsub(x, "%-", "")
                    y = string.gsub(y, "%-", "")
                    x = string.gsub(x, "%.", "")
                    y = string.gsub(y, "%.", "")
                    
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", tostring(x..y))
                    TriggerEvent("inventory:client:SetCurrentStash", tostring(x..y)) ]]
                else
                    lib.requestAnimDict('pickup_object')
                    TaskPlayAnim(ped, "pickup_object" ,"putdown_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
                    TriggerServerEvent("inventory:server:OpenInventory")
                    Wait(1800)
                    ClearPedTasks(ped)
                end
            end
        end)
    end
end

local function OpenInventorySlot1()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 1)
            end
        end)
    end
end

local function OpenInventorySlot2()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 2)
            end
        end)
    end
end

local function OpenInventorySlot3()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 3)
            end
        end)
    end
end

local function OpenInventorySlot4()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 4)
            end
        end)
        
    end
end

local function OpenInventorySlot5()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 5)
            end
        end)
    end
end

local function OpenInventorySlot41()
    if not LocalPlayer.state.inv_busy then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                TriggerServerEvent("inventory:server:UseItemSlot", 41)
            end
        end)
    end
end

local function ToggleHotbar(toggle)
    local HotbarItems = {
        [1] = QBCore.Functions.GetPlayerData().items[1],
        [2] = QBCore.Functions.GetPlayerData().items[2],
        [3] = QBCore.Functions.GetPlayerData().items[3],
        [4] = QBCore.Functions.GetPlayerData().items[4],
        [5] = QBCore.Functions.GetPlayerData().items[5],
        --[41] = QBCore.Functions.GetPlayerData().items[41],
    } 

    if toggle then
        SendNUIMessage({
            action = "toggleHotbar",
            open = true,
            items = HotbarItems
        })
    else
        SendNUIMessage({
            action = "toggleHotbar",
            open = false,
        })
    end
end

local function DisableDisplayControlActions()
    DisableControlAction(0, 288, true) -- disable chat  
    DisableControlAction(0, 289, true) -- disable chat
    DisableControlAction(0, 244, true) -- disable chat  
end

-- local function InInventory()
--     return inInventory
-- end

-- local function DestroyZones()
--     for k, v in pairs(Drops) do
--         zones[k]:remove()
--     end
-- end

--Events
local onDuty = false

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = PlayerJob.onduty
end)

RegisterNetEvent('QBCore:Client:SetDuty')
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LocalPlayer.state:set("inv_busy", false, true)
    -- QBCore.Functions.TriggerCallback("inventory:server:GetCurrentDrops", function(theDrops)
	-- 	Drops = theDrops
    --     CreateDropZones()
    -- end)
    lib.callback('inventory:server:GetCurrentDrops', false, function(theDrops)
        Drops = theDrops
        CreateDropZones()
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set("inv_busy", true, true)
    --DestroyZones()
end)

-- AddEventHandler('onResourceStop', function(resourceName)
--     if GetCurrentResourceName() ~= resourceName then return end
--     DestroyZones()
-- end)

RegisterNetEvent('inventory:client:CheckOpenState', function(type, id, label)
    local name = SplitStr(label, "-")[2]
    if type == "stash" then
        if name ~= CurrentStash or CurrentStash == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "trunk" then
        if name ~= CurrentVehicle or CurrentVehicle == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "glovebox" then
        if name ~= CurrentGlovebox or CurrentGlovebox == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    end
end)



--[[ function GetContainer()
    local player = PlayerPedId()
	local startPosition = GetOffsetFromEntityInWorldCoords(player, 0, 0.1, 0)
	local endPosition = GetOffsetFromEntityInWorldCoords(player, 0, 1.8, -0.4)
	local a, b, c, d, hitData = GetShapeTestResult(StartShapeTestRay(startPosition.x,startPosition.y,startPosition.z,endPosition.x,endPosition.y,endPosition.z, 16, player, 0))

	local model = 0
	local vector = nil
	if hitData then
		model = GetEntityModel(hitData)
    end
    if model ~= 0 then
		for k, v in pairs(objectDumps) do
            if k ~= nil then
                if (objectDumps[k].objectID == model) then
					return GetEntityCoords(hitData)
                end
			end
        end
    end
end ]]

RegisterKeyMapping('inventory', 'Open Inventory', 'keyboard', 'F2')
RegisterKeyMapping('inventorySlot1', 'Use Slot 1', 'keyboard', '1')
RegisterKeyMapping('inventorySlot2', 'Use Slot 2', 'keyboard', '2')
RegisterKeyMapping('inventorySlot3', 'Use Slot 3', 'keyboard', '3')
RegisterKeyMapping('inventorySlot4', 'Use Slot 4', 'keyboard', '4')
RegisterKeyMapping('inventorySlot5', 'Use Slot 5', 'keyboard', '5')
RegisterKeyMapping('+inventoryActionMenu', 'Inventory Action Menu', 'keyboard', 'TAB')
RegisterKeyMapping('inventorySlot41', 'Use Vehicle Keys', 'keyboard', 'L')

RegisterCommand('inventory', function()
    OpenInventory()
end, false)

RegisterCommand('inventorySlot1', function()
    OpenInventorySlot1()
end, false)

RegisterCommand('inventorySlot2', function()
    OpenInventorySlot2()
end, false)

RegisterCommand('inventorySlot3', function()
    OpenInventorySlot3()
end, false)

RegisterCommand('inventorySlot4', function()
    OpenInventorySlot4()
end, false)

RegisterCommand('inventorySlot5', function()
    OpenInventorySlot5()
end, false)

RegisterCommand('inventorySlot41', function()
    OpenInventorySlot41()
end, false)

RegisterCommand('+inventoryActionMenu', function()
    ToggleHotbar(true)
end, false)

RegisterCommand('-inventoryActionMenu', function()
    ToggleHotbar(false)
end, false)

TriggerEvent('chat:removeSuggestion', '/inventory')
TriggerEvent('chat:removeSuggestion', '/inventorySlot1')
TriggerEvent('chat:removeSuggestion', '/inventorySlot2')
TriggerEvent('chat:removeSuggestion', '/inventorySlot3')
TriggerEvent('chat:removeSuggestion', '/inventorySlot4')
TriggerEvent('chat:removeSuggestion', '/inventorySlot5')
TriggerEvent('chat:removeSuggestion', '/+inventoryActionMenu')
TriggerEvent('chat:removeSuggestion', '/-inventoryActionMenu')

--[[ function OpenInventoryActionMenu()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 5)
        end
    end)
end ]]

RegisterNetEvent('inventory:client:open:tray', function(Numbers)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "foodtray"..Numbers, {
        maxweight = 100000, slots = 3
    })
    TriggerEvent("inventory:client:SetCurrentStash", "foodtray"..Numbers)
end)

-- CreateThread(function()
--     while true do
--         Wait(7)
--         DisableControlAction(0, Keys["F2"], true)
--         DisableControlAction(0, Keys["1"], true)
--         DisableControlAction(0, Keys["2"], true)
--         DisableControlAction(0, Keys["3"], true)
--         DisableControlAction(0, Keys["4"], true)
--         DisableControlAction(0, Keys["5"], true)
--         if IsDisabledControlJustPressed(0, Keys["F2"]) and not isCrafting then
--             --local BinFound = GetContainer()
            
--         end

--         --[[ if IsControlJustPressed(0, Keys["Z"]) then
--             ToggleHotbar(true)
--         end

--         if IsControlJustReleased(0, Keys["Z"]) then
--             ToggleHotbar(false)
--         end ]]

--         if IsDisabledControlJustReleased(0, Keys["1"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 1)
--                 end
--             end)
--         end

--         if IsDisabledControlJustReleased(0, Keys["2"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 2)
--                 end
--             end)
--         end

--         if IsDisabledControlJustReleased(0, Keys["3"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 3)
--                 end
--             end)
--         end

--         if IsDisabledControlJustReleased(0, Keys["4"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 4)
--                 end
--             end)
--         end

--         if IsDisabledControlJustReleased(0, Keys["5"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 5)
--                 end
--             end)
--         end

--         if IsDisabledControlJustReleased(0, Keys["6"]) then
--             QBCore.Functions.GetPlayerData(function(PlayerData)
--                 if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
--                     TriggerServerEvent("inventory:server:UseItemSlot", 41)
--                 end
--             end)
--         end
--     end
-- end)

RegisterNetEvent('inventory:client:ItemBox', function(itemData, type)
    SendNUIMessage({
        action = "itemBox",
        item = itemData,
        type = type
    })
end)

RegisterNetEvent('inventory:client:requiredItems', function(items, bool)
    local itemTable = {}
    if bool then
        for k, v in pairs(items) do
            table.insert(itemTable, {
                item = items[k].name,
                label = SharedItems[items[k].name]["label"],
                image = items[k].image,
            })
        end
    end
    
    SendNUIMessage({
        action = "requiredItem",
        items = itemTable,
        toggle = bool
    })
end)

--[[ CreateThread(function()
    while true do
        local sleep = 1000
        if DropsNear ~= nil then
            sleep = 3
            for k, v in pairs(DropsNear) do
                if DropsNear[k] ~= nil then
                    DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 255, false, false, false, 1, false, false, false)
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        DropsNear = {}
        local sleep = 1000
        if Drops ~= nil and next(Drops) ~= nil then
            local pos = GetEntityCoords(PlayerPedId(), true)
            CurrentDrop = 0
            for k, v in pairs(Drops) do
                if Drops[k] ~= nil then
                    if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) < 10.0 then
                        sleep = 500
                        DropsNear[k] = v
                        if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) < 2 then
                            CurrentDrop = k
                        end
                    else
                        DropsNear[k] = nil
                    end
                end
            end
        end
        Wait(sleep)
    end
end) ]]

RegisterNetEvent("inventory:client:StartDropsThread", function()
    local PlayerPed = PlayerPedId()
    CreateThread(function()
        while dropsThreadStarted and DropsInRange > 0 do
            local sleep = 1000
            local PlayerPos = GetEntityCoords(PlayerPed)
            if DropsNear ~= nil then
                for k, v in pairs(DropsNear) do
                    --if DropsNear[k] ~= nil then
                        if #(PlayerPos - vec3(v.coords.x, v.coords.y, v.coords.z)) < 10 then
                            sleep = 2
                            DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 255, false, false, false, 1, false, false, false)
                        end
                    --end
                end
            end
            Wait(sleep)
        end
    end)
end)

RegisterNetEvent("inventory:client:StartDropsThread", function()
    CreateThread(function()
        while dropsThreadStarted and DropsInRange > 0 do
            DropsNear = {}
            --local sleep = 1500
            if Drops ~= nil and next(Drops) ~= nil then
                local pos = GetEntityCoords(PlayerPedId(), true)
                CurrentDrop = 0
                for k, v in pairs(Drops) do
                    if Drops[k] ~= nil then
                        if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) < 15.0 then
                            --sleep = 500
                            DropsNear[k] = v
                            if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) < 2 then
                                CurrentDrop = k
                            end
                        else
                            DropsNear[k] = nil
                        end
                    end
                end
            end
            Wait(1500)
        end
    end)
end)

RegisterNetEvent('inventory:server:RobPlayer', function(TargetId)
    SendNUIMessage({
        action = "RobMoney",
        TargetId = TargetId,
    })
end)

RegisterNUICallback('RobMoney', function(data, cb)
    TriggerServerEvent("police:server:RobPlayer", data.TargetId)
    cb('ok')
end)

RegisterNUICallback('Notify', function(data, cb)
    QBCore.Functions.Notify(data.message, data.type)
    cb('ok')
end)

RegisterNetEvent("inventory:client:OpenInventory", function(PlayerAmmo, inventory, other)
    if not IsEntityDead(PlayerPedId()) then
        ToggleHotbar(false)
        SetNuiFocus(true, true)
        if other ~= nil then
            currentOtherInventory = other.name
        end
        -- if not blur then
        --     blur = true
        --     while IsScreenblurFadeRunning() do
        --         Wait(0)
        --     end
        --     TriggerScreenblurFadeIn(400)
        -- end
        TriggerScreenblurFadeIn(0)
        SendNUIMessage({
            action = "open",
            inventory = inventory,
            slots = MaxInventorySlots,
            other = other,
            maxweight = QBCore.Config.Player.MaxWeight,
            Ammo = PlayerAmmo,
            maxammo = Config.MaximumAmmoValues,
        })
        LocalPlayer.state:set("inv_busy", true, true)

        CreateThread(function()
            while LocalPlayer.state.inv_busy do
                DisableDisplayControlActions()
                Wait(0)
            end
        end)
    end
end)

local function trunkPosFunc()
    local trunkPosTime = 10000
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local ped = PlayerPedId()

    CreateThread(function()
        while trunkPosTime > 0 do
            Wait(0)
            trunkPosTime = trunkPosTime - 10
            if showTrunkPos and not LocalPlayer.state.inv_busy then
                if vehicle ~= 0 and vehicle ~= nil then
                    local pos = GetEntityCoords(ped)
                    local vehpos = GetEntityCoords(vehicle)
                    if (#(pos - vehpos) < 5.0) and not IsPedInAnyVehicle(ped) then
                        local drawpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                        if (IsBackEngine(GetEntityModel(vehicle))) then
                            drawpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                        end
                        local vehModel = GetEntityModel(vehicle)
                        if (IsCustomTrunkPosition(vehModel)) then --need this for custom job vehicle trunk positions
                            drawpos = GetOffsetFromEntityInWorldCoords(vehicle, Config.CustomTrunkPosition[vehModel].x, Config.CustomTrunkPosition[vehModel].y, Config.CustomTrunkPosition[vehModel].z)
                        end
                        QBCore.Functions.DrawText3D(drawpos.x, drawpos.y, drawpos.z, "Trunk")
                    else
                        showTrunkPos = false
                    end
                end
            end
        end
    end)
end

RegisterNetEvent("inventory:client:ShowTrunkPos", function()
    showTrunkPos = true
    trunkPosFunc()
end)

RegisterNetEvent("inventory:client:UpdatePlayerInventory", function(isError)
    SendNUIMessage({
        action = "update",
        inventory = QBCore.Functions.GetPlayerData().items,
        maxweight = QBCore.Config.Player.MaxWeight,
        slots = MaxInventorySlots,
        error = isError,
    })
end)

RegisterNetEvent("inventory:client:CraftItems", function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftItems", itemName, itemCosts, amount, toSlot, points, securityToken)
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed!", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftAttachment", itemName, itemCosts, amount, toSlot, points, securityToken)
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed!", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:MechanicCraft', function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:MechanicCraft", itemName, itemCosts, amount, toSlot, points, securityToken)
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed!", "error")
        isCrafting = false
	end)
end)

-- RegisterNetEvent("inventory:client:PickupSnowballs", function()
--     local ped = PlayerPedId()
--     lib.requestAnimDict("anim@mp_snowball")
--     TaskPlayAnim(ped, 'anim@mp_snowball', 'pickup_snowball', 3.0, 3.0, -1, 0, 1, 0, 0, 0)
--     QBCore.Functions.Progressbar("pickupsnowball", "Packing snowball..", 1500, false, true, {
--         disableMovement = true,
--         disableCarMovement = true,
--         disableMouse = false,
--         disableCombat = true,
--     }, {}, {}, {}, function() -- Done
--         ClearPedTasks(ped)
--         TriggerServerEvent('QBCore:Server:AddItem', "snowball", 1)
--         TriggerEvent('inventory:client:ItemBox', SharedItems["snowball"], "add")
--     end, function() -- Cancel
--         ClearPedTasks(ped)
--         QBCore.Functions.Notify("Canceled..", "error")
--     end)
-- end)

RegisterNetEvent("inventory:client:UseSnowball", function(amount)
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, GetHashKey("weapon_snowball"), amount, false, false)
    SetPedAmmo(ped, GetHashKey("weapon_snowball"), amount)
    SetCurrentPedWeapon(ped, GetHashKey("weapon_snowball"), true)
end)

local function FormatWeaponAttachments(itemdata)
    local attachments = {}
    itemdata.name = itemdata.name:upper()
    if itemdata.info.attachments ~= nil and next(itemdata.info.attachments) ~= nil then
        for k, v in pairs(itemdata.info.attachments) do
            if Config.WeaponAttachments[itemdata.name] ~= nil then
                for key, value in pairs(Config.WeaponAttachments[itemdata.name]) do
                    if #value > 0 then
                        for a, s in pairs(value) do
                            if s.component == v.component then
                                table.insert(attachments, {
                                    attachment = key,
                                    label = s.label,
                                    item = s.item,
                                })
                            end
                        end
                    else
                        if value.component == v.component then
                            table.insert(attachments, {
                                attachment = key,
                                label = value.label,
                                item = value.item,
                            })
                        end
                    end
                end
            end
        end
    end
    return attachments
end

RegisterNUICallback('GetWeaponData', function(data, cb)
    local data = {
        WeaponData = SharedItems[data.weapon],
        AttachmentData = FormatWeaponAttachments(data.ItemData)
    }
    cb(data)
end)

RegisterNUICallback('RemoveAttachment', function(data, cb)
    local WeaponData = SharedItems[data.WeaponData.name]
    local Attachment = Config.WeaponAttachments[WeaponData.name:upper()][data.AttachmentData.attachment]

    if #Attachment > 0 then
        for k, v in pairs(Attachment) do
            if data.AttachmentData.item == v.item then
                Attachment = v
            end
        end
    end

    QBCore.Functions.TriggerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
        if NewAttachments ~= false then
            local Attachies = {}
            RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            for k, v in pairs(NewAttachments) do
                for wep, pew in pairs(Config.WeaponAttachments[WeaponData.name:upper()]) do
                    if #pew > 0 then
                        for a, s in pairs(Config.WeaponAttachments[WeaponData.name:upper()][wep]) do
                            if v.component == s.component then
                                table.insert(Attachies, {
                                    attachment = s.item,
                                    label = s.label,
                                })
                            end
                        end
                    else
                        if v.component == pew.component then
                            table.insert(Attachies, {
                                attachment = pew.item,
                                label = pew.label,
                            })
                        end
                    end
                end
            end
            local sentData = {
                Attachments = Attachies,
                WeaponData = WeaponData,
            }
            cb(sentData)
        else
            RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            cb({})
        end
    end, data.AttachmentData, data.WeaponData)
end)

local zones = {}

function onEnter(self)
    DropsInRange = DropsInRange + 1
    if DropsInRange == 1 then
        dropsThreadStarted = true
        TriggerEvent("inventory:client:StartDropsThread")
    end
    --print("onEnter", DropsInRange)
end

function onExit(self)
    DropsInRange = DropsInRange - 1
    if DropsInRange == 0 then
        dropsThreadStarted = false
    end
    --print("onExit", DropsInRange)
end

RegisterNetEvent("inventory:client:AddDropItem", function(dropId, player, sourceCoords)
    local coords = sourceCoords
    local forward = GetEntityForwardVector(GetPlayerPed(GetPlayerFromServerId(player)))
	local x, y, z = table.unpack(coords + forward * 0.5)
    Drops[dropId] = {
        id = dropId,
        coords = {
            x = x,
            y = y,
            z = z - 0.3,
        },
    }

    zones[dropId] = lib.zones.sphere({
        coords = vec3(x, y, z),
        radius = 10,
        --debug = true,
        onEnter = onEnter,
        onExit = onExit
    })

    -- zones[dropId]:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
    --     if isPointInside then
    --         DropsInRange = DropsInRange + 1
    --         if DropsInRange == 1 then
    --             dropsThreadStarted = true
    --             TriggerEvent("inventory:client:StartDropsThread")
    --         end
    --     else
    --         DropsInRange = DropsInRange - 1
    --         if DropsInRange == 0 then
    --             dropsThreadStarted = false
    --         end
    --     end
    -- end)
end)

--local zones2 = {}
function CreateDropZones()
    for k, v in pairs(Drops) do
        zones[k] = lib.zones.sphere({
            coords = vec3(v.coords.x, v.coords.y, v.coords.z),
            name="invdrop_"..k,
            radius = 10,
            --debug = true,
            onEnter = onEnter,
            onExit = onExit
        })

        -- zones[k]:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        --     if isPointInside then
        --         DropsInRange = DropsInRange + 1
        --         if DropsInRange == 1 then
        --             dropsThreadStarted = true
        --             TriggerEvent("inventory:client:StartDropsThread")
        --         end
        --     else
        --         DropsInRange = DropsInRange - 1
        --         if DropsInRange == 0 then
        --             dropsThreadStarted = false
        --         end
        --     end
        -- end)
    end
end

RegisterNetEvent("inventory:client:RemoveDropItem", function(dropId)
    Drops[dropId] = nil
    zones[dropId]:remove()
    if dropsThreadStarted then
        DropsInRange = DropsInRange - 1
    end
end)

RegisterNetEvent("inventory:client:DropItemAnim", function()
    SendNUIMessage({
        action = "close",
    })
    lib.requestAnimDict("pickup_object")
    TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Wait(1800)
    ClearPedTasks(PlayerPedId())
end)

--[[ RegisterNetEvent("inventory:client:ShowId")
AddEventHandler("inventory:client:ShowId", function(sourceId, citizenid, character, sourceCoords)
    local pos = GetEntityCoords(PlayerPedId(), false)
    local dist = #(sourceCoords - pos)
    if (dist < 2.0) then
        local gender = "Man"
        if character.gender == 1 then
            gender = "Woman"
        end
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>CID:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>Birth Date:</strong> {4} <br><strong>Geslacht:</strong> {5} <br><strong>Nationality:</strong> {6}</div></div>',
            args = {'ID Card', character.citizenid, character.firstname, character.lastname, character.birthdate, gender, character.nationality}
        })
    end
end) ]]

--[[ RegisterNetEvent("inventory:client:ShowDriverLicense")
AddEventHandler("inventory:client:ShowDriverLicense", function(sourceId, citizenid, character, sourceCoords)
    local pos = GetEntityCoords(PlayerPedId(), false)
    local dist = #(sourceCoords - pos)
    if (dist < 2.0) then
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
            args = {'Driver License', character.firstname, character.lastname, character.birthdate, character.type}
        })
    end
end) ]]

RegisterNetEvent("inventory:client:SetCurrentStash", function(stash)
    CurrentStash = stash
end)

RegisterNUICallback('getCombineItem', function(data, cb)
    cb(SharedItems[data.item])
end)

RegisterNUICallback("CloseInventory", function(data, cb)
    if LocalPlayer.state.inv_busy then
        if currentOtherInventory == "none-inv" then
            CurrentDrop = 0
            CurrentVehicle = nil
            CurrentGlovebox = nil
            CurrentStash = nil
            SetNuiFocus(false, false)
            LocalPlayer.state:set("inv_busy", false, true)
            ClearPedTasks(PlayerPedId())
            return
        end
        if CurrentVehicle ~= nil then
            CloseTrunk()
            TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
            CurrentVehicle = nil
        elseif CurrentGlovebox ~= nil then
            TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
            CurrentGlovebox = nil
        elseif CurrentStash ~= nil then
            TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
            CurrentStash = nil
        else
            TriggerServerEvent("inventory:server:SaveInventory", "drop", CurrentDrop)
            CurrentDrop = 0
        end
        
        SetNuiFocus(false, false)
        LocalPlayer.state:set("inv_busy", false, true)
        -- if blur then
        --     blur = false
        --     while IsScreenblurFadeRunning() do
        --         Wait(0)
        --     end
        --     TriggerScreenblurFadeOut(400)
        -- end
        TriggerScreenblurFadeOut(0)
    end
    cb('ok')
end)

--[[ RegisterNUICallback("UpdateStash", function(data, cb)
    if CurrentVehicle ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
    elseif CurrentGlovebox ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
    elseif CurrentStash ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
    else
        TriggerServerEvent("inventory:server:SaveInventory", "drop", CurrentDrop)
    end
end) ]]

RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("inventory:server:UseItem", data.inventory, data.item)
    cb('ok')
end)

RegisterNUICallback("ModifyItem", function(data, cb)
    --print(data.slot) --slot
    --print(data.name) --item name
    TriggerServerEvent('qb-inventory:server:modifyItem', data.slot, data.name)
    cb('ok')
end)

RegisterNUICallback("combineItem", function(data, cb)
    Wait(150)
    TriggerServerEvent('inventory:server:combineItem', data.reward, data.fromItem, data.toItem)
    cb('ok')
end)

RegisterNUICallback('combineWithAnim', function(data, cb)
    local combineData = data.combineData
    local aDict = combineData.anim.dict
    local aLib = combineData.anim.lib
    local animText = combineData.anim.text
    local animTimeout = combineData.anim.timeOut

    QBCore.Functions.Progressbar("combine_anim", animText, animTimeout, false, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = aDict,
        anim = aLib,
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
        TriggerServerEvent('inventory:server:combineItem', combineData.reward, data.requiredItem, data.usedItem)
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
        QBCore.Functions.Notify("Canceled!", "error")
    end)
    cb('ok')
end)

RegisterNUICallback("SetInventoryData", function(data, cb)
    TriggerServerEvent("inventory:server:SetInventoryData", data.fromInventory, data.toInventory, data.fromSlot, data.toSlot, data.fromAmount, data.toAmount)
    cb('ok')
end)

RegisterNUICallback("PlayDropSound", function(_, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", false, 0, true)
    cb('ok')
end)

RegisterNUICallback("PlayDropFail", function(_, cb)
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", false, 0, true)
    cb('ok')
end)

RegisterNetEvent("inventory:client:closeInventory", function()
    if currentOtherInventory == "none-inv" then
        CurrentDrop = 0
        CurrentVehicle = nil
        CurrentGlovebox = nil
        CurrentStash = nil
        SetNuiFocus(false, false)
        LocalPlayer.state:set("inv_busy", false, true)
        ClearPedTasks(PlayerPedId())
        return
    end
    if CurrentVehicle ~= nil then
        CloseTrunk()
        TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
        CurrentVehicle = nil
    elseif CurrentGlovebox ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
        CurrentGlovebox = nil
    elseif CurrentStash ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
        CurrentStash = nil
    else
        TriggerServerEvent("inventory:server:SaveInventory", "drop", CurrentDrop)
        CurrentDrop = 0
    end
    SetNuiFocus(false, false)
    LocalPlayer.state:set("inv_busy", false, true)
    SendNUIMessage({
        action = "close",
    })
end)