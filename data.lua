local util = require "__core__.lualib.util"
local attractors = require "attractor-values"
require "prototypes.tags"

make_range_icons("biter-attractor-1")
data:extend{
    {
        type = "shortcut",
        name = "ba-show-attractor-range",
        action = "lua",
        order = "r",
        icon = "__biter-attractor-graphics__/graphics/range-shortcut.png",
        icon_size = 56,
        small_icon = "__biter-attractor-graphics__/graphics/range-shortcut.png",
        small_icon_size = 56,
        toggleable = true,
    },
    {
        type = "trivial-smoke",
        name = "ba-heavy-smoke",
        color = util.premul_color{1,1,1, 0.25},

        start_scale = 0.25,
        end_scale = 1.0,
        spread_duration = 300,
        
        duration = 600,
        fade_away_duration = 90,
        fade_in_duration = 60,
        animation = {
            filename = "__base__/graphics/entity/fire-smoke/fire-smoke.png",
            flags = { "smoke" },
            line_length = 8,
            width = 253,
            height = 210,
            frame_count = 60,
            shift = {-0.265625, -0.09375},
            priority = "high",
            animation_speed = 0.1,
        }
    },
    {
        type = "trivial-smoke",
        name = "ba-heavy-smoke-small",
        color = util.premul_color{1,1,1, 0.5},

        start_scale = 0.1,
        end_scale = 0.25,
        spread_duration = 60,
        
        duration = 180,
        fade_away_duration = 60,
        fade_in_duration = 0,
        animation = {
            filename = "__base__/graphics/entity/fire-smoke/fire-smoke.png",
            flags = { "smoke" },
            line_length = 8,
            width = 253,
            height = 210,
            frame_count = 60,
            shift = {-0.265625, -0.09375},
            priority = "high",
            animation_speed = 0.05,
        }
    },
    {
        type = "technology",
        name = "biter-attractor-1",
        icon = "__biter-attractor-graphics__/graphics/tower-tech-1-biter.png",
        icon_size = 256,
        unit = {
            count = 100,
            time = 30,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
            },
        },
        prerequisites = {
            "military-science-pack",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "biter-attractor-1",
            },
        }
    },
    {
        type = "item",
        name = "biter-attractor-1",
        icon = "__biter-attractor-graphics__/graphics/tower-1-icon-mip.png",
        icon_size = 64,
        stack_size = 10,
        place_result = "biter-attractor-1",
        subgroup = "defensive-structure",
        order = "g[biter-attractor-1]",
    },
    {
        type = "recipe",
        name = "biter-attractor-1",
        enabled = false,
        icon = "__biter-attractor-graphics__/graphics/tower-1-icon-mip.png",
        icon_size = 64,
        order = "g[biter-attractor-1]",
        energy_required = 8,
        ingredients = {
            {type = "item", name = "steel-plate", amount = 100},
            {type = "item", name = "iron-stick", amount = 200},
            {type = "item", name = "pipe", amount = 50},
            {type = "item", name = "stone-brick", amount = 50},
        },
        results = {
            {type = "item", name = "biter-attractor-1", amount = 1},
        }
    },
    {
        type = "radar",
        name = "biter-attractor-1",
        localised_description = {"", {"entity-description.biter-attractor-1"}, "\n", {"property-name.attraction-radius", tostring(attractors["biter-attractor-1"].radius)}},
        icon = "__biter-attractor-graphics__/graphics/tower-1-icon-mip.png",
        icon_size = 64,
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        collision_mask = {layers={item=true, meltable=true, object=true, player=true, water_tile=true, is_object=true, is_lower_object=true, elevated_rail=true}},
        flags = {"player-creation"}, -- get by unit number?
        placeable_by = {item = "biter-attractor-1", count = 1},
        minable = {
            mining_time = 1,
            result = "biter-attractor-1",
            count = 1,
        },
        max_health = 1000,
        pictures = {
            layers = {
                {
                    direction_count = 1,
                    filename = "__biter-attractor-graphics__/graphics/tower-1.png",
                    size = {192, 1112},
                    shift = {0, -7},
                    scale = 0.5,
                },
                {
                    draw_as_shadow = true,
                    direction_count = 1,
                    filename = "__biter-attractor-graphics__/graphics/tower-1s.png",
                    size = {1440, 192},
                    shift = util.by_pixel_hr(600, 20),
                    scale = 0.5,
                },
            }
        },
        drawing_box_vertical_extension = 14,
        energy_source = {
            type = "burner",
            fuel_inventory_size = 2,
            emissions_per_minute = {["pollution"] = 300},
            smoke = {
                {
                    name = "ba-heavy-smoke-small",
                    position = {0.0, -15.2},
                    deviation = {0, 0},
                    frequency = 10
                },
                {
                    name = "ba-heavy-smoke",
                    position = {0.0, -15.5},
                    deviation = {0.1, 0.1},
                    frequency = 5
                },
            },
        },

        created_effect = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type  = "script",
                    effect_id = "biter-attractor-1",
                    show_in_tooltip = false,
                }
            }
        },

        energy_usage = "5MW",
        energy_per_sector = "5MW",
        energy_per_nearby_scan = "500kW",
        max_distance_of_sector_revealed = 5,
        max_distance_of_nearby_sector_revealed = 5,

        connects_to_other_radars = false,
    },
    {
        type = "sprite",
        name = "biter-attractor-1-sprite",
        layers = {
            {
                filename = "__biter-attractor-graphics__/graphics/tower-1.png",
                -- Dont render the bottom N tiles with LuaRendering as it draws on top of other objects.
                -- Could be adjusted up to the bottom 9 (3 building size + 6 margin) tiles if needed
                size = {192, 1112 - 64*5},
                shift = {0, -9.5},
                scale = 0.5,
            },
            {
                draw_as_shadow = true,
                filename = "__biter-attractor-graphics__/graphics/tower-1s.png",
                size = {1440, 192},
                shift = util.by_pixel_hr(600, 20),
                scale = 0.5,
            },
        }
    }
}