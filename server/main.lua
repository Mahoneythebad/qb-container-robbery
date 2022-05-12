local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function ResetHouseStateTimer(house)
    local num = math.random(3333333, 11111111)
    local time = tonumber(num)
    SetTimeout(time, function()
        Config.Containers[house]["opened"] = false
        for k, v in pairs(Config.Containers[house]["furniture"]) do
            v["searched"] = false
        end
        TriggerClientEvent('qb-container-robbery:client:ResetHouseState', -1, house)
    end)
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-container-robbery:server:GetHouseConfig', function(source, cb)
    cb(Config.Containers)
end)

-- Events

RegisterNetEvent('qb-container-robbery:server:SetBusyState', function(cabin, house, bool)
    Config.Containers[house]["furniture"][cabin]["isBusy"] = bool
    TriggerClientEvent('qb-container-robbery:client:SetBusyState', -1, cabin, house, bool)
end)

RegisterNetEvent('qb-container-robbery:server:enterHouse', function(house)
    local src = source
    if not Config.Containers[house]["opened"] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('qb-container-robbery:client:setHouseState', -1, house, true)
    end
    TriggerClientEvent('qb-container-robbery:client:enterHouse', src, house)
    Config.Containers[house]["opened"] = true
end)

RegisterNetEvent('qb-container-robbery:server:searchCabin', function(cabin, house)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local luck = math.random(1, 10)
    local itemFound = math.random(1, 4)
    local itemCount = 1

    local Tier = 1
    if Config.Containers[house]["tier"] == 1 then
        Tier = 1
    elseif Config.Containers[house]["tier"] == 2 then
        Tier = 2
    elseif Config.Containers[house]["tier"] == 3 then
        Tier = 3
    end

    if itemFound < 4 then
        if luck == 10 then
            itemCount = 3
        elseif luck >= 6 and luck <= 8 then
            itemCount = 2
        end

        for i = 1, itemCount, 1 do
            local randomItem = Config.Rewards[Tier][Config.Containers[house]["furniture"][cabin]["type"]][math.random(1, #Config.Rewards[Tier][Config.Containers[house]["furniture"][cabin]["type"]])]
            local itemInfo = QBCore.Shared.Items[randomItem]
            if math.random(1, 100) == 69 then
                randomItem = "painkillers"
                itemInfo = QBCore.Shared.Items[randomItem]
                Player.Functions.AddItem(randomItem, 2)
                TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            elseif math.random(1, 100) == 35 then
                    randomItem = "weed_og-kush_seed"
                    itemInfo = QBCore.Shared.Items[randomItem]
                    Player.Functions.AddItem(randomItem, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            else
                if not itemInfo["unique"] then
                    local itemAmount = math.random(1, 3)
                    if randomItem == "plastic" then
                        itemAmount = math.random(15, 30)
                    elseif randomItem == "goldchain" then
                        itemAmount = math.random(1, 4)
                    elseif randomItem == "pistol_ammo" then
                        itemAmount = math.random(1, 3)
                    elseif randomItem == "weed_skunk" then
                        itemAmount = math.random(1, 6)
                    elseif randomItem == "cryptostick" then
                        itemAmount = math.random(1, 2)
                    end

                    Player.Functions.AddItem(randomItem, itemAmount)
                else
                    Player.Functions.AddItem(randomItem, 1)
                end
                TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            end
            Wait(500)
            -- local weaponChance = math.random(1, 100)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.emty_box"), 'error')
    end

    Config.Containers[house]["furniture"][cabin]["searched"] = true
    TriggerClientEvent('qb-container-robbery:client:setCabinState', -1, house, cabin, true)
end)


QBCore.Functions.CreateUseableItem("hardcutter", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent("lockpicks:heavycutters", source, false)
end)