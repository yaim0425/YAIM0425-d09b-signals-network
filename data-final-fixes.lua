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
    This_MOD.load_styles()
    This_MOD.load_icon()
    This_MOD.load_sound()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores constante
    This_MOD.tech_name = This_MOD.prefix .. "transmission"
    This_MOD.sender_name = This_MOD.prefix .. "sender"
    This_MOD.receiver_name = This_MOD.prefix .. "receiver"
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.sound = "__" .. This_MOD.prefix .. This_MOD.name .. "__/sound/"

    --- Valores de referencia
    This_MOD.ref = {}
    This_MOD.ref.combinator = GPrefix.entities["decider-combinator"]
    This_MOD.ref.item = GPrefix.items["decider-combinator"]
    This_MOD.ref.entity = GPrefix.entities["radar"]

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

    Sender.name = This_MOD.sender_name
    Sender.place_result = This_MOD.sender_name

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

    Receiver.name = This_MOD.receiver_name
    Receiver.place_result = This_MOD.receiver_name

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
    Sender.name = This_MOD.sender_name
    Sender.energy_required = 10
    Sender.ingredients = {
        { type = "item", name = "radar",                amount = 1 },
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "battery",              amount = 20 },
        { type = "item", name = "steel-plate",          amount = 10 },
        { type = "item", name = "electric-engine-unit", amount = 10 },
    }
    Sender.results = { {
        type = "item",
        name = This_MOD.sender_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = {}
    Receiver.type = "recipe"
    Receiver.name = This_MOD.receiver_name
    Receiver.energy_required = 10
    Receiver.ingredients = {
        { type = "item", name = "radar",                amount = 1 },
        { type = "item", name = "processing-unit",      amount = 20 },
        { type = "item", name = "copper-plate",         amount = 20 },
        { type = "item", name = "steel-plate",          amount = 20 },
        { type = "item", name = "electric-engine-unit", amount = 10 },
    }
    Receiver.results = { {
        type = "item",
        name = This_MOD.receiver_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.extend(Sender, Receiver)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la entidad
function This_MOD.create_entities()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = {
        type = "roboport",
        name = This_MOD.sender_name,

        localised_name = { "", { "entity-name." .. This_MOD.sender_name } },
        localised_description = { "", { "entity-description." .. This_MOD.sender_name } },

        icons = { { icon = This_MOD.graphics .. "item-sender.png" } },

        collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
        selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
        drawing_box = { { -2.5, -2.9 }, { 2.5, 2.5 } },

        max_health = 400,

        energy_usage = "10MW",
        recharge_minimum = "5MJ",
        charging_energy = "5MW",

        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            input_flow_limit = "1GW",
            buffer_capacity = "5MJ"
        },

        base_animation = {
            layers = {
                {
                    filename = This_MOD.graphics .. "entity-sender.png",
                    shift = util.by_pixel(6, -13),
                    animation_speed = 0.18,
                    frame_count = 64,
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
                    frame_count = 64,
                    priority = "high",
                    height = 2224 / 8,
                    width = 3712 / 8,
                    line_length = 8,
                    scale = 0.5
                }
            }
        },

        circuit_connector = {
            points = {
                shadow = {
                    green = { -1.5, 2.2 },
                    red = { -1.5, 2.2 }
                },
                wire = {
                    green = { -2, 1.7 },
                    red = { -2, 1.7 }
                }
            }
        },

        minable = {
            mining_time = 0.2,
            results = { {
                type = "item",
                name = This_MOD.sender_name,
                amount = 1
            } }
        },

        --- --- --- --- --- --- --- --- --- --- --- --- ---

        dying_explosion = "medium-explosion",
        corpse = "big-remnants",
        flags = { "placeable-player", "player-creation" },

        logistics_radius = 0,
        robot_slots_count = 0,
        construction_radius = 0,
        material_slots_count = 0,
        charge_approach_distance = 0,

        draw_logistic_radius_visualization = false,
        draw_construction_radius_visualization = false,

        radar_range = 1,
        request_to_open_door_timeout = 15,
        spawn_and_station_height = -0.1,
        circuit_wire_max_distance = 10,

        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },

        working_sound = {
            sound = {
                filename = "__base__/sound/roboport-working.ogg",
                volume = 0.6
            },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.5,
            probability = 1 / (15 * 60)
        },

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = {
        type = "roboport",
        name = This_MOD.receiver_name,

        localised_name = { "", { "entity-name." .. This_MOD.receiver_name } },
        localised_description = { "", { "entity-description." .. This_MOD.receiver_name } },

        icons = { { icon = This_MOD.graphics .. "item-receiver.png" } },

        collision_box = { { -4.3, -4.3 }, { 4.3, 4.3 } },
        selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
        drawing_box = { { -4.5, -4.9 }, { 4.5, 4.5 } },

        max_health = 800,

        energy_usage = "2MW",
        recharge_minimum = "1MJ",
        charging_energy = "1MW",

        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            input_flow_limit = "1GW",
            buffer_capacity = "1MJ"
        },

        base_animation = {
            layers = {
                {
                    filename = This_MOD.graphics .. "entity-receiver.png",
                    shift = util.by_pixel(1, -26),
                    animation_speed = 0.15,
                    frame_count = 64,
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
                    frame_count = 64,
                    priority = "high",
                    height = 4800 / 8,
                    width = 5440 / 8,
                    line_length = 8,
                    scale = 0.5
                }
            }
        },

        circuit_connector = {
            points = {
                shadow = {
                    green = { -2.5, 4.2 },
                    red = { -2.7, 4 }
                },
                wire = {
                    green = { -3.5, 3.2 },
                    red = { -3.7, 3 }
                }
            }
        },

        minable = {
            mining_time = 0.5,
            results = { {
                type = "item",
                name = This_MOD.receiver_name,
                amount = 1
            } }
        },

        --- --- --- --- --- --- --- --- --- --- --- --- ---

        dying_explosion = "medium-explosion",
        corpse = "big-remnants",
        flags = { "placeable-player", "player-creation" },

        logistics_radius = 0,
        robot_slots_count = 0,
        construction_radius = 0,
        material_slots_count = 0,
        charge_approach_distance = 0,

        draw_logistic_radius_visualization = false,
        draw_construction_radius_visualization = false,

        radar_range = 1,
        request_to_open_door_timeout = 15,
        spawn_and_station_height = -0.1,
        circuit_wire_max_distance = 10,

        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        working_sound = {
            sound = {
                filename = "__base__/sound/roboport-working.ogg",
                volume = 0.6
            },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.5,
            probability = 1 / (15 * 60)
        },

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Combinador
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Direction = {
        north = util.empty_sprite(),
        east = util.empty_sprite(),
        south = util.empty_sprite(),
        west = util.empty_sprite()
    }

    local Connection_points = {
        {
            shadow = { red = { 0, 0 }, green = { 0, 0 } },
            wire = { red = { 0, 0 }, green = { 0, 0 } }
        },
        {
            shadow = { red = { 0, 0 }, green = { 0, 0 } },
            wire = { red = { 0, 0 }, green = { 0, 0 } }
        },
        {
            shadow = { red = { 0, 0 }, green = { 0, 0 } },
            wire = { red = { 0, 0 }, green = { 0, 0 } }
        },
        {
            shadow = { red = { 0, 0 }, green = { 0, 0 } },
            wire = { red = { 0, 0 }, green = { 0, 0 } }
        }
    }

    local Light_offsets = {
        { 0, 0 },
        { 0, 0 },
        { 0, 0 },
        { 0, 0 }
    }

    local Combinator = {
        type = "decider-combinator",
        name = This_MOD.prefix .. This_MOD.ref.combinator.name,

        localised_name = "",
        localised_description = "",

        icons = { { icon = "__base__/graphics/icons/decider-combinator.png" } },

        collision_box = { { 0, 0 }, { 0, 0 } },
        selection_box = { { 0, 0 }, { 0, 0 } },

        max_health = 1,

        energy_source = { type = "void" },
        active_energy_usage = "1W",

        circuit_wire_max_distance = 9,
        selectable_in_game = false,
        hidden = true,
        flags = { "not-on-map" },

        sprites = Direction,
        activity_led_sprites = Direction,
        activity_led_light = { intensity = 0, size = 0 },
        screen_light_offsets = Light_offsets,
        activity_led_light_offsets = Light_offsets,

        input_connection_bounding_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        output_connection_bounding_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },

        circuit_wire_connection_points = Connection_points,
        output_connection_points = Connection_points,
        input_connection_points = Connection_points
    }

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
        name = This_MOD.tech_name,
        effects = {
            { type = "unlock-recipe", recipe = This_MOD.sender_name, },
            { type = "unlock-recipe", recipe = This_MOD.receiver_name, },
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
                mods["space-age"] and { "space-science-pack", 1 } or nil
            }
        }
    }

    --- Crear la tecnología
    GPrefix.extend(Technology)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Estilos a usar
function This_MOD.load_styles()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Multiuso
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    Styles[Prefix .. "flow_vertival_8"] = {
        type = "vertical_flow_style",
        vertical_spacing = 8
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



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
        parent = "dropdown",
        list_box_style = {
            type = "list_box_style",
            item_style = {
                type = "button_style",
                parent = "list_box_item",
                left_click_sound = This_MOD.sound .. "empty_audio.ogg",
            },
        },
        width = 296 + 64
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



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
        left_click_sound = This_MOD.sound .. "empty_audio.ogg",
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
        width = 296
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Icono para las imagenes
function This_MOD.load_icon()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    local Name = GPrefix.name .. "-icon"
    if data.raw["virtual-signal"][Name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la señal
    GPrefix.extend({
        type = "virtual-signal",
        name = Name,
        localised_name = "",
        icon = This_MOD.graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar el sonido
function This_MOD.load_sound()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.extend({
        type = "sound",
        name = "gui_tool_button",
        filename = "__core__/sound/gui-tool-button.ogg",
        volume = 1.0
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
