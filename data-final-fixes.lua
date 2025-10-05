---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_subgroup(space)
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            -- This_MOD.create_recipe(space)
            -- This_MOD.create_tech(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- IDs de las entidades
    This_MOD.id_sender = "A01A"
    This_MOD.id_receiver = "A02A"

    --- Nombre de las entidades
    This_MOD.name_sender = GMOD.name .. "-" .. This_MOD.id_sender .. "-sender"
    This_MOD.name_receiver = GMOD.name .. "-" .. This_MOD.id_receiver .. "-receiver"

    --- Ruta a los multimedias
    This_MOD.path_graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.path_sound = "__" .. This_MOD.prefix .. This_MOD.name .. "__/sound/"

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores para el proceso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Space = {}
    Space.combinator = GMOD.entities["decider-combinator"]
    Space.item = GMOD.get_item_create(Space.combinator, "place_result")
    Space.entity = GMOD.entities["radar"]

    Space.recipe = GMOD.recipes[Space.item.name]
    Space.tech = GMOD.get_technology(Space.recipe)
    Space.recipe = Space.recipe and Space.recipe[1] or nil

    Space.subgroup = This_MOD.prefix .. GMOD.delete_prefix(Space.item.subgroup)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Space.combinator then return end
    if not Space.entity then return end
    if GMOD.entities[This_MOD.name_sender] then return end
    if GMOD.entities[This_MOD.name_receiver] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed.entities = This_MOD.to_be_processed.entities or {}
    This_MOD.to_be_processed.entities[Space.entity.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_subgroup(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear un nuevo subgrupo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Old = space.item.subgroup
    local New = space.subgroup
    GMOD.duplicate_subgroup(Old, New)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = GMOD.copy(space.item)
    Sender.icons = { { icon = This_MOD.path_graphics .. "item-sender.png" } }
    Sender.subgroup = space.subgroup
    Sender.order = "010"

    Sender.name = This_MOD.name_sender
    Sender.place_result = This_MOD.name_sender

    Sender.localised_name = { "", { "entity-name." .. Sender.name } }
    Sender.localised_description = { "", { "entity-description." .. Sender.name } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = GMOD.copy(space.item)
    Receiver.icons = { { icon = This_MOD.path_graphics .. "item-receiver.png" } }
    Receiver.subgroup = space.subgroup
    Sender.order = "020"

    Receiver.name = This_MOD.name_receiver
    Receiver.place_result = This_MOD.name_receiver

    Receiver.localised_name = { "", { "entity-name." .. Receiver.name } }
    Receiver.localised_description = { "", { "entity-description." .. Receiver.name } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Sender, Receiver)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Emisor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Sender = {
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        type = "roboport",
        name = This_MOD.name_sender,

        localised_name = { "", { "entity-name." .. This_MOD.name_sender } },
        localised_description = { "", { "entity-description." .. This_MOD.name_sender } },

        icons = { { icon = This_MOD.path_graphics .. "item-sender.png" } },

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
                    filename = This_MOD.path_graphics .. "entity-sender.png",
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
                    filename = This_MOD.path_graphics .. "entity-sender-shadow.png",
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
                name = This_MOD.name_sender,
                amount = 1
            } }
        },

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        radar_range = space.entity.max_distance_of_sector_revealed or 1,
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Receptor
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Receiver = {
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        type = "roboport",
        name = This_MOD.name_receiver,

        localised_name = { "", { "entity-name." .. This_MOD.name_receiver } },
        localised_description = { "", { "entity-description." .. This_MOD.name_receiver } },

        icons = { { icon = This_MOD.path_graphics .. "item-receiver.png" } },

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
                    filename = This_MOD.path_graphics .. "entity-receiver.png",
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
                    filename = This_MOD.path_graphics .. "entity-receiver-shadow.png",
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
                name = This_MOD.name_receiver,
                amount = 1
            } }
        },

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        radar_range = space.entity.max_distance_of_sector_revealed or 1,
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Combinador
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
        name = This_MOD.prefix .. space.combinator.name,

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Sender, Receiver, Combinator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = space.name

    --- Apodo y descripción
    Recipe.localised_name = GMOD.copy(space.entity.localised_name)
    Recipe.localised_description = GMOD.copy(This_MOD.lane_splitter.localised_description)

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Productividad
    Recipe.allow_productivity = true
    Recipe.maximum_productivity = 1000000

    --- Cambiar icono
    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator)

    --- Habilitar la receta
    Recipe.enabled = space.tech == nil

    --- Actualizar Order
    local Order = tonumber(Recipe.order) + 1
    Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

    --- Ingredientes
    for _, ingredient in pairs(Recipe.ingredients) do
        ingredient.name = (function(name)
            --- Validación
            if not name then return end

            --- Procesar el nombre
            local That_MOD =
                GMOD.get_id_and_name(name) or
                { ids = "-", name = name }

            --- Nombre despues de aplicar el MOD
            local New_name =
                GMOD.name .. That_MOD.ids ..
                This_MOD.id .. "-" ..
                That_MOD.name

            --- La entidad ya existe
            if GMOD.entities[New_name] ~= nil then
                return New_name
            end

            --- La entidad existirá
            for _, Spaces in pairs(This_MOD.to_be_processed) do
                for _, Space in pairs(Spaces) do
                    if Space.entity.name == name then
                        return New_name
                    end
                end
            end
        end)(ingredient.name) or ingredient.name
    end

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end
    if data.raw.technology[space.name .. "-tech"] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = GMOD.copy(space.tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Tech.name = space.name .. "-tech"

    --- Apodo y descripción
    Tech.localised_name = GMOD.copy(space.entity.localised_name)
    Tech.localised_description = GMOD.copy(This_MOD.lane_splitter.localised_description)

    --- Cambiar icono
    Tech.icons = GMOD.copy(space.item.icons)
    table.insert(Tech.icons, This_MOD.indicator_tech)

    --- Tech previas
    Tech.prerequisites = { space.tech.name }

    --- Efecto de la tech
    Tech.effects = { {
        type = "unlock-recipe",
        recipe = space.name
    } }

    --- Tech se activa con una fabricación
    if Tech.research_trigger then
        Tech.research_trigger = {
            type = "craft-item",
            item = space.item.name,
            count = 1
        }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
