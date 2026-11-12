# JS Tempomat

A lightweight FiveM vehicle speed limiter / cruise-control style script for GTA V servers. It lets players set a maximum speed for their vehicle, enable or disable the limiter, and adjust the limit while driving.

## Features

- Hold the current speed or set a custom cruising speed
- Enable / disable the limiter on demand
- Increase or decrease the limit in steps
- Support for km/h and mph
- Optional keyboard bindings
- Works on ESX, QBCore, and standalone servers without framework dependencies
- Works in vehicles except planes and helicopters
- Disables cruise control when the driver brakes
- Prevents limiting in emergency vehicles if disabled in config
- In-game notifications for status and usage

## Commands

By default, the script includes these commands:

- `/speedlimit <speed>` - Set and enable the cruising speed
- `/speedlimitoff` - Disable the limiter
- `/speedlimiter_toggle` - Toggle limiter on/off
- `/speedlimiter_increase` - Increase the speed limit by the configured step
- `/speedlimiter_decrease` - Decrease the speed limit by the configured step

## Default Key Bindings

If `Config.EnableKeyMapping` is enabled, the script maps:

- `.` - Toggle speed limiter
- `Up Arrow` - Increase limit
- `Down Arrow` - Decrease limit

## Installation

1. Download or copy the folder into your FiveM server resources directory.
2. Rename the folder if desired, for example:
   `js-tempomat`
3. Add it to your `server.cfg`:

```cfg
ensure js-tempomat
```

4. Start or restart your FiveM server.

## Configuration

Edit `config.lua` to customize behavior:

```lua
Config = {}

Config.SpeedUnit = 'kmh' -- 'kmh' or 'mph'
Config.DefaultLimit = 100
Config.MinimumLimit = 10
Config.MaximumLimit = 300
Config.SpeedStep = 5

Config.Command = 'speedlimit'
Config.ClearCommand = 'speedlimitoff'

Config.EnableKeyMapping = true
Config.ToggleKey = 'PERIOD'
Config.SpeedUpKey = 'UP'
Config.SpeedDownKey = 'DOWN'

Config.RequireDriverSeat = true
Config.AllowInEmergencyVehicles = true
Config.ShowNotifications = true
Config.NotifyProvider = 'auto' -- 'auto', 'native', 'esx', 'qbcore', 'ox_lib', 'okokNotify', or 'custom'
Config.CustomNotificationEvent = 'my_notify:client:notify'
Config.NotificationTitle = 'Cruise Control'
Config.NotificationDuration = 5000
```

### Options

- `SpeedUnit`: Sets the unit used in messages and speed calculations.
- `DefaultLimit`: The starting limit when the script is first used.
- `MinimumLimit` / `MaximumLimit`: Safety bounds for the limiter.
- `SpeedStep`: Amount increased/decreased per command or key press.
- `Command` / `ClearCommand`: Chat command names.
- `EnableKeyMapping`: Enables default keyboard mappings.
- `RequireDriverSeat`: Limits functionality to the driver seat only.
- `AllowInEmergencyVehicles`: Allows or blocks emergency vehicles.
- `ShowNotifications`: Enables or disables in-game feed notifications.
- `NotifyProvider`: Selects a notification integration. `auto` prefers ox_lib, then ESX, QBCore, okokNotify, and native GTA notifications.
- `CustomNotificationEvent`: Event triggered with `(message, type)` when `NotifyProvider` is `custom`.
- `NotificationTitle` / `NotificationDuration`: Title and duration used by integrations that support them.

Speed adjustment keys do nothing unless you are in a supported vehicle, and notifications are suppressed outside supported vehicles.

## How It Works

Toggling cruise control captures your current speed and maintains it. `/speedlimit <speed>` sets a specific target instead. The script maintains the target while you drive and disables cruise control when you brake, leave the vehicle, or enter a plane or helicopter. It temporarily adjusts the vehicle's maximum speed and restores the original value when cruise control is disabled.

## Notes

- This script is client-side and designed to be light and simple.
- It is best suited for roleplay or driving-focused servers where a speed cap is desired.
- If you want a more advanced version with police exemptions, vehicle classes, or persistent server-side settings, it can be expanded further.

## Credits

Developed for FiveM by [text](https://github.com/rti9910).

## License

This project is provided as-is for use in your FiveM server. If you are distributing it publicly, please credit the original author.
