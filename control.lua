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

    -- --- Cambiar la propiedad necesaria
    -- This_MOD.Load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores constante
    This_MOD.sender_name = This_MOD.prefix .. "sender"
    This_MOD.receiver_name = This_MOD.prefix .. "receiver"

    --- Canales constantes
    This_MOD.Channel_default = { This_MOD.prefix .. "default-channel" }
    This_MOD.New_channel = { This_MOD.prefix .. "new-channel" }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.edit = 2
    -- ThisMOD.Action.apply = 3
    -- ThisMOD.Action.discard = 4
    This_MOD.action.new_channel = 5

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Cargar los eventos a ejecutar
function This_MOD.Load_events()
    --- Al crear la entidad
    script.on_event({
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity,
    }, function(event)
        This_MOD.on_entity_created(This_MOD.Create_data(event))
    end)

    --- Ocultar la superficie de las fuerzas recién creadas
    script.on_event({
        defines.events.on_force_created
    }, function(event)
        This_MOD.hide_surface(This_MOD.Create_data(event))
    end)

    script.on_event({
        defines.events.on_forces_merged
    }, function(event)
        This_MOD.forces_merged(This_MOD.Create_data(event))
    end)

    --- Verificar que la entidad tenga energía
    script.on_nth_tick(30, This_MOD.check_power)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Abrir o cerrar la interfaz
    script.on_event({
        defines.events.on_gui_opened,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.Toggle_window(This_MOD.Create_data(event))
    end)

    --- Al seleccionar o deseleccionar un icon
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        This_MOD.add_icon(This_MOD.Create_data(event))
    end)

    --- Al seleccionar otro canal
    script.on_event({
        defines.events.on_gui_selection_state_changed
    }, function(event)
        This_MOD.selection_channel(This_MOD.Create_data(event))
    end)

    --- Al hacer clic en algún elemento de la ventana
    script.on_event({
        defines.events.on_gui_click
    }, function(event)
        This_MOD.button_action(This_MOD.Create_data(event))
    end)

    --- Validar el nuevo nombre
    script.on_event({
        defines.events.on_gui_confirmed
    }, function(event)
        This_MOD.validate_channel_name(This_MOD.Create_data(event))
    end)
end

--- Crea y agrupar las variables a usar
function This_MOD.Create_data(event)
    --- Consolidar la información
    local Data = GPrefix.create_data(event or {}, This_MOD)
    if not event then return Data end

    --- Entidad en el event
    if event.entity and event.entity.valid then
        Data.Entity = event.entity
    elseif event.created_entity and event.created_entity.valid then
        Data.Entity = event.created_entity
    end

    --- Lista de los postes
    Data.gForce.Channel = Data.gForce.Channel or {}
    Data.Channel = Data.gForce.Channel

    --- Lista de los transceiver
    Data.gForce.Node = Data.gForce.Node or {}
    Data.Node = Data.gForce.Node

    --- Devolver el consolidado de los datos
    return Data
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Al crear la entidad
function This_MOD.on_entity_created(Data)
    --- Entidad no valida
    if not Data.Entity then return end
    if not string.find(Data.Entity.name, This_MOD.Ref) then return end

    --- Crear la superficie y el canal por defecto
    local Channel = This_MOD.get_channel(Data, This_MOD.Channel_default)

    --- Borrar el nombre adicional de la entidad
    Data.Entity.backer_name = ""

    --- Guardar el canal de la enridad
    Data.Node[Data.Entity.unit_number] = {
        entity = Data.Entity,
        connect = false,
        channel = Channel,
        index = Data.Entity.unit_number,
        red = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true),
        green = Data.Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    }
end

--- Ocultar la superficie de las fuerzas recién creadas
function This_MOD.hide_surface(Data)
    local Surface = This_MOD.get_surface()
    if Surface then
        Data.Event.force.set_surface_hidden(Surface, true)
    end
end

--- Verificar que la entidad tenga energía
function This_MOD.check_power()
    local function action(Data)
        --- Entidad a modificar
        if not Data.Entity then return end
        if not Data.Entity.valid then return end

        --- Renombrar
        local Node = Data.Node[Data.Entity.unit_number]
        local Channel = Node.channel

        if Node.connect then
            --- Desconectar
            Node.connect = false
            Node.red.disconnect_from(Channel.red, defines.wire_origin.script)
            Node.green.disconnect_from(Channel.green, defines.wire_origin.script)
        else
            --- Conectar
            Node.connect = true
            Node.red.connect_to(Channel.red, false, defines.wire_origin.script)
            Node.green.connect_to(Channel.green, false, defines.wire_origin.script)
        end
    end

    --- Variables a usar
    local Data = This_MOD.Create_data()
    local Deleted = {}

    --- Recorrer cada entidad enlistada
    for _, gForce in pairs(Data.gForces) do
        for key, Node in pairs(gForce.Node) do
            if not Node.entity or not Node.entity.valid then
                table.insert(Deleted, key)
                goto JumpNode
            end

            --- En Factorio 2.0 puede ocurrir que la entidad esté
            --- completamente alimentada, pero debido a algunas
            --- peculiaridades del motor el búfer sólo está lleno
            --- al 96%, por ejemplo.

            --- Umbral de activació: 90%
            local Threshold = 0.9

            --- Variables a usar
            local energy = Node.entity.energy
            local buffer = Node.entity.electric_buffer_size
            local power_satisfied = energy >= buffer * Threshold

            --- Acciones
            if Node.connect and not power_satisfied then
                action(This_MOD.Create_data({
                    entity = Node.entity,
                    force = Node.entity.force
                }))
            elseif not Node.connect and power_satisfied then
                action(This_MOD.Create_data({
                    entity = Node.entity,
                    force = Node.entity.force
                }))
            end

            --- Receptor de salto
            :: JumpNode ::
        end

        --- Eliminar a las entidad invalidas
        for _, key in pairs(Deleted) do
            gForce.Node[key] = nil
        end
    end
end

--- Al fusionar dos fuerzas
function This_MOD.forces_merged(Data)
    --- Renombrar
    local Source = Data.gForces[Data.Event.source_index]
    if not Source then return end
    local Destination = This_MOD.Create_data({
        force = Data.Event.destination
    })

    --- Mover los canales
    for index, Channel in pairs(Source.Channel) do
        Destination.Channel[index] = Channel
    end

    --- Mover los nodos
    for index, Node in pairs(Source.Node) do
        Destination.Node[index] = Node
    end

    --- Eliminar la referencia a la fuerza
    Data.gForces[Data.Event.source_index] = nil
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Superficie de los canales
function This_MOD.get_surface()
    --- Devolver la superficie de existir
    if game.surfaces[This_MOD.prefix .. This_MOD.name] then
        return game.surfaces[This_MOD.prefix .. This_MOD.name]
    end

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
end

--- Obtener un canal
function This_MOD.get_channel(Data, channel)
    --- Superficie de los canales
    local Surface = This_MOD.get_surface()

    --- Cargar el poste del canal indicado
    local Channel = GPrefix.get_table(Data.Channel, "name", channel)
    if Channel.name then return Channel end

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
    Data.Channel[Entity.unit_number] = {
        name = channel,
        entity = Entity,
        index = Entity.unit_number,
        red = Entity.get_wire_connector(defines.wire_connector_id.circuit_red, true),
        green = Entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    }

    --- Devolver el canal indicado
    return Data.Channel[Entity.unit_number]
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

---------------------------------------------------------------------------------------------------
--- Desde acá empieza la parte GUI: Esta sección es para cambiar el canal -------------------------
---------------------------------------------------------------------------------------------------

--- Crear o destruir la ventana
function This_MOD.Toggle_window(Data)
    local function Validate_open()
        --- Validación
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if Data.Entity.name ~= This_MOD.NewName then return false end

        --- Por alguna razón algo no se inicializa lo más probable es que
        --- se trate de una entidad heredada ejecute de nuevo los eventos
        --- creados para pasar por el proceso normal de configuración.
        if not Data.Node[Data.Entity.unit_number] then
            This_MOD.on_entity_created({
                entity = Data.Node.entity,
                force = Data.Node.entity.force
            })
        end

        --- Abrir / Cerrar la ventana
        return true
    end
    local function Validate_close()
        if Data.GUI.Action == This_MOD.action.build then return false end
        if not Data.Event.element then return false end
        if Data.Event.element == Data.GUI.frame_main then return true end
        if Data.Event.element ~= Data.GUI.button_exit then return false end
        return true
    end

    local function Build()
        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
        Data.GUI.label_title.caption = { "entity-name." .. This_MOD.NewName }
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del cuerpo para el inventario
        Data.GUI.flow_items = {}
        Data.GUI.flow_items.type = "flow"
        Data.GUI.flow_items.name = "flow_items"
        Data.GUI.flow_items.direction = "vertical"
        Data.GUI.flow_items = Data.GUI.frame_main.add(Data.GUI.flow_items)
        Data.GUI.flow_items.style = Prefix .. "flow_vertival_8"

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_entity = {}
        Data.GUI.frame_entity.type = "frame"
        Data.GUI.frame_entity.name = "frame_entity"
        Data.GUI.frame_entity.direction = "vertical"
        Data.GUI.frame_entity = Data.GUI.flow_items.add(Data.GUI.frame_entity)
        Data.GUI.frame_entity.style = Prefix .. "frame_entity"

        --- Imagen de la entidad
        Data.GUI.entity_preview_entity = {}
        Data.GUI.entity_preview_entity.type = "entity-preview"
        Data.GUI.entity_preview_entity.style = "wide_entity_button"
        Data.GUI.entity_preview_entity = Data.GUI.frame_entity.add(Data.GUI.entity_preview_entity)
        Data.GUI.entity_preview_entity.entity = Data.Entity

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_old_channels = {}
        Data.GUI.frame_old_channels.type = "frame"
        Data.GUI.frame_old_channels.name = "frame_old_channels"
        Data.GUI.frame_old_channels.direction = "horizontal"
        Data.GUI.frame_old_channels = Data.GUI.flow_items.add(Data.GUI.frame_old_channels)
        Data.GUI.frame_old_channels.style = Prefix .. "frame_body"

        --- Barra de movimiento
        Data.GUI.dropdown_channels = {}
        Data.GUI.dropdown_channels.type = "drop-down"
        Data.GUI.dropdown_channels.name = "drop_down_channels"
        Data.GUI.dropdown_channels = Data.GUI.frame_old_channels.add(Data.GUI.dropdown_channels)
        Data.GUI.dropdown_channels.style = Prefix .. "drop_down_channels"

        --- Cargar los canales
        for _, channel in pairs(Data.Channel) do
            Data.GUI.dropdown_channels.add_item(channel.name)
        end
        Data.GUI.dropdown_channels.add_item(This_MOD.New_channel)

        --- Botón para aplicar los cambios
        Data.GUI.button_edit = {}
        Data.GUI.button_edit.type = "sprite-button"
        Data.GUI.button_edit.name = "button_edit"
        Data.GUI.button_edit.sprite = "utility/rename_icon"
        Data.GUI.button_edit.tooltip = { This_MOD.prefix .. "edit-channel" }
        Data.GUI.button_edit = Data.GUI.frame_old_channels.add(Data.GUI.button_edit)
        Data.GUI.button_edit.style = Prefix .. "button_blue"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_confirm"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm.tooltip = { "gui.confirm" }
        Data.GUI.button_confirm = Data.GUI.frame_old_channels.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_new_channels = {}
        Data.GUI.frame_new_channels.type = "frame"
        Data.GUI.frame_new_channels.name = "frame_new_channels"
        Data.GUI.frame_new_channels.direction = "horizontal"
        Data.GUI.frame_new_channels = Data.GUI.flow_items.add(Data.GUI.frame_new_channels)
        Data.GUI.frame_new_channels.style = Prefix .. "frame_body"
        Data.GUI.frame_new_channels.visible = false

        --- Nuevo nombre
        Data.GUI.textfield_new_channel = {}
        Data.GUI.textfield_new_channel.type = "textfield"
        Data.GUI.textfield_new_channel.name = "write-channel"
        Data.GUI.textfield_new_channel.text = "xXx"
        Data.GUI.textfield_new_channel = Data.GUI.frame_new_channels.add(Data.GUI.textfield_new_channel)
        Data.GUI.textfield_new_channel.style = Prefix .. "stretchable_textfield"

        --- Crear la imagen de selección
        Data.GUI.button_icon = {}
        Data.GUI.button_icon.type = "choose-elem-button"
        Data.GUI.button_icon.name = "button_icon"
        Data.GUI.button_icon.elem_type = "signal"
        Data.GUI.button_icon.signal = { type = "virtual", name = This_MOD.prefix .. "icon" }
        Data.GUI.button_icon = Data.GUI.frame_new_channels.add(Data.GUI.button_icon)
        Data.GUI.button_icon.style = Prefix .. "button"

        --- Botón para cancelar los cambios
        Data.GUI.button_cancel = {}
        Data.GUI.button_cancel.type = "sprite-button"
        Data.GUI.button_cancel.name = "button_cancel"
        Data.GUI.button_cancel.sprite = "utility/close_fat"
        Data.GUI.button_cancel.tooltip = { "gui-mod-settings.cancel" }
        Data.GUI.button_cancel = Data.GUI.frame_new_channels.add(Data.GUI.button_cancel)
        Data.GUI.button_cancel.style = Prefix .. "button_red"

        --- Botón para aplicar los cambios
        Data.GUI.button_green = {}
        Data.GUI.button_green.type = "sprite-button"
        Data.GUI.button_green.name = "button_green"
        Data.GUI.button_green.sprite = "utility/check_mark_white"
        Data.GUI.button_green.tooltip = { "gui.confirm" }
        Data.GUI.button_green = Data.GUI.frame_new_channels.add(Data.GUI.button_green)
        Data.GUI.button_green.style = Prefix .. "button_green"
    end
    local function Destroy()
        Data.GUI.frame_main.destroy()
        Data.GPlayer.GUI = {}
        Data.GUI = Data.GPlayer.GUI
        Data.Player.opened = nil
    end

    local function Info()
        --- Valores de la entidad
        Data.GUI.Node = Data.Node[Data.Entity.unit_number]

        --- Selección inicial
        Data.GUI.Pos_start = 0
        for index, _ in pairs(Data.Channel) do
            Data.GUI.Pos_start = Data.GUI.Pos_start + 1
            if index == Data.GUI.Node.channel.index then
                break
            end
        end

        --- Selección actual
        Data.GUI.Pos = Data.GUI.Pos_start
    end

    --- Acción a ejecutar
    if Data.GUI.frame_main and Validate_close() then
        Destroy()
    elseif not Data.GUI.frame_main and Validate_open() then
        Data.GUI.Action = This_MOD.action.build
        Build()
        Info()
        Data.GUI.dropdown_channels.selected_index = Data.GUI.Pos
        This_MOD.selection_channel(Data)
        Data.GUI.Action = This_MOD.action.none
    end
end

--- Al seleccionar un canal
function This_MOD.selection_channel(Data)
    --- Validación
    if not Data.GUI.frame_main then return end
    if not Data.GUI.dropdown_channels then return end
    local element = Data.Event.element
    local dropdown_channels = Data.GUI.dropdown_channels
    if element and element ~= dropdown_channels then return end

    --- Selección actul
    local selected_index = dropdown_channels.selected_index
    if selected_index == 0 then return end

    --- No hay cambio de canal
    Data.GUI.button_confirm.enabled = selected_index ~= Data.GUI.Pos_start

    --- Se seleccionó un canal existente
    Data.GUI.button_edit.enabled = true

    --- Se quiere crear un nuevo canal
    if selected_index == #dropdown_channels.items then
        Data.GUI.Action = This_MOD.action.new_channel
        This_MOD.show_new_channel(Data)
        return
    end

    --- Actualizar la selección
    Data.GUI.Pos = selected_index

    --- De volvió al canal por defecto
    if selected_index == 1 then
        Data.GUI.button_edit.enabled = false
        return
    end
end

--- Acciones de los botones
function This_MOD.button_action(Data)
    --- Variables a usar
    local Flag = false
    local EventID = 0

    --- Validar el elemento
    EventID = defines.events.on_gui_click
    Flag = Data.Event.name == EventID
    if not Flag then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cerrar la ventana
    Flag = Data.Event.element == Data.GUI.button_exit
    if Flag then
        This_MOD.Toggle_window(Data)
        return
    end

    --- Cancelar el cambio de nombre o el nuevo canal
    Flag = Data.Event.element == Data.GUI.button_cancel
    if Flag then
        Data.Event.element = Data.GUI.dropdown_channels
        This_MOD.show_old_channel(Data)
        return
    end

    --- Cambiar el nombre de un canal o agregar un nuevo canal
    Flag = false or Data.GUI.Action == This_MOD.action.edit
    Flag = Flag or Data.GUI.Action == This_MOD.action.new_channel
    Flag = Flag and Data.Event.element == Data.GUI.button_green
    if Flag then
        This_MOD.validate_channel_name(Data)
        return
    end

    --- Editar el nombre del canal seleccionado
    Flag = Data.Event.element == Data.GUI.button_edit
    if Flag then
        Data.GUI.Action = This_MOD.action.edit
        This_MOD.show_new_channel(Data)
        return
    end

    --- Cambiar el canal
    Flag = Data.Event.element == Data.GUI.button_confirm
    if Flag then
        This_MOD.set_channel(Data.GUI.Node, This_MOD.get_channel_pos(Data))
        Data.Event.element = Data.GUI.button_exit
        This_MOD.Toggle_window(Data)
        Data.Player.play_sound({ path = "entity-open/constant-combinator" })
        return
    end
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Seleccionar un nuevo objeto
function This_MOD.add_icon(Data)
    if not Data.GUI.button_icon then return end

    --- Cargar la selección
    local Select = Data.GUI.button_icon.elem_value

    --- Restaurar el icono
    Data.GUI.button_icon.elem_value = {
        type = "virtual",
        name = This_MOD.prefix .. "icon"
    }

    --- Se intentó limpiar el icono
    if not Select then return end

    --- Convertir seleccion en texto
    local function signal_to_rich_text(select)
        local type = ""

        if not select.type then
            if prototypes.entity[select.name] then
                type = "entity"
            elseif prototypes.recipe[select.name] then
                type = "recipe"
            elseif prototypes.fluid[select.name] then
                type = "fluid"
            elseif prototypes.item[select.name] then
                type = "item"
            end
        end

        if select.type then
            type = select.type
            if select.type == "virtual" then
                type = type .. "-signal"
            end
        end

        return "[img=" .. type .. "." .. select.name .. "]"
    end

    --- Agregar la imagen seleccionada
    local text = Data.GUI.textfield_new_channel.text
    text = text .. signal_to_rich_text(Select)
    Data.GUI.textfield_new_channel.text = text
    Data.GUI.textfield_new_channel.focus()
end

--- Validar el nombre del canal
function This_MOD.validate_channel_name(Data)
    --- Texto a evaluar
    local textfield = Data.GUI.textfield_new_channel

    --- Nombre invalido
    if textfield.text == "" then
        textfield.focus()
        return
    end

    --- Nuevo canal
    local result = GPrefix.get_table(Data.Channel, "name", textfield.text)

    --- Nombre ocupado
    if result.name then
        textfield.focus()
        return
    end

    --- Crear un nuevo canal
    if Data.GUI.Action == This_MOD.action.new_channel then
        --- Crear el nuevo canal
        Data.GUI.Pos = GPrefix.get_length(Data.Channel) + 1
        Data.Event.element = Data.GUI.dropdown_channels
        This_MOD.get_channel(Data, textfield.text)

        --- Agregar el nuevo canal
        Data.GUI.dropdown_channels.add_item(textfield.text, Data.GUI.Pos)
    end

    --- Cambiar el nombre de un canal
    if Data.GUI.Action == This_MOD.action.edit then
        --- Buscar el canal
        local Channel = This_MOD.get_channel_pos(Data)

        --- Actualizar el nombre
        Channel.name = textfield.text
        Data.GUI.dropdown_channels.set_item(Data.GUI.Pos, textfield.text)
    end

    --- Cambiar el canal
    This_MOD.set_channel(Data.GUI.Node, This_MOD.get_channel_pos(Data))

    --- Cerrar la ventana
    Data.Event.element = Data.GUI.button_exit
    This_MOD.Toggle_window(Data)
    Data.Player.play_sound({ path = "entity-open/constant-combinator" })
end

--- Obtener el canal seleccionado
function This_MOD.get_channel_pos(Data)
    local Pos = 0
    for _, channel in pairs(Data.Channel) do
        Pos = Pos + 1
        if Pos == Data.GUI.Pos then
            return channel
        end
    end
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Mostrar el cuerpo para seleccionar un canal
function This_MOD.show_old_channel(Data)
    --- Cambiar de frame
    Data.GUI.frame_new_channels.visible = false
    Data.GUI.frame_old_channels.visible = true

    --- Enfocar la selección
    Data.GUI.dropdown_channels.selected_index = Data.GUI.Pos
    This_MOD.selection_channel(Data)
end

--- Mostrar el cuerpo para crear un nuevo canal
function This_MOD.show_new_channel(Data)
    --- Cambiar de frame
    Data.GUI.frame_old_channels.visible = false
    Data.GUI.frame_new_channels.visible = true

    --- Configuración para un nuevo canal
    if Data.GUI.Action == This_MOD.action.new_channel then
        Data.GUI.Action = This_MOD.action.new_channel
        Data.GUI.textfield_new_channel.text = ""
    end

    --- Configuración para un nuevo nombre
    if Data.GUI.Action == This_MOD.action.edit then
        local dropdown = Data.GUI.dropdown_channels
        local textfield = Data.GUI.textfield_new_channel
        textfield.text = dropdown.get_item(Data.GUI.Pos)
    end

    --- Enfocar nombre
    Data.GUI.textfield_new_channel.focus()
end

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
