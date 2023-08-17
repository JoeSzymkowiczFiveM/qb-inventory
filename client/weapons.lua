local CurrentWeaponData = {}
local CanShoot = true
local insideWeaponsRepair = false
local currentWeapon = nil
local copsCalled = false
local holdingWeapon = false
local MultiplierAmount = 0

lib.requestAnimDict("reaction@intimidation@1h")
lib.requestAnimDict("reaction@intimidation@cop@unarmed")
lib.requestAnimDict("rcmjosh4")
lib.requestAnimDict("weapons@pistol@")

--Functions
local function IsPedNearby()
	local retval = false
	local PlayerPeds = {}
    local ped = PlayerPedId()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        --table.insert(PlayerPeds, ped)
        PlayerPeds[#PlayerPeds+1] = ped
    end
    --local player = PlayerPedId()
    local coords = GetEntityCoords(ped)
	local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
	if not IsEntityDead(closestPed) and closestDistance < 100.0 then
		retval = true
	end
	return retval
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

local function IsWeaponStressBlocked(WeaponName)
    -- local retval = false
    -- for _, name in pairs(Config.StressBlockedWeapons) do
    --     if name == WeaponName then
    --         retval = true
    --         break
    --     end 
    -- end
    return Config.StressBlockedWeapons[WeaponName]
end

local function IsWeaponAlertsBlocked(WeaponName)
    local retval = false
    for _, name in pairs(Config.AlertsBlockedWeapons) do
        if name == WeaponName then
            retval = true
            break
        end 
    end
    return retval
end

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--RegisterNetEvent("holstergun", function(weapon)
local function holstergun()
    local rot = GetEntityHeading(cache.ped)
    if PlayerJob.name == "police" then
        TaskPlayAnimAdvanced(cache.ped, "rcmjosh4", "josh_leadout_cop2", GetEntityCoords(cache.ped, true), 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
        Wait(600)
        ClearPedTasks(cache.ped)
    else
        TaskPlayAnimAdvanced(cache.ped, "reaction@intimidation@1h", "intro", GetEntityCoords(cache.ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
        Wait(1800)
        ClearPedTasks(cache.ped)
    end
end

--RegisterNetEvent("unholstergun", function()

local function unholstergun()
    local rot = GetEntityHeading(cache.ped)
    if PlayerJob.name == "police" then
        TaskPlayAnimAdvanced(cache.ped, "reaction@intimidation@cop@unarmed", "intro", GetEntityCoords(cache.ped, true), 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
        Wait(500)
        ClearPedTasks(cache.ped)
    else
        TaskPlayAnimAdvanced(cache.ped, "reaction@intimidation@1h", "outro", GetEntityCoords(cache.ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
        Wait(1600)
        ClearPedTasks(cache.ped)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
    lib.callback('weapons:server:GetConfig', false, function(RepairPoints)
        for i=1, #RepairPoints do
            Config.WeaponRepairPoints[i]['IsRepairing'] = RepairPoints[i]['IsRepairing']
            Config.WeaponRepairPoints[i]['RepairingData'] = RepairPoints[i]['RepairingData']
        end
    end)
    --TriggerServerEvent("weapons:server:LoadWeaponAmmo")
    SetWeaponsNoAutoswap(true)
	--SetWeaponsNoAutoreload(1)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    CurrentWeaponData = {}
    PlayerJob = {}

    for i=1, #Config.WeaponRepairPoints do
        Config.WeaponRepairPoints[i]['IsRepairing'] = false
        Config.WeaponRepairPoints[i]['RepairingData'] = {}
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    while QBCore == nil do Wait(200) end
    if LocalPlayer.state.isLoggedIn then
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerJob = PlayerData.job
    end
    LocalPlayer.state:set("inv_busy", false, true)
    SetWeaponsNoAutoswap(true)
end)

local function CallCops()
    if copsCalled then
        CreateThread(function()
            Wait(1000 * 60)
            copsCalled = false
        end)
    end
end

-- AddEventHandler('ox_lib:cache:weapon', function(value)
--     if value then
--         CreateThread(function()
--             while cache.weapon do
--                 if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
--                     sleep = 200
--                     if IsPedShooting(cahce.ped) then
--                         sleep = 1
--                         if CanShoot then
--                             --local weapon = GetSelectedPedWeapon(ped)
--                             local ammo = GetAmmoInPedWeapon(cahce.ped, weapon)

--                             --[[ if ammo > 0 then
--                                 if not IsWeaponBlocked(CurrentWeaponData.name) then
--                                     MultiplierAmount = MultiplierAmount + 1
--                                 end
--                             end ]]
--                         else
--                             --TriggerEvent('inventory:client:CheckDroppedItem', SharedWeapons[weapon]["name"])
--                             QBCore.Functions.Notify("This weapon is broken and cannot be used..", "error")
--                             MultiplierAmount = 0
--                         end
--                     end
--                 end
--                 Wait(sleep)
--             end
--         end)
--     end
-- end)

-- RegisterNetEvent('weapon:client:StartWeaponsThread', function(weapon)
--     local ped = PlayerPedId()
--     CreateThread(function()
--         while holdingWeapon do
--             if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
--                 sleep = 200
--                 if IsPedShooting(ped) then
--                     sleep = 1
--                     if CanShoot then
--                         --local weapon = GetSelectedPedWeapon(ped)
--                         local ammo = GetAmmoInPedWeapon(ped, weapon)

--                         --[[ if ammo > 0 then
--                             if not IsWeaponBlocked(CurrentWeaponData.name) then
--                                 MultiplierAmount = MultiplierAmount + 1
--                             end
--                         end ]]
--                     else
--                         --TriggerEvent('inventory:client:CheckDroppedItem', SharedWeapons[weapon]["name"])
--                         QBCore.Functions.Notify("This weapon is broken and cannot be used..", "error")
--                         MultiplierAmount = 0
--                     end
--                 end
--             end
--             Wait(sleep)
--         end
--     end)
-- end)

--[[ CreateThread(function()
    while true do
        local weapon = GetSelectedPedWeapon(GLOBAL_PED)
        local ammo = GetAmmoInPedWeapon(GLOBAL_PED, weapon)
        --print("AMMO : "..ammo)
        sleep = 1000
        if GetSelectedPedWeapon(GLOBAL_PED) ~= `WEAPON_UNARMED` then
            sleep = 2
            if ammo == 1 then
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisablePlayerFiring(GLOBAL_PLYID, true)
                if IsPedInAnyVehicle(GLOBAL_PED, true) then
                    SetPlayerCanDoDriveBy(GLOBAL_PLYID, false)
                end
            else
                EnableControlAction(0, 24, true) -- Attack
                EnableControlAction(0, 257, true) -- Attack 2
                DisablePlayerFiring(GLOBAL_PLYID, false)
                if IsPedInAnyVehicle(GLOBAL_PED, true) then
                    SetPlayerCanDoDriveBy(GLOBAL_PLYID, true)
                end
            end

            if IsPedShooting(GLOBAL_PED) then
                if ammo - 1 < 1 then
                    SetAmmoInClip(GLOBAL_PED, GetHashKey(SharedWeapons[weapon]["name"]), 1)
                end
            end

            if not CanShoot then
                if tonumber(weapon) ~= `WEAPON_UNARMED` then
                    DisablePlayerFiring(GLOBAL_PLYID, true)
                end
            end
        end
        Wait(sleep) --changed from Wait(0), if weapons starts acting weird, change back
    end
end) ]]

AddEventHandler('ox_lib:cache:weapon', function(value)
    if value then
        CreateThread(function()
            while cache.weapon do
                local ammo = GetAmmoInPedWeapon(cache.ped, cache.weapon)
                if IsPedShooting(cache.ped) then
                    TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, tonumber(ammo))
                end
                Wait(5) --changed from Wait(0), if weapons starts acting weird, change back
            end
        end)
    end
end)

-- RegisterNetEvent('weapon:client:StartWeaponsThread', function(weapon)
--     local ped = PlayerPedId()
--     CreateThread(function()
--         while holdingWeapon do
--             local ammo = GetAmmoInPedWeapon(ped, weapon)
--             if IsPedShooting(ped) then
--                 TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, tonumber(ammo))
--             end
--             Wait(5) --changed from Wait(0), if weapons starts acting weird, change back
--         end
--     end)
-- end)

RegisterNetEvent('weapon:client:AddAmmo', function(type, amount, itemData)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if CurrentWeaponData ~= nil then
        if SharedWeapons[weapon]["ammotype"] ~= nil then
            if SharedWeapons[weapon]["name"] ~= "weapon_unarmed" and SharedWeapons[weapon]["ammotype"] == type:upper() then
                local total = GetAmmoInPedWeapon(ped, weapon)
                --local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
                local retval = tonumber(GetMaxAmmoInClip(ped, weapon, true))

                --if (total + retval) <= (retval + 1) then --only allow reload on completely empty
                if total < retval then --allow for reload if clip is not completely full; feels better imo but allows waste i guess
                    QBCore.Functions.Progressbar("taking_bullets", "Reloading..", math.random(4000, 6000), false, true, {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        if SharedWeapons[weapon] ~= nil then
                            weapon = GetSelectedPedWeapon(ped)
                            if SharedWeapons[weapon]["name"] ~= "weapon_unarmed" and SharedWeapons[weapon]["ammotype"] == type:upper() then
                                SetAmmoInClip(ped, weapon, 0)
                                SetPedAmmo(ped, weapon, retval)
                                TriggerServerEvent("weapons:server:AddWeaponAmmo", CurrentWeaponData, retval)
                                TriggerServerEvent('QBCore:Server:RemoveItem', itemData.name, 1, itemData.slot)
                                TriggerEvent('QBCore:Notify', " Loaded " .. retval .. " bullets!", "success")
                            else
                                QBCore.Functions.Notify("This is the wrong ammunition for this weapon..", "error")
                            end
                        end
                    end, function()
                        QBCore.Functions.Notify("Canceled..", "error")
                    end, "fa-solid fa-arrows-rotate")
                else
                    QBCore.Functions.Notify("Your weapon is already loaded..", "error")
                end
            else
                QBCore.Functions.Notify("You\'re not holding a weapon..", "error")
            end
        end
    else
        QBCore.Functions.Notify("You\'re not holding a weapon..", "error")
    end
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
    CanShoot = bool
end)

RegisterNetEvent('weapons:client:SetWeaponQuality', function(amount)
    if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
        TriggerServerEvent("weapons:server:SetWeaponQuality", CurrentWeaponData, amount)
    end
end)

RegisterNetEvent('weapons:client:insideWeaponsRepair', function()
    local ped = PlayerPedId()
    CreateThread(function()
        while insideWeaponsRepair do
            local pos = GetEntityCoords(ped)
            for k, data in pairs(Config.WeaponRepairPoints) do --if theres only 1 point, consider removing for loop
                local distance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))

                if distance < 1.5 then
                    if data.IsRepairing then
                        if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                            DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Currently busy...')
                        else
                            if not data.RepairingData.Ready then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Your weapon will be repaired')
                            else
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                            end
                        end
                    else
                        if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
                            if not data.RepairingData.Ready then
                                local WeaponData = SharedWeapons[joaat(CurrentWeaponData.name)]
                                if WeaponData ~= nil then
                                    local WeaponClass = (SplitStr(WeaponData.ammotype, "_")[2]):lower()
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Repair weapon - ~g~$'..Config.WeaponRepairCosts[WeaponClass]..'~w~')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        QBCore.Functions.TriggerCallback('weapons:server:RepairWeapon', function(HasMoney)
                                            if HasMoney then
                                                CurrentWeaponData = {}
                                            end
                                        end, k, CurrentWeaponData)
                                    end
                                end
                            else
                                if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop ~r~NOT~w~ available..')
                                else
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                                    end
                                end
                            end
                        else
                            if data.RepairingData.CitizenId == nil then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'You\'re not holding a weapon..')
                            elseif data.RepairingData.CitizenId == PlayerData.citizenid then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                                if IsControlJustPressed(0, Keys["E"]) then
                                    TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                                end
                            end
                        end
                    end
                end
            end
            Wait(3)
        end
    end)
end)

RegisterNetEvent("weapons:client:takeBackWeapon", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k, data in pairs(Config.WeaponRepairPoints) do --if theres only 1 point, consider removing for loop
        local distance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))

        if distance < 5.0 then
            --if not data.IsRepairing then
                if data.RepairingData.CitizenId == PlayerData.citizenid then
                    TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                    break
                end
            --end
        end
    end
end)

RegisterNetEvent("weapons:client:testWeaponsRepair2", function()
    local pos = GetEntityCoords(PlayerPedId())
    for k, data in pairs(Config.WeaponRepairPoints) do --if theres only 1 point, consider removing for loop
        if #(pos - vector3(data.coords.x, data.coords.y, data.coords.z)) < 5 then
            local options = {}

            local resgisteredMenu = {
                id = 'weapons_repairlist',
                title = 'Weapons Repair',
                options = {}
            }

            for a, s in pairs(QBCore.Functions.GetPlayerData().items) do
                if SharedItems[s.name]["type"] == 'weapon' then
                    local ammoType = SharedItems[s.name]["ammotype"]
                    if ammoType ~= nil then
                        options[#options+1] = {
                            title = SharedItems[s.name]["label"],

                            description = "Repair Cost - $"..Config.WeaponRepairCosts[(SplitStr(ammoType, "_")[2]):lower()],
                            event = 'weapons:client:testWeaponsRepair3',
                            metadata = {
                                {label = 'Serial', value = s.info.serie},                                
                            },
                            args = {spot = k, weaponData = s},
                        }
                    end
                end
            end

            if #options == 0 then
                options[#options+1] = {
                    title = 'You have no weapons on hand.',
                }
            end

            resgisteredMenu["options"] = options
            lib.registerContext(resgisteredMenu)
            lib.showContext('weapons_repairlist')
            break
        end
    end
end)

RegisterNetEvent("weapons:client:testWeaponsRepair3", function(data)
    QBCore.Functions.TriggerCallback('weapons:server:RepairWeapon', function(HasMoney)
        if HasMoney then
            CurrentWeaponData = {}

            TriggerEvent('weapons:ResetHolster')
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            RemoveAllPedWeapons(cache.ped, true)
            currentWeapon = nil
        end
    end, data.spot, data.weaponData)
end)

RegisterNetEvent("weapons:client:testWeaponsRepair", function()
    local pos = GetEntityCoords(PlayerPedId())
    for k, data in pairs(Config.WeaponRepairPoints) do --if theres only 1 point, consider removing for loop, unless making more points
        if #(pos - vector3(data.coords.x, data.coords.y, data.coords.z)) < 5 then

            local options = {}
            
            local resgisteredMenu = {
                id = 'weapons_repairlist',
                title = 'Weapons Repair',
                options = {}
            }

            if data.IsRepairing then
                if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                    --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Currently busy...')
                    options[#options+1] = {
                        description = "Repair station is busy",
                    }
                else
                    if not data.RepairingData.Ready then
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Your weapon will be repaired')
                        options[#options+1] = {
                            description = "Repair station is busy",
                        }
                    else
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                        options[#options+1] = {
                            description = "Take back weapon",
                            event = 'weapons:client:testWeaponsRepair3',
                        }
                    end
                end
            else
                if not data.RepairingData.Ready then
                    for a, s in pairs(QBCore.Functions.GetPlayerData().items) do
                        if SharedItems[s.name]["type"] == 'weapon' then
                            local ammoType = SharedItems[s.name]["ammotype"]
                            if ammoType ~= nil then
                                options[#options+1] = {
                                    title = SharedItems[s.name]["label"],
                                    
                                    description = "Repair Cost - $"..Config.WeaponRepairCosts[(SplitStr(ammoType, "_")[2]):lower()],
                                    event = 'weapons:client:testWeaponsRepair3',
                                    metadata = {
                                        {label = 'Serial', value = s.info.serie},
                                    },
                                    args = {spot = k, weaponData = s},
                                }
                            end
                        end
                    end
                else
                    if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop ~r~NOT~w~ available..')
                        options[#options+1] = {
                            description = "Repair station is busy",
                        }
                    else
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                        -- if IsControlJustPressed(0, Keys["E"]) then
                        --     TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                        -- end
                        options[#options+1] = {
                            description = "Take weapon back",
                            event = 'weapons:client:takeBackWeapon',
                        }
                    end
                end
            end

            resgisteredMenu["options"] = options
            lib.registerContext(resgisteredMenu)
            lib.showContext('weapons_repairlist')
            break
        end
    end
end)

RegisterNetEvent("weapons:client:SyncRepairShops", function(NewData, key)
    Config.WeaponRepairPoints[key].IsRepairing = NewData.IsRepairing
    Config.WeaponRepairPoints[key].RepairingData = NewData.RepairingData
end)

RegisterNetEvent("weapons:client:EquipAttachment", function(ItemData, attachment)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    
    if weapon ~= `WEAPON_UNARMED` then
        local WeaponData = SharedWeapons[weapon]
        

        WeaponData.name = WeaponData.name:upper()
        if Config.WeaponAttachments[WeaponData.name] ~= nil then
            if Config.WeaponAttachments[WeaponData.name:upper()][attachment] ~= nil then
                local AttachmentData = Config.WeaponAttachments[WeaponData.name:upper()][attachment]
                --Config.WeaponAttachments[WeaponData.name][attachment]
                --component, label, item
                if #Config.WeaponAttachments[WeaponData.name][attachment] > 0 then
                    for k, v in pairs(Config.WeaponAttachments[WeaponData.name][attachment]) do
                        if ItemData.name == v.item then
                            AttachmentData = v
                            TriggerServerEvent("weapons:server:EquipAttachment", ItemData, CurrentWeaponData, AttachmentData)
                        end
                    end
                    
                --else
                    --TriggerServerEvent("weapons:server:EquipAttachment", ItemData, CurrentWeaponData, AttachmentData)
                end
            else
                QBCore.Functions.Notify("This weapon does not support this attachment..", "error")
            end
        end
    else
        QBCore.Functions.Notify("You\'re not holding a weapon..", "error")
    end
end)

RegisterNetEvent("addAttachment", function(component)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    local WeaponData = SharedWeapons[weapon]
    GiveWeaponComponentToPed(ped, joaat(WeaponData.name), joaat(component))
end)

RegisterNetEvent("weapons:client:repairEvent", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k, data in pairs(Config.WeaponRepairPoints) do --if theres only 1 point, consider removing for loop
        local distance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))

        if distance < 2.0 then
            if data.IsRepairing then
                if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                    --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop is ~r~NOT~w~ open at the moment..')
                    QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                else
                    if not data.RepairingData.Ready then
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Your weapon will be repaired')
                        QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                    else
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                        QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                    end
                end
            else
                if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
                    if not data.RepairingData.Ready then
                        local WeaponData = SharedWeapons[joaat(CurrentWeaponData.name)]
                        if WeaponData ~= nil then
                            local WeaponClass = (SplitStr(WeaponData.ammotype, "_")[2]):lower()
                            --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Repair weapon - ~g~$'..Config.WeaponRepairCosts[WeaponClass]..'~w~')
                            QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                            QBCore.Functions.TriggerCallback('weapons:server:RepairWeapon', function(HasMoney)
                                if HasMoney then
                                    CurrentWeaponData = {}
                                end
                            end, k, CurrentWeaponData)
                        end
                    else
                        if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                            --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop ~r~NOT~w~ available..')
                            QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                        else
                            --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                            QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                            TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                        end
                    end
                else
                    if data.RepairingData.CitizenId == nil then
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'You\'re not holding a weapon..')
                        QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                    elseif data.RepairingData.CitizenId == PlayerData.citizenid then
                        --DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '~g~E~w~ - Take weapon back')
                        QBCore.Functions.Notify("The repairshop is ~r~NOT~w~ open at the moment..", "error")
                        TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
                    end
                end
            end
        end
    end
end)

-- AddEventHandler('ox_lib:cache:weapon', function(value)
--     if value then
--         CreateThread(function()
--             if PlayerJob.name ~= "police" and not IsWeaponStressBlocked(value) then
--                 while cache.weapon do
--                     if not LocalPlayer.state.inShootingRange then
--                         if IsPedShooting(ped) then
--                             local StressChance = math.random(20)
--                             local odd = math.random(20)
--                             if StressChance == odd then
--                                 TriggerServerEvent('qb-hud:Server:GainStress', 1)
--                                 Wait(1000)
--                             end
--                         end
--                     else
--                         Wait(1000)
--                     end
--                     Wait(5)
--                 end
--             end
--         end)
--     end
-- end)

-- AddEventHandler('ox_lib:cache:weapon', function(value)
--     if value then
--         CreateThread(function()
--             if PlayerJob.name ~= "police" and not IsWeaponStressBlocked(weapon) then
--                 while cache.weapon do
--                     if not LocalPlayer.state.inShootingRange then
--                         if IsPedShooting(ped) then
--                             local StressChance = math.random(1, 20)
--                             local odd = math.random(1, 20)
--                             if StressChance == odd then
--                                 TriggerServerEvent('qb-hud:Server:GainStress', 1)
--                             end
--                         end
--                     end
--                     Wait(5)
--                 end
--             end
--         end)
--     end
-- end)

-- RegisterNetEvent('weapon:client:StartWeaponsThread', function(weapon)
--     local ped = PlayerPedId()
--     CreateThread(function()
--         if PlayerJob.name ~= "police" and not IsWeaponStressBlocked(weapon) then
--             while holdingWeapon do
--                 if not LocalPlayer.state.inShootingRange then
--                     if IsPedShooting(ped) then
--                         local StressChance = math.random(1, 20)
--                         local odd = math.random(1, 20)
--                         if StressChance == odd then
--                             TriggerServerEvent('qb-hud:Server:GainStress', 1)
--                         end
--                     end
--                 end
--                 Wait(5)
--             end
--         end
--     end)
-- end)

AddEventHandler('ox_lib:cache:weapon', function(value)
    if value then
        local weapon = value
        CreateThread(function()
            if not IsPedCurrentWeaponSilenced(cache.ped) and weapon ~= -1600701090 and weapon ~= 2138347493 and weapon ~= 1233104067 and weapon ~= 1198879012 and weapon ~= 1813897027 and weapon ~= 883325847 and weapon ~= -1169823560 and weapon ~= -1420407917 and weapon ~= 126349499 and weapon ~= 741814745 and weapon ~= 911657153 and weapon ~= 101631238 and weapon ~= 615608432 and weapon ~= 600439132 and weapon ~= -37975472 then
                while cache.weapon and PlayerJob.name ~= "police" and not IsWeaponAlertsBlocked(weapon) do
                    if IsPedShooting(cache.ped) and IsPedNearby() and not LocalPlayer.state.inShootingRange then
                        if not copsCalled then
                            --local coords = GetEntityCoords(cache.ped)

                            -- local gender = QBCore.Functions.GetPlayerData().charinfo.gender
                            -- if gender == "man" then
                            --     gender = "Man"
                            -- else
                            --     gender = "Woman"
                            -- end

                            --exports['ps-dispatch']:addCall("10-32", "Shots Fired", {{icon = "fa-venus-mars", info = "Gender: " .. gender}}, {coords[1], coords[2], coords[3]}, {"police"}, 5000, 156, 1)
                            exports['ps-dispatch']:Shooting()
                            copsCalled = true --may not be needed anymore since dispatch handles this
                            CallCops()
                        end
                    end
                    Wait(5)
                end
            end
        end)
    end
end)

-- RegisterNetEvent('weapon:client:StartWeaponsThread', function(weapon)
--     local ped = PlayerPedId()
--     CreateThread(function()
--         if not IsPedCurrentWeaponSilenced(ped) and weapon ~= -1600701090 and weapon ~= 2138347493 and weapon ~= 1233104067 and weapon ~= 1198879012 and weapon ~= 1813897027 and weapon ~= 883325847 and weapon ~= -1169823560 and weapon ~= -1420407917 and weapon ~= 126349499 and weapon ~= 741814745 and weapon ~= 911657153 and weapon ~= 101631238 and weapon ~= 615608432 and weapon ~= 600439132 and weapon ~= -37975472 then 
--             while holdingWeapon and PlayerJob.name ~= "police" and not IsWeaponAlertsBlocked(weapon) do
--                 if IsPedShooting(ped) and IsPedNearby() and not LocalPlayer.state.inShootingRange then
--                     if not copsCalled then
--                         local coords = GetEntityCoords(ped)

--                         local gender = QBCore.Functions.GetPlayerData().charinfo.gender
--                         if gender == "man" then
--                             gender = "Man"
--                         else
--                             gender = "Woman"
--                         end

--                         --exports['ps-dispatch']:addCall("10-32", "Shots Fired", {{icon = "fa-venus-mars", info = "Gender: " .. gender}}, {coords[1], coords[2], coords[3]}, {"police"}, 5000, 156, 1)
--                         exports['ps-dispatch']:Shooting()
--                         copsCalled = true --may not be needed anymore since dispatch handles this
--                         TriggerEvent('qb-inventory:client:CallCops')
--                     end
--                 end
--                 Wait(5)
--             end
--         end
--     end)
-- end)

--[[ local WeaponsRepairZone = PolyZone:Create({
    vector2(-344.10729980468, 6109.5249023438),
    vector2(-357.35079956054, 6097.8642578125),
    vector2(-347.81127929688, 6088.2368164062),
    vector2(-335.68936157226, 6100.4936523438)
    }, {
    name="weapons_repair",
    minZ = 30.0,
    maxZ = 33.0,
    debugGrid = false,
    gridDivisions = 25
}) ]]

-- function weaponsOnEnter(self)
--     insideWeaponsRepair = true
--     TriggerEvent("weapons:client:insideWeaponsRepair")
-- end

-- function weaponsOnExit(self)
--     insideWeaponsRepair = false
-- end

-- local sphere = lib.zones.sphere({
--     coords = vector3(-342.450164, 6097.649414, 31.31027221),
--     radius = 20,
--     --debug = true,
--     onEnter = weaponsOnEnter,
--     onExit = weaponsOnExit
-- })

-- WeaponsRepairZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
--     if isPointInside then
--         insideWeaponsRepair = true
--         TriggerEvent("weapons:client:insideWeaponsRepair")
--     else
--         insideWeaponsRepair = false
--     end
-- end)

--[[ RegisterNetEvent('weapon:client:StartWeaponsThread', function(weapon)
	CreateThread(function()
		while holdingWeapon do
			if not canFire then
				DisableControlAction(0, 25, true)
				DisablePlayerFiring(GLOBAL_PED, true)
			end
			Wait(4)
		end
	end)
end) ]]

RegisterNetEvent("inventory:client:UseWeapon", function(weaponData, shootbool)
    local ped = PlayerPedId()
    local weaponName = tostring(weaponData.name)
    local weaponHash = joaat(weaponName)
    if currentWeapon == weaponName then
        holstergun()
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        RemoveAllPedWeapons(ped, true)
        TriggerEvent('weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif weaponName == "weapon_grenade" or weaponName == "weapon_flare" or weaponName == "weapon_smokegrenade" or weaponName == "weapon_bzgas" or weaponName == "weapon_molotov"  or weaponName == "weapon_stickybomb" or weaponName == "weapon_book" or weaponName == "weapon_cash" or weaponName == "weapon_shoe" or weaponName == "weapon_brick" then
        unholstergun()
        GiveWeaponToPed(ped, weaponHash, ammo, false, false)
        SetPedAmmo(ped, weaponHash, 1)
        SetCurrentPedWeapon(ped, weaponHash, true)
        TriggerServerEvent('QBCore:Server:RemoveItem', weaponName, 1)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        local itemInfo = SharedItems[weaponData.name]
        TriggerEvent('inventory:client:ItemBox', itemInfo, "use")
        currentWeapon = weaponName
    else
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        QBCore.Functions.TriggerCallback("weapon:server:GetWeaponAmmo", function(result)
            local ammo = tonumber(result)
            if weaponName == "weapon_petrolcan" or weaponName == "weapon_fireextinguisher" then
                ammo = 4000
            end
            unholstergun()
            GiveWeaponToPed(ped, weaponHash, ammo, false, false)
            local itemInfo = SharedItems[weaponData.name]
            TriggerEvent('inventory:client:ItemBox', itemInfo, "use")
            SetPedAmmo(ped, weaponHash, ammo)
            SetCurrentPedWeapon(ped, weaponHash, true)
            if weaponData.info.attachments ~= nil then
                for _, attachment in pairs(weaponData.info.attachments) do
                    GiveWeaponComponentToPed(ped, weaponHash, joaat(attachment.component))
                end
            end
            if weaponData.info.tint ~= nil then
                SetPedWeaponTintIndex(ped, weaponHash, weaponData.info.tint)
            end
            currentWeapon = weaponName
        end, CurrentWeaponData)
    end
end)

RegisterNetEvent("inventory:client:CheckDroppedItem", function(item)
    if currentWeapon ~= item then return end
    --local ped = PlayerPedId()
    TriggerEvent('weapons:ResetHolster')
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    RemoveAllPedWeapons(cache.ped, true)
    currentWeapon = nil
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
        -- for k, v in pairs(CurrentWeaponData) do
        --     print(k, tostring(v))
        -- end
    else
        CurrentWeaponData = {}
    end
end)

local mk2Weapons = {
    [1432025498] = true,
    [961495388] = true,
    [-86904375] = true,
    [-1768145561] = true,
    [-2066285827] = true,
    [-608341376] = true,
    [177293209] = true,
    [1785463520] = true,
    [4208062921] = true,
}

local origTints = {
    "Default", "Green", "Gold", "Pink", "Camo", "LSPD", "Orange", "Platinum", 
}

local mk2Tints = {
    'Classic Black',
    'Classic Gray',
    'Classic Two-Tone',
    'Classic White',
    'Classic Beige',
    'Classic Green',
    'Classic Blue',
    'Classic Earth',
    'Classic Brown & Black',
    'Red Contrast',
    'Blue Contrast',
    'Yellow Contrast',
    'Orange Contrast',
    'Bold Pink',
    'Bold Purple & Yellow',
    'Bold Orange',
    'Bold Green & Purple',
    'Bold Red Features',
    'Bold Green Features',
    'Bold Cyan Features',
    'Bold Yellow Features',
    'Bold Red & White',
    'Bold Blue & White',
    'Metallic Gold',
    'Metallic Platinum',
    'Metallic Gray & Lilac',
    'Metallic Purple & Lime',
    'Metallic Red',
    'Metallic Green',
    'Metallic Blue',
    'Metallic White & Aqua',
    'Metallic Orange & Yellow',
    'Mettalic Red and Yellow',
}

local function TintsMenu()
    local ped = PlayerPedId()
	local weaponhash = GetSelectedPedWeapon(ped)
    if weaponhash == `WEAPON_UNARMED` then return end
    local mk2Weapon = false
    if mk2Weapons[weaponhash] then mk2Weapon = true end

    local resgisterMe = {
        id = 'tints_menu',
        title = 'Weapons Tints',
        options = {}
    }
    local options = {}

    if mk2Weapon then 
        for k, v in pairs(mk2Tints) do
            options[#options+1] = {
                title = v .. ' Weapon Tint',
                description = 'Apply this tint',
                onSelect = function(args)
                    SetPedWeaponTintIndex(ped, weaponhash, k-1)
                    local data = CurrentWeaponData
                    TriggerServerEvent('weapons:client:SetCurrentWeaponTint', data.slot, data.name, k-1)
                end,
            }
        end
    else
        for k, v in pairs(origTints) do
            options[#options+1] = {
                title = v .. ' Weapon Tint',
                description = 'Apply this tint',
                onSelect = function(args)
                    SetPedWeaponTintIndex(ped, weaponhash, k-1)
                    local data = CurrentWeaponData
                    TriggerServerEvent('weapons:client:SetCurrentWeaponTint', data.slot, data.name, k-1)
                end,
            }
        end
    end

    resgisterMe["options"] = options
    lib.registerContext(resgisterMe)
    lib.showContext('tints_menu')
end

RegisterCommand("weapontints", TintsMenu)