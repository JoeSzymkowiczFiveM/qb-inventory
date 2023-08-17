local wearing = false

local function isMaskItem(item)
    local response = false
    if string.find(item, "mask_") then response = true end
    return response
end

local function splitStr(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        result[#result+1] = match
    end
    return result
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if wearing then
        SetPedComponentVariation(cache.ped, 1, 0, 0)
        wearing = false
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if LocalPlayer.state.isLoggedIn then
        for _, v in pairs(QBCore.Functions.GetPlayerData().items) do
            if isMaskItem(v.name) then
                local index = splitStr(v.name, "_")[1]
                wearing = true
                SetPedComponentVariation(cache.ped, 1, Config.Masks[index], 0)
                break
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(r)
	SetPedComponentVariation(cache.ped, 1, 0, 0)
end)

RegisterNetEvent("inventory:client:CheckPickupItem", function(itemName)
end)

RegisterNetEvent("inventory:client:CheckDroppedItem", function(item)
    if isMaskItem(item) then
        local HasMask = QBCore.Functions.HasItem(item)
        if not HasMask then
            SetPedComponentVariation(cache.ped, 1, 0, 0)
            wearing = false
        end
    end
end)

RegisterNetEvent('masks:client:applyMask', function(maskIndex)
    if not wearing then --consider adding hasItem to prevent exploitation, maybe
        exports.dpemotes:PlayByCommand('adjusttie')
        QBCore.Functions.Progressbar("chain_misc", "Putting on mask..", 3000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            wearing = true
            SetPedComponentVariation(cache.ped, 1, maskIndex, 0)
            exports.dpemotes:CancelAnimation()
        end)
    else
        exports.dpemotes:PlayByCommand('adjusttie')
        QBCore.Functions.Progressbar("chain_misc", "Taking off mask..", 3000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            SetPedComponentVariation(cache.ped, 1, 0, 0)
            wearing = false
            exports.dpemotes:CancelAnimation()
        end)         
    end
end)