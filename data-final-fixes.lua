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
    This_MOD.create_items()
    This_MOD.create_entities()
    This_MOD.create_recipes()
    This_MOD.create_tech()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Estilos a usar
    This_MOD.styles()
    This_MOD.icon()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores constante
    This_MOD.sender_name = This_MOD.prefix .. "sender"
    This_MOD.receiver_name = This_MOD.prefix .. "receiver"
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"

    --- Objeto de referencia
    This_MOD.ref = {}
    This_MOD.ref.combinator = GPrefix.entities["decider-combinator"]
    This_MOD.ref.item = GPrefix.items["decider-combinator"]
    This_MOD.ref.radar = GPrefix.entities["radar"]

    --- Crear un subgroup
    This_MOD.subgroup = This_MOD.prefix .. GPrefix.delete_prefix(This_MOD.ref.item.subgroup)
    GPrefix.duplicate_subgroup(This_MOD.ref.item.subgroup, This_MOD.subgroup)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear el objeto
function This_MOD.create_items()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = util.copy(This_MOD.ref.item)
    Sender.icons = { { icon = This_MOD.graphics .. "item-sender.png" } }
    Sender.subgroup = This_MOD.subgroup
    Sender.order = "010"

    Sender.name = This_MOD.prefix .. "sender"
    Sender.place_result = This_MOD.prefix .. "sender"

    Sender.localised_name = { "", { "entity-name." .. Sender.name } }
    Sender.localised_description = { "", { "entity-description." .. Sender.name } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = util.copy(This_MOD.ref.item)
    Receiver.icons = { { icon = This_MOD.graphics .. "item-receiver.png" } }
    Receiver.subgroup = This_MOD.subgroup
    Sender.order = "020"

    Receiver.name = This_MOD.prefix .. "receiver"
    Receiver.place_result = This_MOD.prefix .. "receiver"

    Receiver.localised_name = { "", { "entity-name." .. Receiver.name } }
    Receiver.localised_description = { "", { "entity-description." .. Receiver.name } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear los objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.extend(Sender, Receiver)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.create_recipes()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = {}
    Sender.type = "recipe"
    Sender.name = This_MOD.prefix .. "sender"
    Sender.energy_required = 10
    Sender.ingredients = {
        { type = "item", name = "radar",                amount = 1 },
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "battery",              amount = 20 },
        { type = "item", name = "steel-plate",          amount = 10 },
        { type = "item", name = "electric-engine-unit", amount = 10 },
    }
    Sender.results = {
        { type = "item", name = This_MOD.prefix .. "sender", amount = 1 },
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = {}
    Receiver.type = "recipe"
    Receiver.name = This_MOD.prefix .. "receiver"
    Receiver.energy_required = 10
    Receiver.ingredients = {
        { type = "item", name = "radar",                amount = 1 },
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "copper-plate",         amount = 20 },
        { type = "item", name = "steel-plate",          amount = 20 },
        { type = "item", name = "electric-engine-unit", amount = 10 },
    }
    Receiver.results = {
        { type = "item", name = This_MOD.prefix .. "receiver", amount = 1 },
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear los objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.add_recipe_to_tech(This_MOD.prefix .. "transmission", Sender)
    GPrefix.add_recipe_to_tech(This_MOD.prefix .. "transmission", Receiver)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la entidad
function This_MOD.create_entities()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = util.copy(This_MOD.ref.radar)
    Sender.name = This_MOD.prefix .. "sender"
    Sender.icons = { { icon = This_MOD.graphics .. "item-sender.png" } }

    Sender.minable = Sender.minable or { mining_time = 0.1 }
    Sender.minable.results = { { type = "item", name = Sender.name, amount = 1 } }

    Sender.next_upgrade = nil
    Sender.energy_usage = '10MW'
    Sender.rotation_speed = 0.002
    Sender.connects_to_other_radars = false

    Sender.localised_name = { "", { "entity-name." .. Sender.name } }
    Sender.localised_description = { "", { "entity-description." .. Sender.name } }

    Sender.pictures = {
        layers = {
            {
                filename = This_MOD.graphics .. "entity-sender.png",
                shift = util.by_pixel(6, -13),
                animation_speed = 0.18,
                direction_count = 64,
                priority = "high",
                height = 3232 / 8,
                width = 2880 / 8,
                line_length = 8,
                scale = 0.5
            },
            {
                draw_as_shadow = true,
                filename = This_MOD.graphics .. "entity-sender-shadow.png",
                shift = util.by_pixel(33, 10),
                direction_count = 64,
                priority = "high",
                height = 2224 / 8,
                width = 3712 / 8,
                line_length = 8,
                scale = 0.5
            }
        }
    }
    Sender.collision_box = {
        { -2.3, -2.3 },
        { 2.3,  2.3 }
    }
    Sender.selection_box = {
        { -2.5, -2.5 },
        { 2.5,  2.5 }
    }
    Sender.circuit_connector = {
        points = {
            shadow =
            {
                green = { -1.5, 2.2 },
                red = { -1.5, 2.2 },
            },
            wire =
            {
                green = { -2, 1.7 },
                red = { -2, 1.7 },
            }
        }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = util.copy(This_MOD.ref.radar)
    Receiver.name = This_MOD.prefix .. "receiver"
    Receiver.icons = { { icon = This_MOD.graphics .. "item-receiver.png" } }

    Receiver.minable = Receiver.minable or { mining_time = 0.1 }
    Receiver.minable.results = { { type = "item", name = Receiver.name, amount = 1 } }

    Receiver.next_upgrade = nil
    Receiver.energy_usage = '2MW'
    Receiver.rotation_speed = 0.002
    Receiver.connects_to_other_radars = false

    Receiver.localised_name = { "", { "entity-name." .. Receiver.name } }
    Receiver.localised_description = { "", { "entity-description." .. Receiver.name } }

    Receiver.pictures = {
        layers = {
            {
                filename = This_MOD.graphics .. "entity-receiver.png",
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
                filename = This_MOD.graphics .. "entity-receiver-shadow.png",
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
    Receiver.collision_box = {
        { -4.3, -4.3 },
        { 4.3,  4.3 }
    }
    Receiver.selection_box = {
        { -4.5, -4.5 },
        { 4.5,  4.5 }
    }
    Receiver.circuit_connector = {
        points = {
            shadow =
            {
                green = { -2.5, 4.2 },
                red = { -2.7, 4 },
            },
            wire =
            {
                green = { -3.5, 3.2 },
                red = { -3.7, 3 },
            }
        }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Combinador
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Combinator = util.copy(This_MOD.ref.combinator)
    Combinator.name = This_MOD.prefix .. Combinator.name

    Combinator.minable = Combinator.minable or { mining_time = 0.1 }
    Combinator.minable.results = nil

    Combinator.localised_name = ""
    Combinator.localised_description = ""

    Combinator.energy_source = { type = "void" }
    Combinator.hidden = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear los objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.extend(Sender, Receiver, Combinator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crear las tecnologías
function This_MOD.create_tech()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Tecnología base
    local Technology = {
        type = "technology",
        name = This_MOD.prefix .. "transmission",
        effects = {
            { type = "unlock-recipe", recipe = This_MOD.prefix .. "sender", },
            { type = "unlock-recipe", recipe = This_MOD.prefix .. "receiver", },
        },
        icons = { {
            icon = This_MOD.graphics .. "technology.png",
            icon_size = 256
        } },
        order = "e-g",
        prerequisites = {
            "processing-unit",
            "electric-engine",
            "circuit-network",
        },
        unit = {
            count = 100,
            time = 30,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
            }
        }
    }

    --- Corrección
    if mods["space-age"] then
        table.insert(
            Technology.unit.ingredients
            { "space-science-pack", 1 }
        )
    end

    --- Crear la tecnología
    GPrefix.extend(Technology)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Correcciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar los tecnologías de desbloqueo
    local Technologies = {}
    for _, effect in pairs(Technology.effects) do
        local Recipe = data.raw.recipe[effect.recipe]
        for _, ingredient in pairs(Recipe.ingredients or {}) do
            local Tech = { level = 0 }
            for _, recipe in pairs(GPrefix.recipes[ingredient.name] or {}) do
                for _, tech in pairs(GPrefix.tech.recipe[recipe.name] or {}) do
                    if Tech.level < tech.level then
                        Tech = tech
                    end
                end
            end
            if Tech.technology then
                Technologies[Tech.technology.name] = Tech
            end
        end
    end

    --- Cambiar los prerequisitos
    Technology.prerequisites = {}
    for tech, _ in pairs(Technologies) do
        table.insert(Technology.prerequisites, tech)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Estilos a usar
function This_MOD.styles()
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
function This_MOD.icon()
    --- Validación
    local Name = GPrefix.name .. "-icon"
    if data.raw["virtual-signal"][Name] then return end

    --- Crear la señal
    GPrefix.extend({
        type = "virtual-signal",
        name = Name,
        icon = This_MOD.graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
