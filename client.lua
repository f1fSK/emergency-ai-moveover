-- Don't touch this file unless you know what you're doing.
-- Report any issues on the GitHub repository.

Citizen.CreateThread(function()
    local lastMoved = {}
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if playerVeh ~= 0 and IsVehicleSirenOn(playerVeh) and GetVehicleClass(playerVeh) == 18 then
            local emergencyPos = GetEntityCoords(playerVeh)
            local playerPos = GetEntityCoords(playerPed)
            local vehicles = {}
            local handle, vehFound = FindFirstVehicle()
            local success
            repeat
                if vehFound ~= playerVeh and DoesEntityExist(vehFound) then
                    local vehPos = GetEntityCoords(vehFound)
                    if #(emergencyPos - vehPos) < 30.0 then
                        table.insert(vehicles, vehFound)
                    end
                end
                success, vehFound = FindNextVehicle(handle)
            until not success
            EndFindVehicle(handle)
            for _, v in ipairs(vehicles) do
                local ped = GetPedInVehicleSeat(v, -1)
                if ped ~= 0 and not IsPedAPlayer(ped) then
                    if not lastMoved[v] or (GetGameTimer() - lastMoved[v]) > 5000 then
                        local vehPos = GetEntityCoords(v)
                        local dx = playerPos.x - vehPos.x
                        local dy = playerPos.y - vehPos.y
                        local heading = GetEntityHeading(v)
                        local angle = math.deg(math.atan2(dy, dx)) - heading
                        angle = (angle + 360) % 360
                        local model = GetEntityModel(v)
                        local class = GetVehicleClass(v)
                        local offsetX = 6.5
                        if class == 8 or class == 10 or class == 18 or class == 20 then
                            offsetX = 20.0 
                        end
                        local side, offset
                        if angle > 270 or angle < 90 then
                            offset = GetOffsetFromEntityInWorldCoords(v, offsetX, 15.0, 0.0)
                        else
                            offset = GetOffsetFromEntityInWorldCoords(v, -offsetX, 15.0, 0.0)
                        end
                        TaskVehicleDriveToCoord(ped, v, offset.x, offset.y, offset.z, 10.0, 0, model, 786599, 1.0, true)
                        TaskVehicleTempAction(ped, v, 27, 6000)
                        lastMoved[v] = GetGameTimer()
                    end
                end
            end
        end
    end
end)