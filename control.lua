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

function This_MOD.create_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.Entity then return end
    if not GMOD.has_id(Data.Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Canal por defecto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if #Data.channels == 0 then
        local Entity = Data.Entity
        Data.Entity = { link_id = 0 }
        This_MOD.get_channel(Data)
        Data.Entity = Entity
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Canal del cofre
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.get_channel(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_main then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if not GMOD.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Data.GUI.frame_main then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if not GMOD.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Garantizar la creación del canal
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.create_entity(Data)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function gui_destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main.destroy()
        Data.gPlayer.GUI = {}
        Data.GUI = Data.gPlayer.GUI

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function gui_build()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar los guiones del nombre
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el cuadro principal
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main = {}
        Data.GUI.frame_main.type = "frame"
        Data.GUI.frame_main.name = "frame_main"
        Data.GUI.frame_main.direction = "vertical"
        Data.GUI.frame_main.anchor = {}
        Data.GUI.frame_main.anchor.gui = defines.relative_gui_type.linked_container_gui
        Data.GUI.frame_main.anchor.position = defines.relative_gui_position.top
        Data.GUI.frame_main = Data.Player.gui.relative.add(Data.GUI.frame_main)
        Data.GUI.frame_main.style = "frame"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Contenedor para el actual canal
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_old_channel = {}
        Data.GUI.frame_old_channel.type = "frame"
        Data.GUI.frame_old_channel.name = "frame_old_channel"
        Data.GUI.frame_old_channel.direction = "horizontal"
        Data.GUI.frame_old_channel = Data.GUI.frame_main.add(Data.GUI.frame_old_channel)
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Contenedor para el nuevo canal
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_new_channel = {}
        Data.GUI.frame_new_channel.type = "frame"
        Data.GUI.frame_new_channel.name = "frame_new_channels"
        Data.GUI.frame_new_channel.direction = "horizontal"
        Data.GUI.frame_new_channel = Data.GUI.frame_main.add(Data.GUI.frame_new_channel)
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
        Data.GUI.button_icon.signal = { type = "virtual", name = GMOD.name .. "-icon" }
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar los canales
    local function load_channels()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cargar los canales
        local Dropdown = Data.GUI.dropdown_channels
        for _, channel in pairs(Data.channels) do
            if type(channel) == "table" then
                Dropdown.add_item(channel.name)
            end
        end
        Dropdown.add_item(This_MOD.new_channel)

        --- Seleccionar el canal actual
        Dropdown.selected_index = This_MOD.get_channel(Data).index

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        gui_destroy()
    elseif validate_open() then
        gui_build()
        load_channels()
        Data.GUI.entity = Data.Entity
    end
end

function This_MOD.selection_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI.frame_main then return end
    local Element = Data.Event.element
    local Dropdown = Data.GUI.dropdown_channels
    if Element and Element ~= Dropdown then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Selección actual
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Se quiere crear un nuevo canal
    if Dropdown.selected_index == #Dropdown.items then
        Data.GUI.action = This_MOD.action.new_channel
        This_MOD.show_new_channel(Data)
        This_MOD.sound_channel_selected(Data)
        return
    end

    --- Cambiar el canal del cofre
    Data.Entity.link_id = Data.channels[Dropdown.selected_index].link_id
    This_MOD.sound_channel_changed(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.button_action(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI.frame_main then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acción a ejecutar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cancelar el cambio de nombre o el nuevo canal
    if Data.Event.element == Data.GUI.button_cancel then
        This_MOD.show_old_channel(Data)
        return
    end

    --- Cambiar el nombre de un canal o agregar un nuevo canal
    if Data.Event.element == Data.GUI.button_confirm then
        This_MOD.validate_channel_name(Data)
        return
    end

    --- Editar el nombre del canal seleccionado
    if Data.Event.element == Data.GUI.button_edit then
        Data.GUI.action = This_MOD.action.edit
        This_MOD.show_new_channel(Data)
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.add_icon(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.Event.element then return end
    if Data.Event.element ~= Data.GUI.button_icon then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar la selección
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la selección
    local Select = Data.GUI.button_icon.elem_value

    --- Restaurar el icono
    Data.GUI.button_icon.elem_value = {
        type = "virtual",
        name = GMOD.name .. "-icon"
    }

    --- Renombrar
    local Textbox = Data.GUI.textfield_new_channel

    --- Se intentó limpiar el icono
    if not Select then
        Textbox.focus()
        return
    end

    --- Agregar la imagen seleccionada
    local Text = Textbox.text
    Text = Text .. (function()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variables a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local type = ""

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Detectar el tipo de icono
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Select.type then
            if prototypes.entity[Select.name] then
                type = "entity"
            elseif prototypes.recipe[Select.name] then
                type = "recipe"
            elseif prototypes.fluid[Select.name] then
                type = "fluid"
            elseif prototypes.item[Select.name] then
                type = "item"
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Ajustar el tipo de icono
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Select.type then
            type = Select.type
            if Select.type == "virtual" then
                type = type .. "-signal"
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Devolver el icon en formato de texto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return "[img=" .. type .. "." .. Select.name .. "]"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end)()
    Textbox.text = Text
    Textbox.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.validate_channel_name(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Textbox = Data.GUI.textfield_new_channel
    local Dropdown = Data.GUI.dropdown_channels
    local Index = Dropdown.selected_index

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Flag = Textbox.text == ""
    Flag = Flag or GMOD.get_tables(Data.channels, "name", Textbox.text)
    if Flag then
        This_MOD.sound_bad(Data)
        Textbox.focus()
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acción a ejecutar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        --- Buscar un espacio libre
        while GMOD.get_tables(Data.channels, "link_id", Data.last_link_id) do
            Data.last_link_id = Data.last_link_id + 1
        end

        --- Agregar el nuevo nombre a la GUI
        Dropdown.add_item(Textbox.text, Index)

        --- Cambiar el indicador
        Data.Entity.link_id = Data.last_link_id

        --- Efecto de sonido
        This_MOD.sound_channel_changed(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar el nombre de un canal
    if Data.GUI.action == This_MOD.action.edit then
        --- Cambiar el nombre en la GUI
        Dropdown.remove_item(Index)
        Dropdown.add_item(Textbox.text, Index)

        --- Efecto de sonido
        This_MOD.sound_good(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Actualizar el nombre
    This_MOD.get_channel(Data).name = Textbox.text
    This_MOD.show_old_channel(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.show_old_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar de frame
    Data.GUI.frame_new_channel.visible = false
    Data.GUI.frame_old_channel.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Enfocar la selección
    Data.GUI.dropdown_channels.selected_index = This_MOD.get_channel(Data).index
    This_MOD.selection_channel(Data)
    Data.GUI.action = nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.show_new_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar de frame
    Data.GUI.frame_old_channel.visible = false
    Data.GUI.frame_new_channel.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Configuración para un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        Data.GUI.action = This_MOD.action.new_channel
        Data.GUI.textfield_new_channel.text = ""
    end

    --- Configuración para editar el nombre
    if Data.GUI.action == This_MOD.action.edit then
        local Dropdown = Data.GUI.dropdown_channels
        local Textbox = Data.GUI.textfield_new_channel
        Textbox.text = Data.channels[Dropdown.selected_index].name
    end

    --- Enfocar nombre
    Data.GUI.textfield_new_channel.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

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
    --- Crear la superficie si no existe
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
