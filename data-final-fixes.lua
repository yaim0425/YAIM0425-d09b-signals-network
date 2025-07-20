---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear los prototipos
    This_MOD.create_item()
    -- This_MOD.CreateEntity()
    -- This_MOD.CreateRecipe()
    -- This_MOD.create_tech()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Estilos a usar
    -- This_MOD.Styles()
    -- This_MOD.Icon()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor
    This_MOD.entity_ref = "radar"
    This_MOD.sender_name = This_MOD.prefix .. "sender"
    This_MOD.receiver_name = This_MOD.prefix .. "receiver"
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear el objeto
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Emisor
    local Sender = util.copy(GPrefix.items["arithmetic-combinator"])
    Sender.icons = { { icon = "__" .. "__/graphics/item-sender.png" } }
    Sender.place_result = This_MOD.prefix .. "sender"
    Sender.place_result = nil

    --- Receptor
    local Receiver = util.copy(GPrefix.items["arithmetic-combinator"])
    Receiver.icons = { { icon = "__" .. "__/graphics/item-receiver.png" } }
    Receiver.place_result = This_MOD.prefix .. "receiver"
    Receiver.place_result = nil

    --- Crear los objetos
    GPrefix.extend(Sender, Receiver)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.CreateRecipe()
    --- Portotipo de referencia
    local Recipe = GPrefix.recipes[This_MOD.ref][1]
    Recipe = util.copy(Recipe)

    --- Modificar las propiedades
    Recipe.name = This_MOD.receiver

    Recipe.ingredients = {
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "copper-plate",         amount = 20 },
        { type = "item", name = "steel-plate",          amount = 20 },
        { type = "item", name = "electric-engine-unit", amount = 10 }
    }
    Recipe.results = {
        { type = "item", name = This_MOD.receiver, amount = 1 }
    }

    --- Crear el prototipo
    GPrefix.addDataRaw({ Recipe })
    GPrefix.addRecipeToTechnology(This_MOD.tech, nil, Recipe)
end

--- Crear la entidad
function This_MOD.CreateEntity()
    --- Portotipo de referencia
    local Entity = GPrefix.entities[This_MOD.ref]
    Entity = util.copy(Entity)

    --- Modificar las propiedades
    local Result = GPrefix.get_table(Entity.minable.results, "name", This_MOD.ref)
    Result.name = This_MOD.receiver
    Entity.name = This_MOD.receiver
    Entity.icons = This_MOD.icons

    Entity.next_upgrade = nil
    Entity.energy_usage = '2MW'
    Entity.rotation_speed = 0.002
    Entity.connects_to_other_radars = false
    Entity.max_distance_of_sector_revealed = 0
    Entity.max_distance_of_nearby_sector_revealed = 0

    Entity.localised_name = { "", { "entity-name." .. This_MOD.receiver } }
    Entity.localised_description = { "", { "entity-description." .. This_MOD.receiver } }

    Entity.pictures = {
        layers = {
            {
                filename = This_MOD.graphics .. "entity.png",
                shift = util.by_pixel(1, -26),
                animation_speed = 0.15,
                direction_count = 64,
                priority = "high",
                height = 5440 / 8,
                width = 4688 / 8,
                line_length = 8,
                scale = 0.5
            },
            {
                draw_as_shadow = true,
                filename = This_MOD.graphics .. "entity-shadow.png",
                shift = util.by_pixel(25, 19),
                direction_count = 64,
                priority = "high",
                height = 4800 / 8,
                width = 5440 / 8,
                line_length = 8,
                scale = 0.5
            }
        }
    }
    Entity.collision_box = {
        { -4.3, -4.3 },
        { 4.3,  4.3 }
    }
    Entity.selection_box = {
        { -4.5, -4.5 },
        { 4.5,  4.5 }
    }
    Entity.circuit_connector = {
        points = {
            shadow = {
                green = { -2.5, 4.2 },
                red = { -2.7, 4 },
            },
            wire = {
                green = { -3.5, 3.2 },
                red = { -3.7, 3 },
            }
        }
    }

    --- Crear el prototipo
    GPrefix.addDataRaw({ Entity })
end

---------------------------------------------------------------------------------------------------

--- Crear las tecnologías
function This_MOD.create_tech()
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Estilos a usar
function This_MOD.Styles()
    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.Prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Multiuso
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    Styles[Prefix .. "flow_vertival_8"] = {
        type = "vertical_flow_style",
        vertical_spacing = 8
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cabeza
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    Styles[Prefix .. "flow_head"] = {
        type = "horizontal_flow_style",
        horizontal_spacing = 8,
        bottom_padding = 7
    }
    Styles[Prefix .. "label_title"] = {
        type = "label_style",
        parent = "frame_title",
        button_padding = 3,
        top_margin = -3
    }
    Styles[Prefix .. "empty_widget"] = {
        type = "empty_widget_style",
        parent = "draggable_space",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        height = 24
    }
    Styles[Prefix .. "button_close"] = {
        type = "button_style",
        parent = "close_button",
        padding = 2,
        margin = 0,
        size = 24
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cuerpo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    Styles[Prefix .. "frame_entity"] = {
        type = "frame_style",
        parent = "entity_frame",
        padding = 0
    }
    Styles[Prefix .. "frame_body"] = {
        type = "frame_style",
        parent = "entity_frame",
        padding = 4
    }
    Styles[Prefix .. "drop_down_channels"] = {
        type = "dropdown_style",
        width = 250 + 32
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    Styles[Prefix .. "button_red"] = {
        type = "button_style",
        parent = "tool_button_red",
        padding = 0,
        margin = 0,
        size = 28
    }
    Styles[Prefix .. "button_green"] = {
        type = "button_style",
        parent = "tool_button_green",
        padding = 0,
        margin = 0,
        size = 28
    }
    Styles[Prefix .. "button_blue"] = {
        type = "button_style",
        parent = "tool_button_blue",
        padding = 0,
        margin = 0,
        size = 28
    }
    Styles[Prefix .. "button"] = {
        type = "button_style",
        parent = "button",
        top_margin = 1,
        padding = 0,
        size = 28
    }
    Styles[Prefix .. "stretchable_textfield"] = {
        type = "textbox_style",
        width = 250
    }
end

--- Icono para las imagenes
function This_MOD.Icon()
    GPrefix.addDataRaw({ {
        type = "virtual-signal",
        name = This_MOD.Prefix .. "icon",
        localised_name = "",
        icon = This_MOD.graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    } })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
