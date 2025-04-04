local attractors = require "attractor-values"
-- Returns whether the entity is an attractor
function is_attractor(name)
    if attractors[name] then
        return true
    end
end

---@param entity LuaEntity
function add_attractor(entity)
    local force_index = entity.force_index
    storage.attractors[force_index] = storage.attractors[force_index] or {}
    storage.attractors[force_index][entity.unit_number] = entity
    script.register_on_object_destroyed(entity)
end

---@param entity LuaEntity
function add_ghost_attractor(entity)
    local force_index = entity.force_index
    storage.ghost_attractors[force_index] = storage.ghost_attractors[force_index] or {}
    storage.ghost_attractors[force_index][entity.unit_number] = entity
    script.register_on_object_destroyed(entity)
end

---@param force_index integer
function get_all_attractors(force_index)
    return storage.attractors[force_index] or {}
end

---@param force_index integer
function get_ghost_attractors(force_index)
    return storage.ghost_attractors[force_index] or {}
end