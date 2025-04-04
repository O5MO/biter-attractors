local attractors = require "attractor-values"
require "scripts.common"
require "scripts.tags"
local meld = require "__core__.lualib.meld"
local util = require "__core__.lualib.util"

-- Dont update all at once, nor in consequent ticks (spikes are probably better than prolonged freezes), but in groups every UPDATE_INTERVAL/UPDATE_GROUPS ticks.
-- Each attractor is updated every UPDATE_INTERVAL ticks
local UPDATE_INTERVAL = 120
local UPDATE_GROUPS = 10

local function init_storage()
    storage.map_tags = storage.map_tags or {}
    storage.show_attractor_range = storage.show_attractor_range or {}
    storage.attractors = storage.attractors or {}
    storage.active_group = storage.active_group or 0
    storage.ghost_attractors = storage.ghost_attractors or {}
end
script.on_init(function (event)
    init_storage()
end)
script.on_configuration_changed(function (event)
    init_storage()
end)

---@param command Command
---@return boolean
local function is_command_valid(command)
    local type = command.type
    if type == defines.command.attack then
        if not command.target then return false end
    elseif type == defines.command.attack_area then
        if not command.destination then return false end
    elseif type == defines.command.flee then
        if not command.from then return false end
    elseif type == defines.command.group then
        if not command.group then return false end
    elseif type == defines.command.build_base then
        if not command.destination then return false end
    elseif type == defines.command.compound then
        for _, command2 in pairs(command.commands) do
            if not is_command_valid(command2) then return false end
        end
    end
    return true
end

script.on_nth_tick(UPDATE_INTERVAL/UPDATE_GROUPS, function(event)
    if remote.interfaces["profiler"] then
        remote.call("profiler", "dump")
    end
    local i = 0
    for _, force in pairs(game.forces) do
        local entites = get_all_attractors(force.index)
        for _, entity in pairs(entites) do
            i = i + 1
            if (not entity.valid) or (not entity.active) or (entity.status ~= defines.entity_status.working) then goto next_attractor end
            if i % UPDATE_GROUPS ~= storage.active_group then goto next_attractor end
            local surface = entity.surface
            local units = surface.find_entities_filtered{
                position = entity.position,
                radius = attractors[entity.name].radius,
                type = {"unit","spider-unit"},
                force = "enemy",
                is_military_target = true,
            }
            -- High performance code ahead. Any modification must be measured
            local cached_group
            for _, unit in pairs(units) do
                if not unit.valid then goto continue end
                local commandable = unit.commandable
                if --[[not commandable or]] not commandable.valid then goto continue end
                -- if commandable.parent_group then goto continue end
                local pg = commandable.parent_group
                if pg then 
                    -- Checking group is faster than checking if target is attractor, even if redundant
                    if cached_group == pg then goto continue end
                    commandable = pg
                end
                local command = commandable.command
                cached_group = pg
                if command and command.target and command.target.valid and attractors[command.target.name] then goto continue end
                local old_distraction = commandable.distraction_command
                -- game.print("Redirecting commandable "..serpent.line(commandable))
                commandable.set_command{
                    type = defines.command.attack,
                    target = entity,
                    pathfind_flags = {
                        -- prefer straight paths?
                    },
                }
                if old_distraction then
                    if is_command_valid(old_distraction) then
                        commandable.set_distraction_command(old_distraction)
                    end
                end
                ::continue::
            end
            -- End of high performance code

            ::next_attractor::
        end
    end
    storage.active_group = (storage.active_group + 1) % UPDATE_GROUPS
end)

script.on_event(defines.events.on_script_trigger_effect, function (event)
    local entity = event.cause_entity
    if not entity or not is_attractor(entity.name) then return end
    -- Texture extends too much past the bounds to render properly. LuaRendering sprite fixes that.
    -- TODO: add more sprites with higher render layers
    rendering.draw_sprite{
        sprite = "biter-attractor-1-sprite",
        x_scale = 1,
        y_scale = 1,
        render_layer = "elevated-higher-object",
        target = entity,
        surface = entity.surface,
    }
    add_attractor(entity)
end)

script.on_event(defines.events.on_object_destroyed, function (event)
    if not event.type == defines.target_type.entity then return end
    for _, force in pairs(game.forces) do
        local force_index = force.index
        storage.attractors[force_index] = storage.attractors[force_index] or {}
        if storage.attractors[force_index][event.useful_id] then
            table.remove(storage.attractors[force_index], event.useful_id)
        end
        storage.ghost_attractors[force_index] = storage.ghost_attractors[force_index] or {}
        if storage.ghost_attractors[force_index][event.useful_id] then
            table.remove(storage.ghost_attractors[force_index], event.useful_id)
        end
    end
end)

-- This could be used to reduce performance impact of iterating through units, however find_entites_filtered would still be a concern
script.on_event(defines.events.on_unit_group_created, function (event)
    -- game.print(serpent.dump(event.group))
end)