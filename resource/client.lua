if not lib.checkDependency('stevo_lib', '1.6.9') then error('stevo_lib 1.6.9 required for stevo_portablecrafting') end
lib.locale()


local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local PLACING_TABLE = false
local TABLE_POINTS = {}
local CURRENT_TABLE, CRAFTING_OPTIONS, TABLE_CAM, CRAFTABLE_OBJ

local function createTable(object, coords, heading, tabletype)
    DeleteObject(object)

    lib.progressBar({
        duration = 1000,
        label = locale('progress.placing_table'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true
        },
        anim = {
            dict = "pickup_object",
            clip = "pickup_low"
        },
        prop = {
            model = `prop_box_guncase_01a`,
            pos = vec3(0.12, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
            bone = 57005,
        },
    })

    
    lib.callback.await('stevo_portablecrafting:createTable', false, coords, heading, tabletype)

    stevo_lib.Notify(locale('placed_crafting_table'), 'info', 5000)
end

local function placeTable(tabletype)

    if PLACING_TABLE then
        stevo_lib.Notify('Already placing a table', 'error', 5000)
        return
    end

    local tableConfig = config.craftingTables[tabletype]

    lib.requestModel(tableConfig.model)
      
    local _, _, endCoords, _ = lib.raycast.cam()
  
    local object = CreateObject(tableConfig.model, endCoords.x, endCoords.y, endCoords.z, false, false, false)
  
    SetEntityAlpha(object, 200)
    DisableCamCollisionForEntity(object)
    SetEntityCollision(object, false, false)
    SetEntityDrawOutlineColor(10, 170, 210, 200)
    SetEntityDrawOutlineShader(0)
    SetEntityDrawOutline(object, true)
    PLACING_TABLE = true
    lib.showTextUI(locale('place_instructions'))
    while true do
        _, _, endCoords, _ = lib.raycast.cam()
        SetEntityCoords(object, endCoords)

        if IsControlJustReleased(0, 241) and not IsControlPressed(0, 21) then
            local objHeading = GetEntityHeading(object)
            SetEntityRotation(object, 0.0, 0.0, objHeading + 10, false, false)
        end

        if IsControlJustReleased(0, 242) and not IsControlPressed(0, 21) then
            local objHeading = GetEntityHeading(object)
            SetEntityRotation(object, 0.0, 0.0, objHeading - 10, false, false)
        end
  
        if IsControlJustPressed(0, 38) then
           break
        end
    end
    PlaceObjectOnGroundProperly(object)
    PLACING_TABLE = false
    lib.hideTextUI()
    createTable(object, GetEntityCoords(object), GetEntityHeading(object), tabletype)
end

function craftItem(data)
    local craftAmount = 1

    DeleteObject(CRAFTABLE_OBJ)

    if data.craftable.craftMultiple then 
        local input = lib.inputDialog(locale("dialog.amount_title"), {
            {type = 'slider', label = locale("dialog.amount_label"), required = true, min = data.craftable.craftMin, max = data.craftable.craftMax},
        })
        if not input then stevo_lib.Notify('Cancelled Input', 'info', 3000) return lib.showContext('stevo_portablecrafting') end
        
        craftAmount = input[1]
    end
    local craftItem = lib.callback.await('stevo_portablecrafting:craftItem', false, data.tabletype, data.item, data.craftable, craftAmount)

    if craftItem == 1 then 

        stevo_lib.Notify(locale('no_blueprint', data.craftable.blueprintRequired_label), 'error', 5000)
    elseif craftItem == 2 then 
        stevo_lib.Notify(locale('missing_requiredItems'), 'error', 5000)
    else
        stevo_lib.Notify(locale('crafted_item', craftItem), 'info', 5000)
    end

    lib.showContext('stevo_portablecrafting')
end

function pickupTable(entity)

    
    lib.progressBar({
        duration = 1000,
        label = locale('progress.picking_up_table'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true
        },
        anim = {
            dict = "pickup_object",
            clip = "pickup_low"
        },
    })
    
    local pickedupTable = lib.callback.await('stevo_portablecrafting:pickupTable', false, CURRENT_TABLE)

    if pickedupTable then 
        stevo_lib.Notify(locale('pickedup_crafting_table'), 'info', 5000)
    else
        stevo_lib.Notify(locale('failed_to_pickup_crafting_table'), 'info', 5000)
    end
end

function toggleCam(toggle, obj)
    if not toggle then
        RenderScriptCams(false, true, 250, 1, 0)
        DestroyCam(TABLE_CAM, false)
        FreezeEntityPosition(PlayerPedId(), false)
    else
        local coords = GetOffsetFromEntityInWorldCoords(obj, 0, -0.75, 0)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(TABLE_CAM, false)
        FreezeEntityPosition(cache.ped, true)
        TABLE_CAM = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(TABLE_CAM, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(TABLE_CAM, coords.x, coords.y, coords.z + 1.2)
        SetCamRot(TABLE_CAM, 0.0, 0.0, GetEntityHeading(obj))
    end
end

function previewCraftable(data)
    lib.requestModel(data.craftable.model)
    CRAFTABLE_OBJ = CreateObject(data.craftable.model, CURRENT_TABLE.coords.x, CURRENT_TABLE.coords.y, CURRENT_TABLE.coords.z + 1.1, true, false, true)
    SetEntityHeading(CRAFTABLE_OBJ, GetEntityHeading(cache.ped) + 180)
    lib.showContext('stevo_portablecrafting_'..CURRENT_TABLE.type..'_'..data.item)
end

function registerCraftables()
    local options = {}

    for tabletype, tableData in pairs(config.craftingTables) do
        if not options[tabletype] then
            options[tabletype] = {}  
        end
    
        for i, craftable in pairs(tableData.craftables) do 
            local option = {
                title = craftable.name,
                description = craftable.description,
                icon = craftable.icon,
                iconColor = craftable.iconColor,
                args = {craftable = craftable, item = i},
                onSelect = previewCraftable,
            }

            table.insert(options[tabletype], option)
    
            local requiredItems = {}
            for _, item in ipairs(craftable.requiredItems) do
                table.insert(requiredItems, item.amount .. 'x ' .. item.label)
            end
    
            local secondaryOptions = { 
                {
                    title = locale('craftable_requiredItems'),
                    icon = 'info-circle',
                    description = table.concat(requiredItems, ', '),
                },
                {
                    title = 'Craft',
                    arrow = true,
                    args = {tabletype = tabletype, craftable = craftable, item = i},
                    onSelect = craftItem
                }
            }
            
            if craftable.blueprintRequired then 
                local blueprintOption = {
                    title = craftable.blueprintRequired_label,
                    icon = 'book',
                }
                table.insert(secondaryOptions, 1, blueprintOption)
            end
    
            lib.registerContext({
                id =  'stevo_portablecrafting_'..tabletype..'_'..i,
                title = craftable.name,
                menu = 'stevo_portablecrafting',
                onBack = function()
                    DeleteObject(CRAFTABLE_OBJ)
                end,
                canClose = false,
                options = secondaryOptions
            })
    
        end
    end
    
    return options
end


function openCraftingMenu(entity)
    local table = CURRENT_TABLE

    lib.registerContext({
        id =  'stevo_portablecrafting',
        onExit = function()
            toggleCam(false)
        end,
        title = table.name,
        options = CRAFTING_OPTIONS[CURRENT_TABLE.type]
    })

    lib.showContext('stevo_portablecrafting')

    toggleCam(true, entity)
end

function enterTablePoint(self)

    lib.requestModel(self.table_model)
    self.table = CreateObject(self.table_model, self.table_coords, true)
    SetEntityHeading(self.table, self.table_heading)
    FreezeEntityPosition(self.table, true)

    local options = {
        options = not self.table_perm and {
            {
                icon = config.interaction.targeticon,
                label = config.interaction.targetLabel,
                distance = config.interaction.targetdistance,
                num = 1,
                action = openCraftingMenu,
            },
            {
                icon = config.interaction.deleteTargeticon,
                label = config.interaction.deleteTargetLabel,
                num = 2,
                distance = config.interaction.targetdistance,
                action = pickupTable,
            },
        } or  {
            {
                icon = config.interaction.targeticon,
                label = config.interaction.targetLabel,
                distance = config.interaction.targetdistance,
                num = 1,
                action = openCraftingMenu,
            }
        }, 
        distance = 5,
        rotation = vec3(0.0,0.0, 0.0)

    }
    stevo_lib.target.AddTargetEntity(self.table, options)

    CURRENT_TABLE = {
        entity = self.table,
        name = self.table_name,
        coords = self.table_coords,
        id = self.table_id,
        type = self.table_type
    }
end
 
function exitTablePoint(self)
    if CURRENT_TABLE.id == self.table_id then 
        CURRENT_TABLE = {} 
    end
    DeleteEntity(self.table)
end

function nearbyTablePoint(self)

    if self.currentDistance < 2 then 
        CURRENT_TABLE = {
            entity = self.table,
            name = self.table_name,
            coords = self.table_coords,
            id = self.table_id,
            type = self.table_type,
        }
    end
end


function onPlayerLoaded()
    CRAFTING_OPTIONS = registerCraftables()
    local tables = lib.callback.await('stevo_portablecrafting:loadTables', false)
    
    for i, table in pairs(tables) do 
        TABLE_POINTS[table.id] = lib.points.new({
            coords = table.coords,
            distance = 10,
            table_id = table.id,
            table_model = config.craftingTables[table.type].model,
            table_type = table.type,
            table_name = table.name,
            table_coords = table.coords,
            table_heading = table.heading,
            table_perm = table.permanent,
            onEnter = enterTablePoint,
            onExit = exitTablePoint,
            nearby = nearbyTablePoint,
        })
    end
end

RegisterNetEvent('stevo_portable_crafting', function(tabletype)
    if not IsPedInAnyVehicle(PlayerPedId(), true) then
        placeTable(tabletype)
    else
        stevo_lib.Notify(locale('no_placing_in_vehicle'), 'error', 5000)
    end
end)

RegisterNetEvent('stevo_portablecrafting:networkSync', function(action, tables, action_data)
    if action == 'delete' then 
        TABLE_POINTS[action_data]:onExit()
        TABLE_POINTS[action_data]:remove()
    elseif action == 'create' then 
        TABLE_POINTS[action_data.id] = lib.points.new({
            coords = action_data.coords,
            distance = 10,
            table_id = action_data.id,
            table_model = config.craftingTables[action_data.type].model,
            table_type = action_data.type,
            table_name = action_data.name,
            table_coords = vec3(action_data.coords.x, action_data.coords.y, action_data.coords.z),
            table_heading = action_data.heading,
            table_perm = action_data.permanent,
            onEnter = enterTablePoint,
            onExit = exitTablePoint,
            debug = true,
        })
    end
end)

AddEventHandler('stevo_lib:playerLoaded', function()
    onPlayerLoaded()
end)

AddEventHandler('onResourceStop', function(resource)
    if cache.resource ~= resource then return end

    for _, point in pairs(TABLE_POINTS) do
        TABLE_POINTS[_]:onExit()
        TABLE_POINTS[_]:remove()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if cache.resource ~= resource then return end

    onPlayerLoaded()
end)












