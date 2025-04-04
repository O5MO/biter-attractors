local attractors = require "attractor-values"

local ENABLED_COLOR = {0,1,1}
local DISABLED_COLOR = {1,0.9,0}
local GHOST_COLOR = {0.6,0.6,0.6}

function make_range_icons(name)
    local radius = attractors[name].radius
    data:extend{
        {
            type = "virtual-signal",
            name = name.."-range-enabled",
            localised_name = "virtual-signal-name.attractor-range-visualisation",
            icons = {
                {
                    icon = "__biter-attractors__/graphics/circle.png",
                    icon_size = 1024,
                    scale = radius/16 * 64/1024,
                    draw_background = false,
                    tint = ENABLED_COLOR,
                }
            },
            hidden = true,
        },
        {
            type = "virtual-signal",
            name = name.."-range-disabled",
            localised_name = "virtual-signal-name.attractor-range-visualisation",
            icons = {
                {
                    icon = "__biter-attractors__/graphics/circle.png",
                    icon_size = 1024,
                    scale = radius/16 * 64/1024,
                    draw_background = false,
                    tint = DISABLED_COLOR,
                }
            },
            hidden = true,
        },
        {
            type = "virtual-signal",
            name = name.."-range-ghost",
            localised_name = "virtual-signal-name.attractor-range-visualisation",
            icons = {
                {
                    icon = "__biter-attractors__/graphics/circle.png",
                    icon_size = 1024,
                    scale = radius/16 * 64/1024,
                    draw_background = false,
                    tint = GHOST_COLOR,
                }
            },
            hidden = true,
        },
    }
end