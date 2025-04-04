---@enum tag_type
local tag_type = {
    enabled = "enabled",
    disabled = "disabled",
    ghost = "ghost",
}

local function remove_all_tags()
    for _, tag in pairs(storage.map_tags) do
        tag.destroy()
    end
    storage.map_tags = {}
end

local function add_tag(name, force, surface, position, type)
    table.insert(storage.map_tags, force.add_chart_tag(surface, {position = position, icon = {type = "virtual", name = name.."-range-"..type}}))
end

-- Update map tags
-- TODO: use selected event?
script.on_nth_tick(5, function (event)
    remove_all_tags()
    for _, player in pairs(game.players) do
        local should_display_range = false
        local selected = player.selected
        if selected and selected.valid and is_attractor(selected.name) then
            should_display_range = true
        end
        local cursor_stack = player.cursor_stack
        local cursor_ghost = player.cursor_ghost
        local name = nil
        if cursor_stack and cursor_stack.valid_for_read then
            name = cursor_stack.name
        elseif cursor_ghost then
            name = cursor_ghost.name.name
        end
        if is_attractor(name) then
            should_display_range = true
            local cursor_position = get_cursor_position(player)
            add_tag(name, player.force, player.surface, cursor_position, tag_type.enabled)
        end
        if storage.show_attractor_range[player.index] then
            should_display_range = true
        end
        
        if should_display_range then
            local force = player.force
            for _, entity in pairs(get_all_attractors(force.index)) do
                if entity and entity.valid then
                    add_tag(entity.name, force, entity.surface, entity.position, entity.status == defines.entity_status.working and tag_type.enabled or tag_type.disabled)
                end
            end
            for _, entity in pairs(get_ghost_attractors(force.index)) do
                if entity and entity.valid then
                    add_tag(entity.ghost_name, force, entity.surface, entity.position, tag_type.ghost)
                end
            end
        end
    end
end)

script.on_event(defines.events.on_lua_shortcut, function (event)
    if not event.prototype_name == "ba-show-attractor-range" then return end
    local player = game.players[event.player_index]
    player.set_shortcut_toggled("ba-show-attractor-range", not storage.show_attractor_range[event.player_index])
    storage.show_attractor_range[event.player_index] = not storage.show_attractor_range[event.player_index]
end)

-- Detect ghosts to enable range visualizations of ghosts
script.on_event(defines.events.on_built_entity, function (event)
    local entity = event.entity
    if entity.type ~= "entity-ghost" then return end
    if not is_attractor(entity.ghost_name) then return end
    add_ghost_attractor(entity)
end)
script.on_event(defines.events.script_raised_built, function (event)
    local entity = event.entity
    if entity.type ~= "entity-ghost" then return end
    if not is_attractor(entity.ghost_name) then return end
    add_ghost_attractor(entity)
end)
script.on_event(defines.events.script_raised_revive, function (event)
    local entity = event.entity
    if entity.type ~= "entity-ghost" then return end
    if not is_attractor(entity.ghost_name) then return end
    add_ghost_attractor(entity)
end)