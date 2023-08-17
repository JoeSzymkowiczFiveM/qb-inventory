local backpackProp = nil

--Functions
local function RemoveBag()
    DeleteEntity(backpackProp)
    backpackProp = nil
end

local function CheckForBag()
    if LocalPlayer.state.isLoggedIn then
        -- QBCore.Functions.TriggerCallback('qb-backpack:verifyBackpack', function(backpackItem)
        --     if backpackItem == 'backpack_small' then
        --         local coords = GetEntityCoords(ped)
        --         backpackProp = CreateObject(`p_michael_backpack_s`, coords.x, coords.y, coords.z,  true,  true, true)
        --         AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
        --     elseif backpackItem == 'backpack_medium' then
        --         local coords = GetEntityCoords(ped)
        --         backpackProp = CreateObject(`prop_med_bag_01b`, coords.x, coords.y, coords.z,  true,  true, true)
        --         AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), 0.02, -0.15, -0.02, -30.0, 90.0, 0.0, true, true, false, true, 1, true)
        --     elseif backpackItem == 'backpack_large' then
        --         local coords = GetEntityCoords(ped)
        --         backpackProp = CreateObject(`hei_p_f_bag_var20_arm_s`, coords.x, coords.y, coords.z,  true,  true, true)
        --         AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), -0.30, -0.05, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
        --     end
        -- end)
        lib.callback('qb-backpack:verifyBackpack', false, function(backpackItem)
            local coords = GetEntityCoords(cache.ped)
            if backpackItem == 'backpack_small' then
                backpackProp = CreateObject(`p_michael_backpack_s`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, cache.ped, GetPedBoneIndex(cache.ped, 24818), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
            elseif backpackItem == 'backpack_medium' then
                backpackProp = CreateObject(`prop_med_bag_01b`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, cache.ped, GetPedBoneIndex(cache.ped, 24818), 0.02, -0.15, -0.02, -30.0, 90.0, 0.0, true, true, false, true, 1, true)
            elseif backpackItem == 'backpack_large' then
                backpackProp = CreateObject(`hei_p_f_bag_var20_arm_s`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, cache.ped, GetPedBoneIndex(cache.ped, 24818), -0.30, -0.05, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
            end
        end)
    end
end

--Events
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if LocalPlayer.state.isLoggedIn then
        CheckForBag()
    end
    TriggerScreenblurFadeOut(0)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if backpackProp ~= nil then
        RemoveBag()
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(1500)
    CheckForBag()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if backpackProp ~= nil then
        RemoveBag()
    end
end)

RegisterNetEvent('qb-backpack:client:openBackpack', function(backpackId, item)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.5)
    Wait(500)
    if item == 'backpack_small' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "backpack_" ..backpackId, { maxweight = 80000, slots = 5})
        TriggerEvent("inventory:client:SetCurrentStash", "backpack_" ..backpackId)
    elseif item == 'backpack_medium' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "backpack_" ..backpackId, { maxweight = 100000, slots = 8})
        TriggerEvent("inventory:client:SetCurrentStash", "backpack_" ..backpackId)
    elseif item == 'backpack_large' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "backpack_" ..backpackId, { maxweight = 120000, slots = 10})
        TriggerEvent("inventory:client:SetCurrentStash", "backpack_" ..backpackId)
    end
end)

RegisterNetEvent("inventory:client:CheckDroppedItem", function(item)
    if item == 'backpack_small' then
        local HasBackpack = QBCore.Functions.HasItem('backpack_small')
        if not HasBackpack then
            RemoveBag()
            CheckForBag()
        end
    elseif item == 'backpack_medium' then
        local HasBackpack = QBCore.Functions.HasItem('backpack_medium')
        if not HasBackpack then
            RemoveBag()
            CheckForBag()
        end
    elseif item == 'backpack_large' then
        local HasBackpack = QBCore.Functions.HasItem('backpack_large')
        if not HasBackpack then
            RemoveBag()
            CheckForBag()
        end
    end
end)

RegisterNetEvent("inventory:client:CheckPickupItem", function(itemName)
    if itemName == 'backpack_small' then
        local HasItem = QBCore.Functions.HasItem('backpack_small')
        if HasItem then
            if backpackProp == nil then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                backpackProp = CreateObject(`p_michael_backpack_s`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
            end
        end
    elseif itemName == 'backpack_medium' then
        local HasItem = QBCore.Functions.HasItem('backpack_medium')
        if HasItem then
            if backpackProp == nil then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                backpackProp = CreateObject(`prop_med_bag_01b`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), 0.02, -0.15, -0.02, -30.0, 90.0, 0.0, true, true, false, true, 1, true)
            end
        end
    elseif itemName == 'backpack_large' then
        local HasItem = QBCore.Functions.HasItem('backpack_large')
        if HasItem then
            if backpackProp == nil then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                backpackProp = CreateObject(`hei_p_f_bag_var20_arm_s`, coords.x, coords.y, coords.z,  true,  true, true)
                AttachEntityToEntity(backpackProp, ped, GetPedBoneIndex(ped, 24818), -0.30, -0.05, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
            end
        end
    end
end)

--[[ Citizen.CreateThread(function()
    while true do
        local mochilaprop = nil

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if LocalPlayer.state.isLoggedIn then
                QBCore.Functions.TriggerCallback('qb-backpack:verifyBackpack', function(mochilainv)
                    print(mochilainv)
                    if mochilainv == 'backpack_small' then
                        DeleteEntity(mochilaprop)
                        mochilaprop = CreateObject(GetHashKey('p_michael_backpack_s'), coords.x, coords.y, coords.z,  true,  true, true)
                        AttachEntityToEntity(mochilaprop, ped, GetPedBoneIndex(ped, 24818), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
                    elseif mochilainv == 'backpack_medium' then
                        DeleteEntity(mochilaprop)
                        mochilaprop = CreateObject(GetHashKey('prop_med_bag_01b'), coords.x, coords.y, coords.z,  true,  true, true)
                        AttachEntityToEntity(mochilaprop, ped, GetPedBoneIndex(ped, 24818), 0.02, -0.15, -0.02, -30.0, 90.0, 0.0, true, true, false, true, 1, true)
                    elseif mochilainv == 'backpack_large' then
                        DeleteEntity(mochilaprop)
                        mochilaprop = CreateObject(GetHashKey('hei_p_f_bag_var20_arm_s'), coords.x, coords.y, coords.z,  true,  true, true)
                        AttachEntityToEntity(mochilaprop, ped, GetPedBoneIndex(ped, 24818), -0.30, -0.05, -0.05, 0.0, 90.0, 175.0, true, true, false, true, 1, true)
                    else
                        DeleteEntity(mochilaprop)
                    end
                end)
            end
        Citizen.Wait(2500)
    end
end) ]]