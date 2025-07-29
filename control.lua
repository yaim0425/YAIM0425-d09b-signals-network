---------------------------------------------------------------------------------------------------
---> control.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Cargar las funciones
require("__zzzYAIM0425-0000-lib__/control")

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Cambiar la propiedad necesaria
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores constante
    This_MOD.sender_name = "sender"
    This_MOD.receiver_name = "receiver"

    --- Canales constantes
    This_MOD.channel_default = { This_MOD.prefix .. "default-channel" }
    This_MOD.new_channel = { This_MOD.prefix .. "new-channel" }

    --- Valores de referencia
    This_MOD.ref = {}
    This_MOD.ref.combinator = GPrefix.entities["decider-combinator"]

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.edit = 2
    This_MOD.action.new_channel = 3
    This_MOD.action.close_force = 4

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar los eventos a ejecutar
function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Al crear la entidad
    script.on_event({
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity,
    }, function(event)
        This_MOD.create_entity(This_MOD.create_data(event))
    end)

    --- Ocultar la superficie de las fuerzas recién creadas
    script.on_event({
        defines.events.on_force_created
    }, function(event)
        game.players[event.player_index].print("hide_surface")
        -- This_MOD.hide_surface(This_MOD.Create_data(event))
    end)

    script.on_event({
        defines.events.on_forces_merged
    }, function(event)
        game.players[event.player_index].print("forces_merged")
        -- This_MOD.forces_merged(This_MOD.Create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Modificar el fantasma de reconstrucción
    script.on_event({
        defines.events.on_post_entity_died
    }, function(event)
        event.entity = event.ghost
        This_MOD.edit_ghost(This_MOD.create_data(event))
    end)

    --- Muerte de la entidad
    script.on_event({
        defines.events.on_entity_died
    }, function(event)
        This_MOD.beafore_entity_died(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Verificación periodica
    script.on_nth_tick(20, function()
        --- La entidad tenga energía
        This_MOD.check_power()

        --- Forzar el cierre, en caso de ser necesario
        This_MOD.validate_gui()

        --- Información de las antenas destruidas
        This_MOD.after_entity_died()
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Abrir o cerrar la interfaz
    script.on_event({
        defines.events.on_gui_opened,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    --- Al seleccionar o deseleccionar un icon
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        game.players[event.player_index].print("add_icon")
        -- This_MOD.add_icon(This_MOD.Create_data(event))
    end)

    --- Al seleccionar otro canal
    script.on_event({
        defines.events.on_gui_selection_state_changed
    }, function(event)
        This_MOD.selection_channel(This_MOD.create_data(event))
    end)

    --- Al hacer clic en algún elemento de la ventana
    script.on_event({
        defines.events.on_gui_click
    }, function(event)
        game.players[event.player_index].print("button_action")
        -- This_MOD.button_action(This_MOD.Create_data(event))
    end)

    --- Validar el nuevo nombre
    script.on_event({
        defines.events.on_gui_confirmed
    }, function(event)
        game.players[event.player_index].print("validate_channel_name")
        -- This_MOD.validate_channel_name(This_MOD.Create_data(event))
    end)

    --- Al copiar las entidades
    script.on_event({
        defines.events.on_player_setup_blueprint
    }, function(event)
        This_MOD.create_blueprint(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crea y agrupar las variables a usar
function This_MOD.create_data(event)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Consolidar la información
    local Data = GPrefix.create_data(event or {}, This_MOD)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.gForce then return Data end
    if not event then return Data end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Postes / canales
    Data.gForce.channels = Data.gForce.channels or {}
    Data.channels = Data.gForce.channels

    --- Antenas
    Data.gForce.nodes = Data.gForce.nodes or {}
    Data.nodes = Data.gForce.nodes

    --- Auxiliar
    Data.gForce.ghosts = Data.gForce.ghosts or {}
    Data.ghosts = Data.gForce.ghosts

    --- Cargar el nodo a tratar
    if Data.Entity or Data.GUI then
        local Entity = Data.Entity or Data.GUI.entity
        Data.node = GPrefix.get_table(Data.nodes, "entity", Entity)
    end

    --- Devolver el consolidado de los datos
    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Acciones por eventos
---------------------------------------------------------------------------------------------------

--- Al crear la entidad
function This_MOD.create_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad no valida
    if not Data.Entity then return end
    if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Canal por defecto
    This_MOD.get_channel(Data, This_MOD.channel_default)

    --- Canal para la nueva antena
    local Tags = Data.Event.tags
    Tags = Tags and Tags.name or This_MOD.channel_default
    local Channel = This_MOD.get_channel(Data, Tags)

    --- Borrar el nombre adicional de la entidad
    Data.Entity.backer_name = ""

    --- Guardar el canal de la enridad
    local Node = {}
    Node.entity = Data.Entity
    Node.channel = Channel
    Node.connect = false
    Node.unit_number = Data.Entity.unit_number
    table.insert(Data.nodes, Node)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Emisor
    if string.find(Data.Entity.name, This_MOD.sender_name, 1, true) then
        --- Superficie de los canales
        local Surface = This_MOD.get_surface()

        --- Crear los filtros
        Node.filter_red = Surface.create_entity({
            name = This_MOD.prefix .. This_MOD.ref.combinator.name,
            force = Data.Force.name,
            position = { 0, 0 }
        })
        Node.filter_green = Surface.create_entity({
            name = This_MOD.prefix .. This_MOD.ref.combinator.name,
            force = Data.Force.name,
            position = { 0, 0 }
        })

        --- Configurar los filtros
        Node.filter_red.get_or_create_control_behavior().parameters = {
            output_signal = { type = "virtual", name = "signal-everything" },
            first_signal = { type = "virtual", name = "signal-anything" },
            comparator = "≠"
        }
        Node.filter_green.get_or_create_control_behavior().parameters = {
            output_signal = { type = "virtual", name = "signal-everything" },
            first_signal = { type = "virtual", name = "signal-anything" },
            comparator = "≠"
        }

        --- Puntos de conexión de los filtros
        local Filter_red = Node.filter_red.get_wire_connector(defines.wire_connector_id.combinator_input_red, true)
        local Filter_green = Node.filter_green.get_wire_connector(defines.wire_connector_id.combinator_input_green, true)

        --- Puntos de conexión del emisor
        local Sender_red = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
        local Sender_green = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)

        --- Conectar el emisor a los filtros
        Sender_red.connect_to(Filter_red, false, defines.wire_origin.script)
        Sender_green.connect_to(Filter_green, false, defines.wire_origin.script)

        --- Guardar el puntos de conexión
        Node.red = Node.filter_red.get_wire_connector(defines.wire_connector_id.combinator_output_red, true)
        Node.green = Node.filter_green.get_wire_connector(defines.wire_connector_id.combinator_output_green, true)
        Node.type = This_MOD.sender_name
    end

    --- Receptor
    if string.find(Data.Entity.name, This_MOD.receiver_name, 1, true) then
        Node.red = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
        Node.green = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        Node.type = This_MOD.receiver_name
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

-- --- Ocultar la superficie de las fuerzas recién creadas
-- function This_MOD.hide_surface(Data)
--     local Surface = This_MOD.get_surface()
--     if Surface then
--         Data.Event.force.set_surface_hidden(Surface, true)
--     end
-- end

-- --- Al fusionar dos fuerzas
-- function This_MOD.forces_merged(Data)
--     --- Renombrar
--     local Source = Data.gForces[Data.Event.source_index]
--     if not Source then return end
--     local Destination = This_MOD.create_data({
--         force = Data.Event.destination
--     })

--     --- Mover los canales
--     for index, Channel in pairs(Source.Channel) do
--         Destination.channel[index] = Channel
--     end

--     --- Mover los nodos
--     for index, Node in pairs(Source.Node) do
--         Destination.node[index] = Node
--     end

--     --- Eliminar la referencia a la fuerza
--     Data.gForces[Data.Event.source_index] = nil
-- end

---------------------------------------------------------------------------------------------------

--- Modificar el fantasma de reconstrucción
function This_MOD.edit_ghost(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar
    local Ghost = Data.Event.ghost
    local Prototype = Data.Event.prototype

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Ghost then return end
    if not GPrefix.has_id(Prototype.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la información relacionada
    local Info = GPrefix.get_table(Data.ghosts, "unit_number", Data.Event.unit_number)
    if not Info then return end

    --- Modificar el fantasma
    Ghost.tags = { name = Info.channel.name }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Muerte de la entidad
function This_MOD.beafore_entity_died(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Eliminar la conexión
    Data.node.red.disconnect_from(Data.node.channel.red, defines.wire_origin.script)
    Data.node.green.disconnect_from(Data.node.channel.green, defines.wire_origin.script)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Información a guardar
    local Info = {}
    Info.unit_number = Data.node.unit_number
    Info.channel = Data.node.channel
    Info.tick = 9

    --- Guardar la información
    table.insert(Data.ghosts, Info)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- La entidad tenga energía
function This_MOD.check_power()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function connection_toggle(Data)
        --- Entidad a modificar
        if not Data.Entity then return end
        if not Data.Entity.valid then return end

        --- Renombrar
        local Node = GPrefix.get_table(Data.nodes, "entity", Data.Entity)

        if Node.connect then
            --- Desconectar
            Node.connect = false
            Node.red.disconnect_from(Node.channel.red, defines.wire_origin.script)
            Node.green.disconnect_from(Node.channel.green, defines.wire_origin.script)
        else
            --- Conectar
            Node.connect = true
            Node.red.connect_to(Node.channel.red, false, defines.wire_origin.script)
            Node.green.connect_to(Node.channel.green, false, defines.wire_origin.script)
        end
    end

    local function check_power(Node)
        --- En Factorio 2.0 puede ocurrir que la entidad esté
        --- completamente alimentada, pero debido a algunas
        --- peculiaridades del motor el búfer sólo está lleno
        --- al 96%, por ejemplo.

        --- Umbral de activació: 90%
        local Threshold = 0.9

        --- Variables a usar
        local Energy = Node.entity.energy
        local Buffer = Node.entity.electric_buffer_size
        local Power_satisfied = Energy >= Buffer * Threshold

        --- Acciones
        local Flag = false
        Flag = Flag or Node.connect and not Power_satisfied --- Desconectar
        Flag = Flag or not Node.connect and Power_satisfied --- Conectar
        if Flag then
            local Data = { entity = Node.entity }
            Data = This_MOD.create_data(Data)
            connection_toggle(Data)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer cada fuerza activa
    for _, gForce in pairs(This_MOD.create_data().gForces) do
        --- Antenas a eliminar
        local Deleted = {}

        --- Validar cada antena
        for key, node in pairs(gForce.nodes) do
            if node.entity and node.entity.valid then
                check_power(node)
            else
                table.insert(Deleted, 1, key)
            end
        end

        --- Eliminar a las entidad invalidas
        for _, key in pairs(Deleted) do
            local Node = gForce.nodes[key]
            table.remove(gForce.nodes, key)

            if Node.type == This_MOD.sender_name then
                Node.filter_red.destroy()
                Node.filter_green.destroy()
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Validar el estado
function This_MOD.validate_gui()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for player_index, GPlayer in pairs(This_MOD.create_data().GPlayers) do
        This_MOD.validate_entity(
            This_MOD.create_data({
                entity = GPlayer.GUI.entity,
                player_index = player_index
            })
        )
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Información de las antenas destruidas
function This_MOD.after_entity_died()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer cada fuerza activa
    for _, gForce in pairs(This_MOD.create_data().gForces) do
        --- Información a eliminar
        local Deleted = {}

        --- Revisar cada información
        for key, ghost in pairs(gForce.ghosts) do
            if ghost.tick == 0 then
                table.insert(Deleted, 1, key)
            else
                ghost.tick = ghost.tick - 1
            end
        end

        --- Eliminar la información
        for _, key in pairs(Deleted) do
            table.remove(gForce.ghosts, key)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Funciones de apoyo
---------------------------------------------------------------------------------------------------

--- Superficie de los canales
function This_MOD.get_surface()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver la superficie de existir
    if game.surfaces[This_MOD.prefix .. This_MOD.name] then
        return game.surfaces[This_MOD.prefix .. This_MOD.name]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la superficie si no existe
    local map_gen_settings = {
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
    local Surface = game.create_surface(This_MOD.prefix .. This_MOD.name, map_gen_settings)
    Surface.request_to_generate_chunks({ 0, 0 }, 1)
    Surface.force_generate_chunk_requests()

    --- Ocultar la superficie de todas las fuerzas vistas a
    --- distancia sobre la creación
    for _, force in pairs(game.forces) do
        force.set_surface_hidden(Surface, true)
    end

    --- Devolver la superficie
    return Surface

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Obtener un canal
function This_MOD.get_channel(Data, channel)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Superficie de los canales
    local Surface = This_MOD.get_surface()

    --- Se busca el canal por defecto
    local Index = GPrefix.pad_left_zeros(10, 1)
    local Flag = GPrefix.get_length(Data.channels)
    Flag = Flag and GPrefix.is_table(channel)
    if Flag then return Data.channels[Index] end

    --- Cargar el canal indicado
    local Channel = GPrefix.get_table(Data.channels, "name", channel)
    if Channel then return Channel end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
    Channel.index = GPrefix.get_length(Data.channels) or 0
    Channel.index = GPrefix.pad_left_zeros(10, Channel.index + 1)
    Channel.entity = Entity
    Channel.name = channel
    Channel.red = Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    Channel.green = Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    Data.channels[Channel.index] = Channel

    --- Devolver el canal indicado
    return Channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cambiar el canal
function This_MOD.set_channel(node, channel)
    --- No hay cambio
    if node.channel and node.channel == channel then return end
    if not node.entity.valid then return end

    --- Cambiar los cables de canal
    if node.connect then
        --- Desconectar
        node.red.disconnect_from(node.channel.red, defines.wire_origin.script)
        node.green.disconnect_from(node.channel.green, defines.wire_origin.script)

        --- Conectar
        node.red.connect_to(channel.red, false, defines.wire_origin.script)
        node.green.connect_to(channel.green, false, defines.wire_origin.script)
    end

    --- Guardar el canal de la enridad
    node.channel = channel
end

--- Forzar cierre de la GUI
function This_MOD.validate_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cerrado forzado de la ventana de ser necesario
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Flag = false
    Flag = (Data.GUI.entity and Data.GUI.entity.valid)
    Flag = Flag or (Data.Entity and Data.Entity.valid)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Flag then
        if Data.GUI.frame_main then
            Data.GUI.action = This_MOD.action.close_force
            This_MOD.toggle_gui(Data)
        end
        return false
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Aprovado
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    return true

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

-- --- Obtener el indice del canal de la entidad
-- function This_MOD.get_index_of_channel(Data)
--     --- --- --- --- --- --- --- --- --- --- --- --- --- ---

--     local Channel_name = GPrefix.get_table(Data.nodes, "entity", Data.Entity).channel.name
--     local i = 0

--     for _, channel in pairs(Data.channels) do
--         i = i + 1
--         if channel.name == Channel_name then
--             return i
--         end
--     end

--     --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- end

-- --- Obtener el canal seleccionado
-- function This_MOD.get_channel_pos(Data)
--     local Pos = 0
--     for _, channel in pairs(Data.Channel) do
--         Pos = Pos + 1
--         if Pos == Data.GUI.Pos then
--             return channel
--         end
--     end
-- end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Acciones en el GUI
---------------------------------------------------------------------------------------------------

--- Crear o destruir la ventana
function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_main then return false end
        if Data.GUI.action == This_MOD.action.build then return false end
        if Data.GUI.action == This_MOD.action.close_force then return true end
        if not Data.Event.element then return false end
        if Data.Event.element == Data.GUI.frame_main then return true end
        if Data.Event.element ~= Data.GUI.button_exit then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- ---


        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end
    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Data.GUI.frame_main then return false end
        if not This_MOD.validate_entity(Data) then return false end
        if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> En caso de ser necesaria
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.node then
            This_MOD.create_entity({
                entity = Data.Entity
            })
        end

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function gui_destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main.destroy()
        Data.GPlayer.GUI = {}
        Data.GUI = Data.GPlayer.GUI
        Data.Player.opened = nil

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end
    local function gui_build()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_main = {}
        Data.GUI.frame_main.type = "frame"
        Data.GUI.frame_main.name = "frame_main"
        Data.GUI.frame_main.direction = "vertical"
        Data.GUI.frame_main = Data.Player.gui.screen.add(Data.GUI.frame_main)
        Data.GUI.frame_main.style = "frame"
        Data.GUI.frame_main.auto_center = true

        --- Indicar que la ventana esta abierta
        --- Cerrar la ventana al abrir otra ventana, presionar E o Esc
        Data.Player.opened = Data.GUI.frame_main

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor de la cabeza
        Data.GUI.flow_head = {}
        Data.GUI.flow_head.type = "flow"
        Data.GUI.flow_head.name = "flow_head"
        Data.GUI.flow_head.direction = "horizontal"
        Data.GUI.flow_head = Data.GUI.frame_main.add(Data.GUI.flow_head)
        Data.GUI.flow_head.style = Prefix .. "flow_head"

        --- Etiqueta con el titulo
        Data.GUI.label_title = {}
        Data.GUI.label_title.type = "label"
        Data.GUI.label_title.name = "title"
        Data.GUI.label_title.caption = { "entity-name." .. Data.Entity.name }
        Data.GUI.label_title = Data.GUI.flow_head.add(Data.GUI.label_title)
        Data.GUI.label_title.style = Prefix .. "label_title"

        --- Indicador para mover la ventana
        Data.GUI.empty_widget_head = {}
        Data.GUI.empty_widget_head.type = "empty-widget"
        Data.GUI.empty_widget_head.name = "empty_widget_head"
        Data.GUI.empty_widget_head = Data.GUI.flow_head.add(Data.GUI.empty_widget_head)
        Data.GUI.empty_widget_head.drag_target = Data.GUI.frame_main
        Data.GUI.empty_widget_head.style = Prefix .. "empty_widget"

        --- Botón de cierre
        Data.GUI.button_exit = {}
        Data.GUI.button_exit.type = "sprite-button"
        Data.GUI.button_exit.name = "button_exit"
        Data.GUI.button_exit.sprite = "utility/close"
        Data.GUI.button_exit.hovered_sprite = "utility/close_black"
        Data.GUI.button_exit.clicked_sprite = "utility/close_black"
        Data.GUI.button_exit.tooltip = { "", { This_MOD.prefix .. "close" } }
        Data.GUI.button_exit = Data.GUI.flow_head.add(Data.GUI.button_exit)
        Data.GUI.button_exit.style = Prefix .. "button_close"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del cuerpo para el inventario
        Data.GUI.flow_items = {}
        Data.GUI.flow_items.type = "flow"
        Data.GUI.flow_items.name = "flow_items"
        Data.GUI.flow_items.direction = "vertical"
        Data.GUI.flow_items = Data.GUI.frame_main.add(Data.GUI.flow_items)
        Data.GUI.flow_items.style = Prefix .. "flow_vertival_8"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_entity = {}
        Data.GUI.frame_entity.type = "frame"
        Data.GUI.frame_entity.name = "frame_entity"
        Data.GUI.frame_entity.direction = "vertical"
        Data.GUI.frame_entity = Data.GUI.flow_items.add(Data.GUI.frame_entity)
        Data.GUI.frame_entity.style = Prefix .. "frame_entity"

        --- Imagen de la entidad
        Data.GUI.entity_preview_entity = {}
        Data.GUI.entity_preview_entity.name = "entity_preview_entity"
        Data.GUI.entity_preview_entity.type = "entity-preview"
        Data.GUI.entity_preview_entity = Data.GUI.frame_entity.add(Data.GUI.entity_preview_entity)
        Data.GUI.entity_preview_entity.style = "wide_entity_button"
        Data.GUI.entity_preview_entity.entity = Data.Entity

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_old_channel = {}
        Data.GUI.frame_old_channel.type = "frame"
        Data.GUI.frame_old_channel.name = "frame_old_channels"
        Data.GUI.frame_old_channel.direction = "horizontal"
        Data.GUI.frame_old_channel = Data.GUI.flow_items.add(Data.GUI.frame_old_channel)
        Data.GUI.frame_old_channel.style = Prefix .. "frame_body"

        --- Barra de movimiento
        Data.GUI.dropdown_channels = {}
        Data.GUI.dropdown_channels.type = "drop-down"
        Data.GUI.dropdown_channels.name = "drop_down_channels"
        Data.GUI.dropdown_channels = Data.GUI.frame_old_channel.add(Data.GUI.dropdown_channels)
        Data.GUI.dropdown_channels.style = Prefix .. "drop_down_channels"

        --- Botón para aplicar los cambios
        Data.GUI.button_edit = {}
        Data.GUI.button_edit.type = "sprite-button"
        Data.GUI.button_edit.name = "button_edit"
        Data.GUI.button_edit.sprite = "utility/rename_icon"
        Data.GUI.button_edit.tooltip = { This_MOD.prefix .. "edit-channel" }
        Data.GUI.button_edit = Data.GUI.frame_old_channel.add(Data.GUI.button_edit)
        Data.GUI.button_edit.style = Prefix .. "button_blue"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_new_channel = {}
        Data.GUI.frame_new_channel.type = "frame"
        Data.GUI.frame_new_channel.name = "frame_new_channels"
        Data.GUI.frame_new_channel.direction = "horizontal"
        Data.GUI.frame_new_channel = Data.GUI.flow_items.add(Data.GUI.frame_new_channel)
        Data.GUI.frame_new_channel.style = Prefix .. "frame_body"
        Data.GUI.frame_new_channel.visible = false

        --- Nuevo nombre
        Data.GUI.textfield_new_channel = {}
        Data.GUI.textfield_new_channel.type = "textfield"
        Data.GUI.textfield_new_channel.name = "write-channel"
        Data.GUI.textfield_new_channel.text = "xXx"
        Data.GUI.textfield_new_channel = Data.GUI.frame_new_channel.add(Data.GUI.textfield_new_channel)
        Data.GUI.textfield_new_channel.style = Prefix .. "stretchable_textfield"

        --- Crear la imagen de selección
        Data.GUI.button_icon = {}
        Data.GUI.button_icon.type = "choose-elem-button"
        Data.GUI.button_icon.name = "button_icon"
        Data.GUI.button_icon.elem_type = "signal"
        Data.GUI.button_icon.signal = { type = "virtual", name = GPrefix.name .. "-icon" }
        Data.GUI.button_icon = Data.GUI.frame_new_channel.add(Data.GUI.button_icon)
        Data.GUI.button_icon.style = Prefix .. "button"

        --- Botón para cancelar los cambios
        Data.GUI.button_cancel = {}
        Data.GUI.button_cancel.type = "sprite-button"
        Data.GUI.button_cancel.name = "button_cancel"
        Data.GUI.button_cancel.sprite = "utility/close_fat"
        Data.GUI.button_cancel.tooltip = { "gui-mod-settings.cancel" }
        Data.GUI.button_cancel = Data.GUI.frame_new_channel.add(Data.GUI.button_cancel)
        Data.GUI.button_cancel.style = Prefix .. "button_red"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_green"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm.tooltip = { "gui.confirm" }
        Data.GUI.button_confirm = Data.GUI.frame_new_channel.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- local function Info()
    --     --- Valores de la entidad
    --     Data.GUI.Node = Data.Node[Data.Entity.unit_number]

    --     --- Selección inicial
    --     Data.GUI.Pos_start = 0
    --     for index, _ in pairs(Data.channels) do
    --         Data.GUI.Pos_start = Data.GUI.Pos_start + 1
    --         if index == Data.GUI.Node.channel.index then
    --             break
    --         end
    --     end

    --     --- Selección actual
    --     Data.GUI.Pos = Data.GUI.Pos_start
    -- end

    --- Cargar los canales
    local function load_channels()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cargar los canales
        local Dropdown = Data.GUI.dropdown_channels
        for _, channel in pairs(Data.channels) do
            Dropdown.add_item(channel.name)
        end
        Dropdown.add_item(This_MOD.new_channel)

        --- Seleccionar el canal actual
        Dropdown.selected_index = tonumber(Data.node.channel.index)
        Data.GUI.button_edit.enabled = Dropdown.selected_index > 1

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        gui_destroy()
        Data.Player.play_sound({ path = "entity-close/decider-combinator" })
    elseif validate_open() then
        Data.GUI.action = This_MOD.action.build
        gui_build()
        load_channels()
        -- Info()
        -- Data.GUI.dropdown_channels.selected_index = Data.GUI.Pos
        -- This_MOD.selection_channel(Data)
        Data.GUI.entity = Data.Entity
        Data.GUI.action = This_MOD.action.none
        Data.Player.play_sound({ path = "entity-open/decider-combinator" })
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Al seleccionar un canal
function This_MOD.selection_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.GUI.frame_main then return end
    if not Data.GUI.dropdown_channels then return end
    if not This_MOD.validate_entity(Data) then return end
    local Element = Data.Event.element
    local Dropdown_channels = Data.GUI.dropdown_channels
    if Element and Element ~= Dropdown_channels then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Selección actual
    local Selected_index = Dropdown_channels.selected_index

    --- Se quiere crear un nuevo canal
    if Selected_index == #Dropdown_channels.items then
        This_MOD.show_new_channel(Data)
        Data.Player.play_sound({ path = "utility/gui_click" })
        return
    end

    --- Estado del botón
    Data.GUI.button_edit.enabled = Selected_index > 1

    --- Cambiar el canal del nodo
    local Channel = Data.channels[GPrefix.pad_left_zeros(10, Selected_index)]
    This_MOD.set_channel(Data.node, Channel)
    Data.Player.play_sound({ path = "utility/wire_connect_pole" })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

-- --- Acciones de los botones
-- function This_MOD.button_action(Data)
--     --- Variables a usar
--     local Flag = false
--     local EventID = 0

--     --- Validar el elemento
--     EventID = defines.events.on_gui_click
--     Flag = Data.Event.name == EventID
--     if not Flag then return end

--     --- --- --- --- --- --- --- --- --- --- --- --- --- ---



--     --- --- --- --- --- --- --- --- --- --- --- --- --- ---

--     --- Cerrar la ventana
--     Flag = Data.Event.element == Data.GUI.button_exit
--     if Flag then
--         This_MOD.toggle_gui(Data)
--         return
--     end

--     --- Cancelar el cambio de nombre o el nuevo canal
--     Flag = Data.Event.element == Data.GUI.button_cancel
--     if Flag then
--         Data.Event.element = Data.GUI.dropdown_channels
--         This_MOD.show_old_channel(Data)
--         return
--     end

--     --- Cambiar el nombre de un canal o agregar un nuevo canal
--     Flag = false or Data.GUI.action == This_MOD.action.edit
--     Flag = Flag or Data.GUI.action == This_MOD.action.new_channel
--     Flag = Flag and Data.Event.element == Data.GUI.button_green
--     if Flag then
--         This_MOD.validate_channel_name(Data)
--         return
--     end

--     --- Editar el nombre del canal seleccionado
--     Flag = Data.Event.element == Data.GUI.button_edit
--     if Flag then
--         Data.GUI.action = This_MOD.action.edit
--         This_MOD.show_new_channel(Data)
--         return
--     end

--     --- Cambiar el canal
--     Flag = Data.Event.element == Data.GUI.button_confirm
--     if Flag then
--         This_MOD.set_channel(Data.GUI.Node, This_MOD.get_channel_pos(Data))
--         Data.Event.element = Data.GUI.button_exit
--         This_MOD.toggle_gui(Data)
--         Data.Player.play_sound({ path = "entity-open/constant-combinator" })
--         return
--     end
-- end

-- --- Seleccionar un nuevo objeto
-- function This_MOD.add_icon(Data)
--     if not Data.GUI.button_icon then return end

--     --- Cargar la selección
--     local Select = Data.GUI.button_icon.elem_value

--     --- Restaurar el icono
--     Data.GUI.button_icon.elem_value = {
--         type = "virtual",
--         name = This_MOD.prefix .. "icon"
--     }

--     --- Se intentó limpiar el icono
--     if not Select then return end

--     --- Convertir seleccion en texto
--     local function signal_to_rich_text(select)
--         local type = ""

--         if not select.type then
--             if prototypes.entity[select.name] then
--                 type = "entity"
--             elseif prototypes.recipe[select.name] then
--                 type = "recipe"
--             elseif prototypes.fluid[select.name] then
--                 type = "fluid"
--             elseif prototypes.item[select.name] then
--                 type = "item"
--             end
--         end

--         if select.type then
--             type = select.type
--             if select.type == "virtual" then
--                 type = type .. "-signal"
--             end
--         end

--         return "[img=" .. type .. "." .. select.name .. "]"
--     end

--     --- Agregar la imagen seleccionada
--     local text = Data.GUI.textfield_new_channel.text
--     text = text .. signal_to_rich_text(Select)
--     Data.GUI.textfield_new_channel.text = text
--     Data.GUI.textfield_new_channel.focus()
-- end

--- Guardar el canal en la copia
function This_MOD.create_blueprint(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Blueprint = nil

    --- Identificar el tipo de selección
    local Flag_blueprint =
        Data.Player.blueprint_to_setup and
        Data.Player.blueprint_to_setup.valid_for_read

    local Flag_cursor =
        Data.Player.cursor_stack.valid_for_read and
        Data.Player.cursor_stack.is_blueprint

    --- Renombrar la selección
    if Flag_blueprint then
        Blueprint = Data.Player.blueprint_to_setup
    elseif Flag_cursor then
        Blueprint = Data.Player.cursor_stack
    end

    --- Validar la selección
    if not Blueprint then return end
    if not Blueprint.is_blueprint_setup() then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Listado de las entidades
    local Entities = Blueprint.get_blueprint_entities()
    if not Entities then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Guardar el canal al que está conectado
    local Mapping = Data.Event.mapping.get()
    for _, entity in pairs(Entities or {}) do
        if GPrefix.has_id(entity.name, This_MOD.id) then
            local Entity = Mapping[entity.entity_number]
            local Node = GPrefix.get_table(Data.nodes, "entity", Entity)
            local Tags = { name = Node.channel.name }
            Blueprint.set_blueprint_entity_tags(entity.entity_number, Tags)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

-- --- Mostrar el cuerpo para seleccionar un canal
-- function This_MOD.show_old_channel(Data)
--     --- Cambiar de frame
--     Data.GUI.frame_new_channels.visible = false
--     Data.GUI.frame_old_channels.visible = true

--     --- Enfocar la selección
--     Data.GUI.dropdown_channels.selected_index = Data.GUI.Pos
--     This_MOD.selection_channel(Data)
-- end

--- Mostrar el cuerpo para crear un nuevo canal
function This_MOD.show_new_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar de frame
    Data.GUI.frame_old_channel.visible = false
    Data.GUI.frame_new_channel.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Configuración para un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        Data.GUI.textfield_new_channel.text = ""
    end

    --- Configuración para un nuevo nombre
    if Data.GUI.action == This_MOD.action.edit then
        local Textfield = Data.GUI.textfield_new_channel
        Textfield.text = Data.node.channel.name
    end

    --- Enfocar nombre
    Data.GUI.textfield_new_channel.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

-- --- Validar el nombre del canal
-- function This_MOD.validate_channel_name(Data)
--     --- Texto a evaluar
--     local textfield = Data.GUI.textfield_new_channel

--     --- Nombre invalido
--     if textfield.text == "" then
--         textfield.focus()
--         return
--     end

--     --- Nuevo canal
--     local result = GPrefix.get_table(Data.Channel, "name", textfield.text)

--     --- Nombre ocupado
--     if result.name then
--         textfield.focus()
--         return
--     end

--     --- Crear un nuevo canal
--     if Data.GUI.action == This_MOD.action.new_channel then
--         --- Crear el nuevo canal
--         Data.GUI.Pos = GPrefix.get_length(Data.Channel) + 1
--         Data.Event.element = Data.GUI.dropdown_channels
--         This_MOD.get_channel(Data, textfield.text)

--         --- Agregar el nuevo canal
--         Data.GUI.dropdown_channels.add_item(textfield.text, Data.GUI.Pos)
--     end

--     --- Cambiar el nombre de un canal
--     if Data.GUI.action == This_MOD.action.edit then
--         --- Buscar el canal
--         local Channel = This_MOD.get_channel_pos(Data)

--         --- Actualizar el nombre
--         Channel.name = textfield.text
--         Data.GUI.dropdown_channels.set_item(Data.GUI.Pos, textfield.text)
--     end

--     --- Cambiar el canal
--     This_MOD.set_channel(Data.GUI.Node, This_MOD.get_channel_pos(Data))

--     --- Cerrar la ventana
--     Data.Event.element = Data.GUI.button_exit
--     This_MOD.toggle_gui(Data)
--     Data.Player.play_sound({ path = "entity-open/constant-combinator" })
-- end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--[[ Código de prueba

script.on_init(function()
    local player = game.players[1]  -- Solo hay un jugador
    if not player then return end

    -- Crear un nuevo force temporal
    local temp_force_name = "temporary_force"
    if not game.forces[temp_force_name] then
        game.create_force(temp_force_name)
    end
    local temp_force = game.forces[temp_force_name]

    -- Crear 10 entidades para ese force
    local surface = player.surface
    local position = player.position

    for i = 1, 10 do
        local entity_position = { x = position.x + i, y = position.y }
        surface.create_entity{
            name = "stone-furnace",  -- Puedes cambiarlo por otra entidad válida
            position = entity_position,
            force = temp_force,
            create_build_effect_smoke = false
        }
    end

    -- Fusionar fuerzas: temp_force → jugador.force
    temp_force.merge(player.force)

    -- Confirmación en consola
    player.print("Se crearon 10 entidades en un force temporal y se fusionó con el force del jugador.")
end)

]]

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
