# Qb-Container  Robbery

##INSTALL
-Put hardcutter into your shareds/items lua.


**Dependencys:**
>**qb-lock**

## Add following lines to the qb-weathersync/client/client.lua (somewhere)
```
RegisterNetEvent('qb-weathersync:client:DisableContainer', function()
	disable = true
	CreateThread(function()
		while disable do
			SetRainLevel(0.0)
			SetWeatherTypePersist('FOGGY')
			SetWeatherTypeNow('FOGGY')
			SetWeatherTypeNowPersist('FOGGY')
			NetworkOverrideClockTime(23, 0, 0)
			Wait(5000)
		end
	end)
end)
```

## Add following lines to the qb-interior/client/main.lua (somewhere)

```
exports('CreateContainerRobbery', function(spawn)
	local objects = {}
    local POIOffsets = {}
	POIOffsets.exit = json.decode('{"x": 0.08, "y": -5.93, "z": 1.24, "h": 359.32}')
	POIOffsets.prop = json.decode('{"x": 0.00, "y": 4.7, "z": 1.24, "h": 359.32}')
	POIOffsets.prop2 = json.decode('{"x": 0.00, "y": 0.1, "z": 2.2, "h": 270.0}')
	POIOffsets.prop3 = json.decode('{"x": 0.00, "y": -1.0, "z": 1.84, "h": 270.0}')
	POIOffsets.prop4 = json.decode('{"x": 0.00, "y": -4.4, "z": 1.84, "h": 270.0}')
	POIOffsets.prop5 = json.decode('{"x": 0.77, "y": -0.7, "z": 0.0, "h": 360.0}')
	POIOffsets.prop6 = json.decode('{"x": -0.88, "y": -2.9, "z": 0.0, "h": 360.0}')
	POIOffsets.prop7 = json.decode('{"x": 0.82, "y": 0.9, "z": 0.0, "h": 360.0}')
	POIOffsets.prop8 = json.decode('{"x": 1.27, "y": -3.1, "z": 1.35, "h": 360.0}')
	POIOffsets.prop9 = json.decode('{"x": 1.2, "y": -3.0, "z": 0.1, "h": 360.0}')
	POIOffsets.prop10 = json.decode('{"x": -1.19, "y": 0.8, "z": 0.1, "h": 360.0}')
	POIOffsets.prop11 = json.decode('{"x": 0.0, "y": 0.0, "z": 2.5, "h": 360.0}')
	POIOffsets.prop12 = json.decode('{"x": -0.9, "y": 4.0, "z": 1.8, "h": 360.0}')
	POIOffsets.prop13 = json.decode('{"x": -1.2, "y": 1.2, "z": 0.1, "h": 360.0}')
	POIOffsets.prop14 = json.decode('{"x": -1.34, "y": 0.5, "z": 0.9, "h": 360.0}')
	POIOffsets.prop15 = json.decode('{"x": 0.79, "y": 0.9, "z": 0.8, "h": 360.0}')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
	RequestModel(`container_shell`)
	while not HasModelLoaded(`container_shell`) do
	    Wait(1000)
	end
	local house = CreateObject(`container_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
	local newprop = CreateObject(`ba_prop_battle_crate_art_02_bc`, spawn.x, spawn.y + POIOffsets.prop.y, spawn.z, false, false, false)
	local newprop2 = CreateObject(`hei_prop_hei_cont_light_01`, spawn.x, spawn.y + POIOffsets.prop2.y, spawn.z + POIOffsets.prop2.z, false, false, false)

	local newprop5 = CreateObject(`gr_prop_gr_drillcage_01a`, spawn.x + POIOffsets.prop5.x, spawn.y + POIOffsets.prop5.y, spawn.z + POIOffsets.prop5.z, false, false, false)
	local newprop6 = CreateObject(`gr_prop_gr_crates_pistols_01a`, spawn.x + POIOffsets.prop6.x, spawn.y + POIOffsets.prop6.y, spawn.z + POIOffsets.prop6.z, false, false, false)
	local newprop7 = CreateObject(`gr_prop_gr_bench_02b`, spawn.x + POIOffsets.prop7.x, spawn.y + POIOffsets.prop7.y, spawn.z + POIOffsets.prop7.z, false, false, false)
	local newprop8 = CreateObject(`v_ret_neon_baracho`, spawn.x + POIOffsets.prop8.x, spawn.y + POIOffsets.prop8.y, spawn.z + POIOffsets.prop8.z, false, false, false)
	local newprop9 = CreateObject(`ex_office_swag_paintings01`, spawn.x + POIOffsets.prop9.x, spawn.y + POIOffsets.prop9.y, spawn.z + POIOffsets.prop9.z, false, false, false)
	local newprop10 = CreateObject(`w_am_fire_exting`, spawn.x + POIOffsets.prop10.x, spawn.y + POIOffsets.prop10.y, spawn.z + POIOffsets.prop10.z, false, false, false)
	local newprop11 = CreateObject(`xm_prop_lab_strip_lightbl`, spawn.x + POIOffsets.prop11.x, spawn.y + POIOffsets.prop11.y, spawn.z + POIOffsets.prop11.z, false, false, false)
	local newprop12 = CreateObject(`hei_prop_hei_carrier_disp_01`, spawn.x + POIOffsets.prop12.x, spawn.y + POIOffsets.prop12.y, spawn.z + POIOffsets.prop12.z, false, false, false)
	local newprop13 = CreateObject(`prop_security_case_01`, spawn.x + POIOffsets.prop13.x, spawn.y + POIOffsets.prop13.y, spawn.z + POIOffsets.prop13.z, false, false, false)
	local newprop14 = CreateObject(`prop_cash_depot_billbrd`, spawn.x + POIOffsets.prop14.x, spawn.y + POIOffsets.prop14.y, spawn.z + POIOffsets.prop14.z, false, false, false)
	local newprop15 = CreateObject(`prop_tool_bluepnt`, spawn.x + POIOffsets.prop15.x, spawn.y + POIOffsets.prop15.y, spawn.z + POIOffsets.prop15.z, false, false, false)
	SetEntityHeading(newprop7, -90.0)
	SetEntityHeading(newprop8, -90.0)
	SetEntityHeading(newprop9, -90.0)
	SetEntityHeading(newprop10, 90.0)
	SetEntityHeading(newprop11, 90.0)
	SetEntityHeading(newprop12, 60.0)
	SetEntityHeading(newprop13, 90.0)
	SetEntityHeading(newprop14, 90.0)
	SetEntityHeading(newprop15, 0.0)
    FreezeEntityPosition(house, true)
	FreezeEntityPosition(newprop, true)
	FreezeEntityPosition(newprop2, true)
	FreezeEntityPosition(newprop5, true)
	FreezeEntityPosition(newprop6, true)
	FreezeEntityPosition(newprop7, true)
	FreezeEntityPosition(newprop8, true)
	FreezeEntityPosition(newprop9, true)
	FreezeEntityPosition(newprop10, true)
	FreezeEntityPosition(newprop11, true)
	FreezeEntityPosition(newprop12, true)
	FreezeEntityPosition(newprop13, true)
	FreezeEntityPosition(newprop14, true)
	FreezeEntityPosition(newprop15, true)
    objects[#objects+1] = house
	objects[#objects+1] = newprop
	objects[#objects+1] = newprop2
	objects[#objects+1] = newprop5
	objects[#objects+1] = newprop6
	objects[#objects+1] = newprop7
	objects[#objects+1] = newprop8
	objects[#objects+1] = newprop9
	objects[#objects+1] = newprop10
	objects[#objects+1] = newprop11
	objects[#objects+1] = newprop12
	objects[#objects+1] = newprop13
	objects[#objects+1] = newprop14
	objects[#objects+1] = newprop15
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + POIOffsets.exit.z, POIOffsets.exit.h)
    return { objects, POIOffsets }
end)
```
