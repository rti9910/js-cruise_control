-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            Client                                │
-- └──────────────────────────────────────────────────────────────────┘

local limiterEnabled = false
local currentLimit = Config.DefaultLimit
local activeVehicle = nil
local originalMaxSpeeds = {}
local getDriverVehicle

local function showNativeNotification(message)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(false, false)
end

local function notify(message, notificationType)
	if not Config.ShowNotifications then
		return
	end

	if not getDriverVehicle() then
		return
	end

	local provider = Config.NotifyProvider or 'auto'
	local notificationType = notificationType or 'inform'

	if provider == 'auto' then
		if GetResourceState('ox_lib') == 'started' then
			provider = 'ox_lib'
		elseif GetResourceState('es_extended') == 'started' then
			provider = 'esx'
		elseif GetResourceState('qb-core') == 'started' then
			provider = 'qbcore'
		elseif GetResourceState('okokNotify') == 'started' then
			provider = 'okokNotify'
		else
			provider = 'native'
		end
	end

	if provider == 'ox_lib' and GetResourceState('ox_lib') == 'started' and lib and lib.notify then
		lib.notify({
			title = Config.NotificationTitle,
			description = message,
			type = notificationType,
			duration = Config.NotificationDuration
		})
	elseif provider == 'esx' and GetResourceState('es_extended') == 'started' then
		local esx = exports['es_extended']:getSharedObject()
		esx.ShowNotification(message)
	elseif provider == 'qbcore' and GetResourceState('qb-core') == 'started' then
		local qbCore = exports['qb-core']:GetCoreObject()
		local qbType = notificationType == 'inform' and 'primary' or notificationType
		qbCore.Functions.Notify(message, qbType, Config.NotificationDuration)
	elseif provider == 'okokNotify' and GetResourceState('okokNotify') == 'started' then
		local okokType = notificationType == 'inform' and 'info' or notificationType
		exports['okokNotify']:Alert(
			Config.NotificationTitle,
			message,
			Config.NotificationDuration,
			okokType
		)
	elseif provider == 'custom' then
		TriggerEvent(Config.CustomNotificationEvent, message, notificationType)
	else
		showNativeNotification(message)
	end
end

getDriverVehicle = function()
	local ped = PlayerPedId()

	if not IsPedInAnyVehicle(ped, false) then
		return nil
	end

	local vehicle = GetVehiclePedIsIn(ped, false)

	if Config.RequireDriverSeat and GetPedInVehicleSeat(vehicle, -1) ~= ped then
		return nil
	end

	local vehicleClass = GetVehicleClass(vehicle)
	if vehicleClass == 15 or vehicleClass == 16 then
		return nil
	end

	if not Config.AllowInEmergencyVehicles and GetVehicleClass(vehicle) == 18 then
		return nil
	end

	return vehicle
end

local function toMetersPerSecond(speed)
	if Config.SpeedUnit == 'mph' then
		return speed / 2.236936
	end

	return speed / 3.6
end

local function fromMetersPerSecond(speed)
	if Config.SpeedUnit == 'mph' then
		return speed * 2.236936
	end

	return speed * 3.6
end

local function restoreVehicle(vehicle)
	if vehicle and DoesEntityExist(vehicle) and originalMaxSpeeds[vehicle] then
		SetEntityMaxSpeed(vehicle, originalMaxSpeeds[vehicle])
		originalMaxSpeeds[vehicle] = nil
	end
end

local function disableLimiter(message)
	limiterEnabled = false
	restoreVehicle(activeVehicle)
	activeVehicle = nil

	if message then
		notify(message)
	end
end

local function toggleLimiter()
	if limiterEnabled then
		disableLimiter('Cruise control disabled.')
		return
	end

	local vehicle = getDriverVehicle()
	if not vehicle then
		notify('You must be in a vehicle other than a plane or helicopter to use cruise control.')
		return
	end

	local speed = fromMetersPerSecond(GetEntitySpeed(vehicle))
	if speed < Config.MinimumLimit then
		notify(('You must be moving at least %s %s to enable cruise control.'):format(
			Config.MinimumLimit,
			Config.SpeedUnit
		))
		return
	end

	currentLimit = math.floor(math.max(Config.MinimumLimit, math.min(Config.MaximumLimit, speed)) + 0.5)
	limiterEnabled = true
	activeVehicle = vehicle
	notify(('Cruise control enabled: %s %s.'):format(currentLimit, Config.SpeedUnit))
end

local function adjustLimit(amount)
	if not getDriverVehicle() then
		return
	end

	currentLimit = math.max(
		Config.MinimumLimit,
		math.min(Config.MaximumLimit, currentLimit + amount)
	)

	if limiterEnabled then
		notify(('Speed limit set to %s %s.'):format(currentLimit, Config.SpeedUnit))
	else
		notify(('Speed limit set to %s %s. Press . to enable it.'):format(currentLimit, Config.SpeedUnit))
	end
end

RegisterCommand('speedlimiter_toggle', toggleLimiter, false)
RegisterCommand('speedlimiter_increase', function()
	adjustLimit(Config.SpeedStep)
end, false)
RegisterCommand('speedlimiter_decrease', function()
	adjustLimit(-Config.SpeedStep)
end, false)

if Config.EnableKeyMapping then
	RegisterKeyMapping('speedlimiter_toggle', 'Toggle vehicle speed limiter', 'keyboard', Config.ToggleKey)
	RegisterKeyMapping('speedlimiter_increase', 'Increase speed limiter', 'keyboard', Config.SpeedUpKey)
	RegisterKeyMapping('speedlimiter_decrease', 'Decrease speed limiter', 'keyboard', Config.SpeedDownKey)
end

RegisterCommand(Config.Command, function(_, args)
	local requestedLimit = tonumber(args[1])

	if not requestedLimit then
		notify(('Usage: /%s <speed>'):format(Config.Command))
		return
	end

	local vehicle = getDriverVehicle()
	if not vehicle then
		notify('You must be in a vehicle other than a plane or helicopter to use cruise control.')
		return
	end

	if fromMetersPerSecond(GetEntitySpeed(vehicle)) < Config.MinimumLimit then
		notify(('You must be moving at least %s %s to enable cruise control.'):format(
			Config.MinimumLimit,
			Config.SpeedUnit
		))
		return
	end

	currentLimit = math.floor(math.max(
		Config.MinimumLimit,
		math.min(Config.MaximumLimit, requestedLimit)
	) + 0.5)
	limiterEnabled = true
	activeVehicle = vehicle
	notify(('Cruise control set to %s %s.'):format(currentLimit, Config.SpeedUnit))
end, false)

RegisterCommand(Config.ClearCommand, function()
	disableLimiter('Cruise control disabled.')
end, false)

CreateThread(function()
	while true do
		if limiterEnabled then
			local vehicle = getDriverVehicle()

			if not vehicle then
				disableLimiter()
			elseif IsControlPressed(0, 72) then
				disableLimiter('Cruise control disabled.')
			else
				if activeVehicle and activeVehicle ~= vehicle then
					restoreVehicle(activeVehicle)
				end

				activeVehicle = vehicle

				if not originalMaxSpeeds[vehicle] then
					local estimatedMaxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
					originalMaxSpeeds[vehicle] = estimatedMaxSpeed > 0 and estimatedMaxSpeed or 999.0
				end

				local targetSpeed = toMetersPerSecond(currentLimit)
				local speed = GetEntitySpeed(vehicle)
				SetEntityMaxSpeed(vehicle, targetSpeed)

				if speed < targetSpeed - 0.5 then
					SetControlNormal(0, 71, 1.0)
				end
			end

			Wait(0)
		else
			Wait(500)
		end
	end
end)
