local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor

return function(monitor)
    return Widget.Window({
        monitor = monitor,
        anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
        exclusivity = "EXCLUSIVE",
        Widget.Label({
            label = "Example label content",
        }),
    })
end
