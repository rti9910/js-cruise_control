-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            Config                                │
-- └──────────────────────────────────────────────────────────────────┘


Config = {}

-- Speed values use the unit selected below.
Config.SpeedUnit = 'kmh' -- 'kmh' or 'mph'
Config.DefaultLimit = 100
Config.MinimumLimit = 10
Config.MaximumLimit = 300
Config.SpeedStep = 5

-- Chat commands
Config.Command = 'speedlimit'
Config.ClearCommand = 'speedlimitoff'

-- Default keyboard mappings
Config.EnableKeyMapping = true
Config.ToggleKey = 'PERIOD'
Config.SpeedUpKey = 'UP'
Config.SpeedDownKey = 'DOWN'

Config.RequireDriverSeat = true
Config.AllowInEmergencyVehicles = true
Config.ShowNotifications = true

-- Notification provider: 'auto', 'native', 'esx', 'qbcore', 'ox_lib', 'okokNotify', or 'custom'.
Config.NotifyProvider = 'auto'
Config.CustomNotificationEvent = 'my_notify:client:notify'
Config.NotificationTitle = 'Cruise Control'
Config.NotificationDuration = 5000