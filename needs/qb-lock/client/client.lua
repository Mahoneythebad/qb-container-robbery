local Result = nil
local NUI_status = false

function StartLockPickCircle(circles, seconds)
    Result = nil
    NUI_status = true
    SendNUIMessage({
        action = 'start',
        value = circles,
		time = seconds,
    })
    while NUI_status do
        Wait(5)
        SetNuiFocus(NUI_status, false)
    end
    Wait(100)
    SetNuiFocus(false, false)
    return Result
end

RegisterNUICallback('fail', function()
        ClearPedTasks(PlayerPedId())
        Result = false
        Wait(100)
        NUI_status = false
end)

RegisterNUICallback('success', function()
	Result = true
	Wait(100)
	NUI_status = false
    SetNuiFocus(false, false)
    return Result
end)

RegisterCommand("lockpick", function()
	local time = math.random(10,15)
	local circles = math.random(5,6)
	local success = exports['qb-lock']:StartLockPickCircle(circles, time)
	if success then
		print("win")
	else
		print("fail")
	end
end)