local QBCore = exports['qb-core']:GetCoreObject()
local inside = false
local currentHouse = nil
local closestHouse
local inRange
local lockpicking = false
local houseObj = {}
local POIOffsets = nil
local usingAdvanced = false
local requiredItemsShowed = false
local requiredItems = {}
local CurrentCops = 0
local openingDoor = false
local SucceededAttempts = 0
local NeededAttempts = 4

-- Functions

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

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end


-- Container player anim

local function openHouseAnim()
    loadAnimDict("anim@heists@keycard@")
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(400)
    ClearPedTasks(PlayerPedId())
end

-- Container robbery enter function

local function enterRobberyHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.10)
    openHouseAnim()
    Wait(250)
    local coords = { x = Config.Containers[house]["coords"]["x"], y = Config.Containers[house]["coords"]["y"], z= Config.Containers[house]["coords"]["z"] - Config.MinZOffset}
    if Config.Containers[house]["tier"] == 1 then
        data = exports['qb-interior']:CreateContainerRobbery(coords)
    end
    Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    currentHouse = house
    Wait(500)
    TriggerEvent('qb-weathersync:client:DisableContainer')
end

-- Container robbery leave function

local function leaveRobberyHouse(house)
    local ped = PlayerPedId()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.10)
    openHouseAnim()
    Wait(250)
    DoScreenFadeOut(250)
    Wait(500)
    exports['qb-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('qb-weathersync:client:EnableSync')
        Wait(250)
        DoScreenFadeIn(250)
        SetEntityCoords(ped, Config.Containers[house]["coords"]["x"], Config.Containers[house]["coords"]["y"], Config.Containers[house]["coords"]["z"] + 0.5)
        SetEntityHeading(ped, Config.Containers[house]["coords"]["h"])
        inside = false
        currentHouse = nil
    end)
end

--Police call

local function PoliceCall()
    local chance = 75
    if GetClockHours() >= 1 and GetClockHours() <= 6 then
        chance = 65
    end
    if math.random(1, 100) <= chance then
        exports['qb-dispatch']:HouseRobbery()
    end
end

-- If lockpick success or fail

local function lockpickFinish(success)
    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
    if success then
        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
        TriggerServerEvent('qb-container-robbery:server:enterHouse', closestHouse)
        QBCore.Functions.Notify(Lang:t("success.worked"), "success", 2500)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 2))
    else
        local itemInfo = QBCore.Shared.Items["hardcutter"]
        if math.random(1, 100) < 20 then
            TriggerServerEvent("QBCore:Server:RemoveItem", "hardcutter", 1)
            TriggerEvent('inventory:client:ItemBox', itemInfo, "remove")
            TriggerServerEvent('hud:server:GainStress', math.random(1, 2))
        end
        QBCore.Functions.Notify(Lang:t("error.didnt_work"), "error", 2500)
        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
    end
end

-- Animation for lockpicking

local function LockpickDoorAnim()
    openingDoor = true
    CreateThread(function()
        while true do
            if openingDoor then
                TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            else
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                break
            end
            Wait(1000)
        end
    end)
end

-- Gloves things

local function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == `mp_m_freemode_01` then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

local function searchCabin(cabin)
    local ped = PlayerPedId()
    local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
    if math.random(1, 100) <= 85 and not IsWearingHandshoes() then
        local pos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end
    LockpickDoorAnim()
    TriggerServerEvent('qb-container-robbery:server:SetBusyState', cabin, currentHouse, true)
    FreezeEntityPosition(ped, true)
    IsLockpicking = true
    Skillbar.Start({
        duration = math.random(7500, 15000),
        pos = math.random(10, 30),
        width = math.random(10, 20),
    }, function()
        if SucceededAttempts + 1 >= NeededAttempts then
            openingDoor = false
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('qb-container-robbery:server:searchCabin', cabin, currentHouse)
            Config.Containers[currentHouse]["furniture"][cabin]["searched"] = true
            TriggerServerEvent('qb-container-robbery:server:SetBusyState', cabin, currentHouse, false)
            SucceededAttempts = 0
            FreezeEntityPosition(ped, false)
            SetTimeout(500, function()
                IsLockpicking = false
            end)
        else
            Skillbar.Repeat({
                duration = math.random(700, 1250),
                pos = math.random(10, 40),
                width = math.random(10, 13),
            })
            SucceededAttempts = SucceededAttempts + 1
        end
    end, function()
        openingDoor = false
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent('qb-container-robbery:server:SetBusyState', cabin, currentHouse, false)
        QBCore.Functions.Notify(Lang:t("error.process_cancelled"), "error", 3500)
        SucceededAttempts = 0
        FreezeEntityPosition(ped, false)
        SetTimeout(500, function()
            IsLockpicking = false
        end)
    end)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-container-robbery:server:GetHouseConfig', function(HouseConfig)
        Config.Containers = HouseConfig
    end)
end)

RegisterNetEvent('qb-container-robbery:client:ResetHouseState', function(house)
    Config.Containers[house]["opened"] = false
    for k, v in pairs(Config.Containers[house]["furniture"]) do
        v["searched"] = false
    end
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('qb-container-robbery:client:enterHouse', function(house)
    enterRobberyHouse(house)
end)

RegisterNetEvent('qb-container-robbery:client:setHouseState', function(house, state)
    Config.Containers[house]["opened"] = state
end)

RegisterNetEvent('qb-container-robbery:client:setCabinState', function(house, cabin, state)
    Config.Containers[house]["furniture"][cabin]["searched"] = state
end)

RegisterNetEvent('qb-container-robbery:client:SetBusyState', function(cabin, house, bool)
    Config.Containers[house]["furniture"][cabin]["isBusy"] = bool
end)

RegisterNetEvent('lockpicks:heavycutters', function(isAdvanced)
    local ped = PlayerPedId()
    local hours = GetClockHours()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local seconds = math.random(17,19)
    local circles = math.random(3,5)

    if hours >= Config.MinimumTime or hours <= Config.MaximumTime then
        usingAdvanced = isAdvanced
        if usingAdvanced then
            if closestHouse ~= nil then
                if CurrentCops >= Config.MinimumHouseRobberyPolice then
                    if not Config.Containers[closestHouse]["opened"] then
                        PoliceCall()
                        loadAnimDict("veh@break_in@0h@p_m_one@")
                        TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
                        if PlayerData.metadata['tolvaj'] >= 20 then
                            seconds = math.random(17,19)
                            circles = math.random(3,4)
                        else
                            seconds = math.random(12,15)
                            circles = math.random(10,11)
                        end
                        local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                        lockpickFinish(success)            
                        if math.random(1, 100) <= 85 and not IsWearingHandshoes() then
                            local pos = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                            StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                        end
                    else
                        QBCore.Functions.Notify(Lang:t("error.door_open"), "error", 3500)
                        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    end
                else
                    QBCore.Functions.Notify(Lang:t("error.not_enough_police"), "error", 3500)
                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                end
            end
        else
            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                if closestHouse ~= nil then
                    if result then
                        if CurrentCops >= Config.MinimumHouseRobberyPolice then
                            if not Config.Containers[closestHouse]["opened"] then
                                PoliceCall()
                                loadAnimDict("veh@break_in@0h@p_m_one@")
                                TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
                                if PlayerData.metadata['tolvaj'] >= 20 then
                                    seconds = math.random(17,19)
                                    circles = math.random(3,4)
                                else
                                    seconds = math.random(12,15)
                                    circles = math.random(10,11)
                                end
                                local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                                lockpickFinish(success)
                                if math.random(1, 100) <= 85 and not IsWearingHandshoes() then
                                    local pos = GetEntityCoords(PlayerPedId())
                                    TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                end
                            else
                                QBCore.Functions.Notify(Lang:t("error.door_open"), "error", 3500)
                                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                            end
                        else
                            QBCore.Functions.Notify(Lang:t("error.not_enough_police"), "error", 3500)
                            StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                        end
                    else
                        QBCore.Functions.Notify(Lang:t("error.missing_something"), "error", 3500)
                        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    end
                end
            end, "hardcutter")
        end
    end
end)

-- Threads

CreateThread(function()
    Wait(500)
    requiredItems = {
        [1] = {name = QBCore.Shared.Items["hardcutter"]["name"], image = QBCore.Shared.Items["hardcutter"]["image"]},
    }
    while true do
        inRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)
        closestHouse = nil
        if QBCore ~= nil then
            local hours = GetClockHours()
            if hours >= Config.MinimumTime or hours <= Config.MaximumTime then
                if not inside then
                    for k, v in pairs(Config.Containers) do
                        dist = #(PlayerPos - vector3(Config.Containers[k]["coords"]["x"], Config.Containers[k]["coords"]["y"], Config.Containers[k]["coords"]["z"]))
                        if dist <= 1.5 then
                            closestHouse = k
                            inRange = true
                            if CurrentCops >= Config.MinimumHouseRobberyPolice then
                                if Config.Containers[k]["opened"] then
                                    DrawText3Ds(Config.Containers[k]["coords"]["x"], Config.Containers[k]["coords"]["y"], Config.Containers[k]["coords"]["z"], '~g~E~w~ - To Enter')
                                    if IsControlJustPressed(0, 38) then
                                        enterRobberyHouse(k)
                                    end
                                else
                                    if not requiredItemsShowed then
                                        requiredItemsShowed = true
                                        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if inside then Wait(1000) end
            if not inRange then
                if requiredItemsShowed then
                    requiredItemsShowed = false
                    TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                end
                Wait(1000)
            end
        end
        Wait(5)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if inside then
            if #(pos - vector3(Config.Containers[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.Containers[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.Containers[currentHouse]["coords"]["z"] - Config.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                DrawText3Ds(Config.Containers[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.Containers[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.Containers[currentHouse]["coords"]["z"] - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - To leave home')
                if IsControlJustPressed(0, 38) then
                    leaveRobberyHouse(currentHouse)
                end
            end

            for k, v in pairs(Config.Containers[currentHouse]["furniture"]) do
                if #(pos - vector3(Config.Containers[currentHouse]["coords"]["x"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["x"], Config.Containers[currentHouse]["coords"]["y"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["y"], Config.Containers[currentHouse]["coords"]["z"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["z"] - Config.MinZOffset)) < 2 then
                    if not Config.Containers[currentHouse]["furniture"][k]["searched"] then
                        if not Config.Containers[currentHouse]["furniture"][k]["isBusy"] then
                            DrawMarker(32, Config.Containers[currentHouse]["coords"]["x"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["x"], Config.Containers[currentHouse]["coords"]["y"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["y"], Config.Containers[currentHouse]["coords"]["z"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["z"] - Config.MinZOffset, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255, 255, 255, 190, false, false, false, true, false, false, false)
                            if not IsLockpicking then
                                if IsControlJustReleased(0, 38) then
                                    searchCabin(k)
                                end
                            end
                        else
                            DrawText3Ds(Config.Containers[currentHouse]["coords"]["x"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["x"], Config.Containers[currentHouse]["coords"]["y"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["y"], Config.Containers[currentHouse]["coords"]["z"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["z"] - Config.MinZOffset, 'Searching..')
                        end
                    else
                        DrawMarker(2, Config.Containers[currentHouse]["coords"]["x"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["x"], Config.Containers[currentHouse]["coords"]["y"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["y"], Config.Containers[currentHouse]["coords"]["z"] + Config.Containers[currentHouse]["furniture"][k]["coords"]["z"] - Config.MinZOffset, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255, 255, 255, 190, false, false, false, true, false, false, false)
                    end
                end
            end
        end

        if not inside then
            Wait(5000)
        end
        Wait(3)
    end
end)

-- Util Command (can be commented out - used for setting new spots in the config)

RegisterCommand('gethroffset', function()
    local coords = GetEntityCoords(PlayerPedId())
    local houseCoords = vector3(
        Config.Containers[currentHouse]["coords"]["x"],
        Config.Containers[currentHouse]["coords"]["y"],
        Config.Containers[currentHouse]["coords"]["z"] - Config.MinZOffset
    )
    if inside then
        local xdist = coords.x - houseCoords.x
        local ydist = coords.y - houseCoords.y
        local zdist = coords.z - houseCoords.z
        print('X: '..xdist)
        print('Y: '..ydist)
        print('Z: '..zdist)
    end
end)
