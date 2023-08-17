--local QBCore = exports['qb-core']:GetCoreObject()

local BackItems = {
    --[[ ["markedbills"] = { -- Item Name
        model="prop_money_bag_01", -- Model you want to display
        back_bone = 24818, -- PED bone the entity is attached to.
        -- Location of the model on the players back. Note this is and offset relative to the players bone coords.
        x = -0.4,
        y = -0.17,
        z = -0.12,
        -- Rotaion of the object.
        x_rotation = 0.0,
        y_rotation = 90.0,
        z_rotation = 0.0,
    }, ]]
    ["meth"] = {
        model="hei_prop_pill_bag_01", 
        back_bone = 24818,
        x = -0.1,
        y = -0.17,
        z = 0.12,
        x_rotation = 0.0,
        y_rotation = 90.0,
        z_rotation = 0.0,
    },
    ["weapon_scarsc"] = {
        model="scarsc", 
        back_bone = 24818,
        x = 0.0,
        y = -0.17,
        z = -0.12,
        x_rotation = 0.0,
        y_rotation = -180.0,
        z_rotation = 180.0,
    },
    ["weapon_assaultrifle"] = {
        model="w_ar_assaultrifle",
        back_bone = 24818,
        x = 0.0,
        y = -0.17,
        z = -0.05,
        x_rotation = 0.0,
        y_rotation = -180.0,
        z_rotation = 180.0,
    },
    ["weapon_carbinerifle"] = {
        model="w_ar_carbinerifle",
        back_bone = 24818,
        x = 0.0,
        y = -0.17,
        z = 0.08,
        x_rotation = 0.0,
        y_rotation = -180.0,
        z_rotation = 180.0,
    },
    ["weapon_rpg"] = {
        model="w_lr_rpg",
        back_bone = 24818,
        x = 0.2,
        y = -0.17,
        z = 0.0,
        x_rotation = 0.0,
        y_rotation = 180.0,
        z_rotation = 180.0,
    },
    --[[ ["coke_brick"] = {
        model="bkr_prop_coke_cutblock_01", 
        back_bone = 24818,
        x = -0.20,
        y = -0.17,
        z = 0.0,
        x_rotation = 0.0,
        y_rotation = 90.0,
        z_rotation = 90.0,
    },
    ["weed_bud"] = {
        model="bkr_prop_weed_drying_01a", 
        back_bone = 24818,
        x = -0.20,
        y = -0.17,
        z = 0.0,
        x_rotation = 0.0,
        y_rotation = 90.0,
        z_rotation = 0.0,
    }, ]]
}

local CurrentBackItems = {}
local TempBackItems = {}
local currentWeapon = nil
local slots = 41 --qbcore max slots, find global reference
local s = {}

--Functions
local function createBackItem(item)
    if CurrentBackItems[item] then return end
    if BackItems[item] then
        local i = BackItems[item]
        local model = i["model"]
        print(i["model"])
        local bone = GetPedBoneIndex(cache.ped, i["back_bone"])
        lib.requestModel(model)
        SetModelAsNoLongerNeeded(model)
        CurrentBackItems[item] = CreateObject(joaat(model), 1.0, 1.0, 1.0, true, true, false)   
        local y = i["y"]
        if QBCore.Functions.GetPlayerData().charinfo.gender == 1 then y = y + 0.035 end
        AttachEntityToEntity(CurrentBackItems[item], cache.ped, bone, i["x"], y, i["z"], i["x_rotation"], i["y_rotation"], i["z_rotation"], 0, 1, 0, 1, 0, 1)
        SetEntityCompletelyDisableCollision(CurrentBackItems[item], false, true)
    end
end

local function removeBackItem(item)
    if CurrentBackItems[item] then
        DeleteEntity(CurrentBackItems[item])
        CurrentBackItems[item] = nil
    end
end

local function check()
    for i = 1, slots do
        if s[i] ~= nil then
            local name = s[i].name
            if BackItems[name] then
                if name ~= currentWeapon then
                    createBackItem(name)
                end
            end
        end
    end

    for k,v in pairs(CurrentBackItems) do
        local hasItem = false
        for j = 1, slots do
            if s[j] ~= nil then
                local name = s[j].name
                if name == k then 
                    hasItem = true
                end
            end
        end
        if not hasItem then 
            removeBackItem(k)
        end
    end
end

local function removeAllBackItems()
    for k,v in pairs(CurrentBackItems) do 
        removeBackItem(k)
    end
end

local function resetItems()
    removeAllBackItems()
    CurrentBackItems = {}
    TempBackItems = {}
    currentWeapon = nil
    s = {}
end

AddEventHandler('onClientResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    --BackLoop()
    if LocalPlayer.state.isLoggedIn then
        local player = QBCore.Functions.GetPlayerData()
        while player == nil do 
            player = QBCore.Functions.GetPlayerData()
            Wait(500)
        end
        for i = 1, slots do
            s[i] = player.items[i]
        end
        check()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    resetItems()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    local PlayerData = QBCore.Functions.GetPlayerData()
    while PlayerData == nil do
        PlayerData = QBCore.Functions.GetPlayerData()
        Wait(500)
    end
    for i = 1, slots do
        s[i] = PlayerData.items[i]
    end
    check()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    resetItems()
end)

-- RegisterNetEvent("backitems:start", function()
--     Wait(10000)
--     BackLoop()
-- end)

RegisterNetEvent("inventory:client:CheckDroppedItem", function(item)
    if BackItems[item] == nil then return end
    local HasBackItem = QBCore.Functions.HasItem(item)
    if HasBackItem then return end
    removeBackItem(item)
end)

RegisterNetEvent("inventory:client:CheckPickupItem", function(item)
    if BackItems[item] == nil then return end
    createBackItem(item)
end)

-- function table.shallow_copy(t)
--     local t2 = {}
--     for k,v in pairs(t) do
--         t2[k] = v
--     end
--     return t2
-- end

RegisterNetEvent("backitems:displayItems", function(toggle)
    print(toggle)
    if toggle then
        for k, v in pairs(TempBackItems) do
            createBackItem(k)
        end
        TempBackItems = {}
    else
        TempBackItems = lib.table.deepclone(CurrentBackItems)
        for k, v in pairs(CurrentBackItems) do
            removeBackItem(k)
        end
        CurrentBackItems = {}
    end
end)

RegisterNetEvent("backitems:refreshItems", function()
    TriggerEvent("backitems:displayItems", false)
    Wait(500)
    TriggerEvent("backitems:displayItems", true)
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(weap, shootbool)
    if weap == nil then
        createBackItem(currentWeapon)
        currentWeapon = nil
    else
        if currentWeapon ~= nil then
            createBackItem(currentWeapon)
            currentWeapon = nil
        end
        currentWeapon = tostring(weap.name)
        removeBackItem(currentWeapon)
    end
end)