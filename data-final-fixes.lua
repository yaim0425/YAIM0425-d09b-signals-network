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

    -- --- Modificar los elementos
    -- for _, spaces in pairs(This_MOD.to_be_processed) do
    --     for _, space in pairs(spaces) do
    --         --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --         -- --- Crear los elementos
    --         -- This_MOD.create_item(space)
    --         -- This_MOD.create_entity(space)
    --         -- This_MOD.create_recipe(space)
    --         -- This_MOD.create_tech(space)

    --         --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --     end
    -- end

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
    This_MOD.name_receiver = GMOD.name .. "-" .. This_MOD.id_sender .. "-receiver"

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
    Space.entity = GMOD.entities["radar"]

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

    This_MOD.to_be_processed[Space.entity.name] = This_MOD.to_be_processed[Space.entity.name] or {}
    This_MOD.to_be_processed[Space.entity.name][Space.item.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = space.name

    --- Apodo y descripción
    Item.localised_name = GMOD.copy(space.entity.localised_name)
    Item.localised_description = GMOD.copy(This_MOD.lane_splitter.localised_description)

    --- Entidad a crear
    Item.place_result = space.name

    --- Agregar indicador del MOD
    table.insert(Item.icons, This_MOD.indicator)

    --- Actualizar Order
    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = space.name

    --- Apodo y descripción
    Entity.localised_name = GMOD.copy(space.entity.localised_name)
    Entity.localised_description = GMOD.copy(This_MOD.lane_splitter.localised_description)

    --- Cambiar el tipo
    Entity.type = This_MOD.lane_splitter.type

    --- Elimnar propiedades inecesarias
    Entity.factoriopedia_simulation = nil

    --- Cambiar icono
    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator)

    --- Copiar algunos valores
    for _, propiety in pairs({
        "collision_box",
        "selection_box",
        "fast_replaceable_group"
    }) do
        Entity[propiety] = This_MOD.lane_splitter[propiety]
    end

    for _, propiety in pairs({ "structure", "structure_patch" }) do
        for key, newTable in pairs(Entity[propiety] or {}) do
            local oldTable = This_MOD.lane_splitter[propiety][key] or {}
            newTable.shift = oldTable.shift
            newTable.scale = oldTable.scale
        end
    end

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- Siguiente tier
    Entity.next_upgrade = (function()
        --- Validación
        if not Entity.next_upgrade then return end

        --- Procesar el nombre
        local That_MOD =
            GMOD.get_id_and_name(Entity.next_upgrade) or
            { ids = "-", name = Entity.next_upgrade }

        --- Nombre despues del aplicar el MOD
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
                if Space.entity.name == Entity.next_upgrade then
                    return New_name
                end
            end
        end
    end)()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

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
ERROR()