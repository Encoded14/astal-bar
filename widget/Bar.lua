local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Variable = astal.Variable
local bind = astal.bind
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Battery = astal.require("AstalBattery")

local battery_window = nil

local function BatteryLevel(monitor)
	local bat = Battery.get_default()
	local window_visible = Variable(false)
	local battery_state = Variable.derive({ bind(bat, "is-present") }, function(present)
		return present
	end)

	local function toggle_battery_window()
		if window_visible:get() and battery_window then
			battery_window:hide()
			window_visible:set(false)
		else
			if not battery_window then
				local BatteryWindow = require("lua.windows.Battery")
				battery_window = BatteryWindow.new(monitor)
			end
			if battery_window then
				battery_window:show_all()
			end
			window_visible:set(true)
		end
	end

	return Widget.Button({
		class_name = "battery-button",
		visible = bind(battery_state),
		on_clicked = toggle_battery_window,
		Widget.Box({
			Widget.Icon({
				icon = bind(bat, "battery-icon-name"),
				css = "padding-right: 5pt;",
			}),
			Widget.Label({
				label = bind(bat, "percentage"):as(function(p)
					return tostring(math.floor(p * 100)) .. " %"
				end),
			}),
		}),
		setup = function(self)
			self:hook(self, "destroy", function()
				window_visible:drop()
				battery_state:drop()
			end)
		end,
	})
end

return function(gdkmonitor)
	if not gdkmonitor then
		print("Bar: No monitor available")
        return nil
    end 

	local Anchor = astal.require("Astal").WindowAnchor

    return Widget.Window({
        class_name = "Bar",
        anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
        exclusivity = "EXCLUSIVE",
        Widget.CenterBox({
			Widget.Box({
				halign = "START",
			}),
			Widget.Box({
			}),
			Widget.Box({
				halign = "END",
                BatteryLevel(gdkmonitor),
			}),
		}),
    })
end
