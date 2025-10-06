---------------------------------------------------------------------------
---[ control.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar las funciones comunes ]---
---------------------------------------------------------------------------

require("__" .. "YAIM0425-d00b-core" .. "__/control")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if This_MOD.setting then return end

    --- Valor de referencia
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Ejecución de las funciones
    This_MOD.reference_values()
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- IDs de las entidades
    This_MOD.id_sender = "A01A"
    This_MOD.id_receiver = "A02A"

    --- Valores propios
    This_MOD.new_channel = { This_MOD.prefix .. "new-channel" }

    --- Nombre del combinador
    This_MOD.combinator_name = This_MOD.prefix .. GMOD.entities["decider-combinator"].name

    --- Configuración de la superficie
    This_MOD.map_gen_settings = {
        width = 1,
        height = 1,
        property_expression_names = {},
        autoplace_settings = {
            decorative = {
                treat_missing_as_default = false,
                settings = {}
            },
            entity = {
                treat_missing_as_default = false,
                settings = {}
            },
            tile = {
                treat_missing_as_default = false,
                settings = {
                    ["out-of-map"] = {}
                }
            }
        }
    }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.edit = 2
    This_MOD.action.new_channel = 3
    This_MOD.action.close_force = 4

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Eventos programados ]---
---------------------------------------------------------------------------

function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Al crear la entidad
    -- script.on_event({
    --     defines.events.on_built_entity,
    --     defines.events.on_robot_built_entity,
    --     defines.events.script_raised_built,
    --     defines.events.script_raised_revive,
    --     defines.events.on_space_platform_built_entity,
    -- }, function(event)
    --     This_MOD.create_entity(This_MOD.create_data(event))
    -- end)

    -- --- Abrir o cerrar la interfaz
    -- script.on_event({
    --     defines.events.on_gui_opened,
    --     defines.events.on_gui_closed
    -- }, function(event)
    --     This_MOD.toggle_gui(This_MOD.create_data(event))
    -- end)

    -- --- Al seleccionar otro canal
    -- script.on_event({
    --     defines.events.on_gui_selection_state_changed
    -- }, function(event)
    --     This_MOD.selection_channel(This_MOD.create_data(event))
    -- end)

    -- --- Al hacer clic en algún elemento de la ventana
    -- script.on_event({
    --     defines.events.on_gui_click
    -- }, function(event)
    --     This_MOD.button_action(This_MOD.create_data(event))
    -- end)

    -- --- Al seleccionar o deseleccionar un icon
    -- script.on_event({
    --     defines.events.on_gui_elem_changed
    -- }, function(event)
    --     This_MOD.add_icon(This_MOD.create_data(event))
    -- end)

    -- --- Al presionar ENTER
    -- script.on_event({
    --     defines.events.on_gui_confirmed
    -- }, function(event)
    --     This_MOD.validate_channel_name(This_MOD.Create_data(event))
    -- end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_entity(Data) end

function This_MOD.toggle_gui(Data) end

function This_MOD.selection_channel(Data) end

function This_MOD.button_action(Data) end

function This_MOD.add_icon(Data) end

function This_MOD.validate_channel_name(Data) end

---------------------------------------------------------------------------

function This_MOD.show_old_channel(Data) end

function This_MOD.show_new_channel(Data) end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones auxiliares ]---
---------------------------------------------------------------------------

function This_MOD.get_surface()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if game.surfaces[This_MOD.prefix .. This_MOD.name] then
        return game.surfaces[This_MOD.prefix .. This_MOD.name]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear la superficie
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la superficie
    local Surface = game.create_surface(
        This_MOD.prefix .. This_MOD.name,
        This_MOD.map_gen_settings
    )

    --- Crear el espacio a usar
    Surface.request_to_generate_chunks({ 0, 0 }, 1)
    Surface.force_generate_chunk_requests()

    --- Ocultar la superficie de todas las fuerzas
    for _, force in pairs(game.forces) do
        force.set_surface_hidden(Surface, true)
    end

    --- Devolver la superficie
    return Surface

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.get_channel(Data, channel)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Superficie de los canales
    local Surface = This_MOD.get_surface()

    --- Convertir el id en iconos
    if not channel then
        channel = ""
        local ID = tostring(#Data.channels + 1)
        for n = 1, #ID do
            channel = channel .. "[img=virtual-signal.signal-" .. ID:sub(n, n) .. "]"
        end
    end

    --- Cargar el canal indicado
    local Channel = GMOD.get_tables(Data.channels, "name", channel)
    if Channel then return Channel end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear un nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el poste
    local Entity = Surface.create_entity({
        name = "small-electric-pole",
        position = { 0, 0 },
        force = Data.Force.name
    })

    --- Desconectar el poste
    local Copper = Entity.get_wire_connector(defines.wire_connector_id.pole_copper, false)
    Copper.disconnect_all(defines.wire_origin.script)

    --- Guardar el nuevo canal
    Channel = {}
    Channel.index = #Data.channels + 1
    Channel.entity = Entity
    Channel.name = channel
    Channel.red = Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    Channel.green = Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    Data.channels[Channel.index] = Channel

    --- Devolver el canal indicado
    return Channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.sound_good(Data)
    Data.Player.play_sound({ path = "gui_tool_button" })
end

function This_MOD.sound_bad(Data)
    Data.Player.play_sound({ path = "utility/cannot_build" })
end

function This_MOD.sound_channel_selected(Data)
    Data.Player.play_sound({ path = "utility/gui_click" })
end

function This_MOD.sound_channel_changed(Data)
    Data.Player.play_sound({ path = "utility/wire_connect_pole" })
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
