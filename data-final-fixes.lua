---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local ThisMOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function ThisMOD.Start()
    --- Valores de la referencia
    ThisMOD.setSetting()

    --- Crear los prototipos
    ThisMOD.CreateItem()
    ThisMOD.CreateEntity()
    ThisMOD.CreateRecipe()

    --- Estilos a usar
    ThisMOD.Styles()
    ThisMOD.Icon()
end

--- Valores de la referencia
function ThisMOD.setSetting()
    --- Otros valores
    ThisMOD.Prefix = "zzzYAIM0425-0900-"
    ThisMOD.name = "signal-network"

    --- Contenedor
    ThisMOD.Ref = "radar"
    ThisMOD.Technology = "satellite"
    ThisMOD.NewName = ThisMOD.Prefix .. "transceiver"
    ThisMOD.graphics = "__zzzYAIM0425-0900-signals-network__/graphics/"
    ThisMOD.icons = {
        { icon = ThisMOD.graphics .. "item.png" }
    }
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Crear el objeto
function ThisMOD.CreateItem()
    --- Portotipo de referencia
    local Item = GPrefix.items[ThisMOD.Ref]
    Item = util.copy(Item)

    --- Modificar las propiedades
    Item.icons = ThisMOD.icons
    Item.name = ThisMOD.NewName
    Item.place_result = ThisMOD.NewName
    local Order = tonumber(Item.order) + 1
    Item.order = GPrefix.pad_left(#Item.order, Order)
    Item.localised_name = { "", { "entity-name." .. ThisMOD.NewName } }
    Item.localised_description = { "", { "entity-description." .. ThisMOD.NewName } }

    --- Crear el prototipo
    GPrefix.addDataRaw({ Item })
end

--- Crear la receta
function ThisMOD.CreateRecipe()
    --- Portotipo de referencia
    local Recipe = GPrefix.recipes[ThisMOD.Ref][1]
    Recipe = util.copy(Recipe)

    --- Modificar las propiedades
    Recipe.name = ThisMOD.NewName

    Recipe.ingredients = {
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "copper-plate",         amount = 20 },
        { type = "item", name = "steel-plate",          amount = 20 },
        { type = "item", name = "electric-engine-unit", amount = 10 }
    }
    Recipe.results = {
        { type = "item", name = ThisMOD.NewName, amount = 1 }
    }

    --- Crear el prototipo
    GPrefix.addDataRaw({ Recipe })
    GPrefix.addRecipeToTechnology(ThisMOD.Technology, nil, Recipe)
end

--- Crear la entidad
function ThisMOD.CreateEntity()
    --- Portotipo de referencia
    local Entity = GPrefix.entities[ThisMOD.Ref]
    Entity = util.copy(Entity)

    --- Modificar las propiedades
    local Result = GPrefix.get_table(Entity.minable.results, "name", ThisMOD.Ref)
    Result.name = ThisMOD.NewName
    Entity.name = ThisMOD.NewName
    Entity.icons = ThisMOD.icons

    Entity.next_upgrade = nil
    Entity.energy_usage = '2MW'
    Entity.rotation_speed = 0.002
    Entity.connects_to_other_radars = false
    Entity.max_distance_of_sector_revealed = 0
    Entity.max_distance_of_nearby_sector_revealed = 0

    Entity.localised_name = { "", { "entity-name." .. ThisMOD.NewName } }
    Entity.localised_description = { "", { "entity-description." .. ThisMOD.NewName } }

    Entity.pictures = {
        layers = {
            {
                filename = ThisMOD.graphics .. "entity.png",
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
                filename = ThisMOD.graphics .. "entity-shadow.png",
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

---------------------------------------------------------------------------------------------------

--- Estilos a usar
function ThisMOD.Styles()
    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(ThisMOD.Prefix, "%-", "_")

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
function ThisMOD.Icon()
    GPrefix.addDataRaw({ {
        type = "virtual-signal",
        name = ThisMOD.Prefix .. "icon",
        localised_name = "",
        icon = ThisMOD.graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    } })
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
ThisMOD.Start()

---------------------------------------------------------------------------------------------------
