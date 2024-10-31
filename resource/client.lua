if not lib.checkDependency('stevo_lib', '1.7.2') then error('stevo_lib 1.7.2 required for stevo_portablecrafting') end
lib.locale()

local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local progress = config.progressCircle and lib.progressCircle or lib.progressBar
local placingTable, currentlyCrafting, currentCraftingTable = false, false, {}
local TableEntities, CraftingOptions = {}, {}
local TABLE_CAM, craftableEntity

local function createTable(object, coords, heading, tabletype)
    DeleteObject(object)

    progress({
        duration = config.pickupPlaceDuration * 1000,
        label = locale('progress.placingTable'),
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
        prop = config.pickupPlaceProp and {
            model = `prop_box_guncase_01a`,
            pos = vec3(0.12, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
            bone = 57005,
        } or false,
    })

    
    lib.callback.await('stevo_portablecrafting:createTable', false, coords, heading, tabletype)

    stevo_lib.Notify(locale('notify.placedTable'), 'info', 5000)
end

local function placeTable(tabletype)

    if placingTable then
        stevo_lib.Notify(locale("notify.alreadyPlacing"), 'error', 5000)
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

    placingTable = true

    lib.showTextUI(locale('textui.placeInstructions'))

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
    placingTable = false
    lib.hideTextUI()
    createTable(object, GetEntityCoords(object), GetEntityHeading(object), tabletype)
end

function craftItem(data)
    local craftAmount = 1

    DeleteObject(craftableEntity)

    if data.craftable.craftMultiple then 
        local input = lib.inputDialog(locale("dialog.amountTitle"), {
            {type = 'number', label = locale("dialog.amountLabel"), required = true, min = data.craftable.craftMin, max = data.craftable.craftMax},
        })
        if not input then stevo_lib.Notify(locale('notify.cancelledInput'), 'error', 3000) return lib.showContext('stevo_portablecrafting') end
        
        craftAmount = input[1]
    end

    if data.craftable.minigame then 
        local success = config.skillCheck(data.craftable.minigame)

        if not success then 
            stevo_lib.Notify(locale('notify.failedSkillCheck'), "error", 5000)
            return lib.showContext('stevo_portablecrafting')
        end
    end

    if data.craftable.timeToCraft then
        if not progress({
            duration = data.craftable.timeToCraft,
            position = 'bottom',
            label = (locale('progress.craftingItem'):format(data.craftable.name)),
            useWhileDead = false,
            canCancel = false,
            disable = { move = true, car = true, mouse = false, combat = true, },
        }) then    
            return
        end
    end

    local craftItemLocale, craftItem = lib.callback.await('stevo_portablecrafting:craftItem', false, data.item, craftAmount, currentCraftingTable)

    stevo_lib.Notify(craftItemLocale, craftItem, 5000)
    lib.showContext('stevo_portablecrafting')

end

local function pickupTable(tableId, tableType)

    
    progress({
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
    
    local pickedupTable = lib.callback.await('stevo_portablecrafting:pickupTable', false, tableId, tableType)

    if pickedupTable then 
        stevo_lib.Notify(locale('notify.pickedupTable'), 'info', 5000)
    else
        stevo_lib.Notify(locale('notify.failedPlace'), 'error', 5000)
    end
end

function toggleCam(toggle, coords, heading)
    if not toggle then
        
        RenderScriptCams(false, true, 250, 1, 0)
        DestroyCam(TABLE_CAM, false)
        FreezeEntityPosition(cache.ped, false)
    else
        SetEntityLocallyInvisible(cache.ped)
        local coords = GetOffsetFromEntityInWorldCoords(TableEntities[currentCraftingTable.id], 0, -0.75, 0)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(TABLE_CAM, false)
        FreezeEntityPosition(cache.ped, true)
        TABLE_CAM = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(TABLE_CAM, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(TABLE_CAM, coords.x, coords.y, coords.z + 1.2)
        SetCamRot(TABLE_CAM, 0.0, 0.0, heading)
    end
end

function previewCraftable(data)
    lib.requestModel(data.craftable.model)
    craftableEntity = CreateObject(data.craftable.model, currentCraftingTable.coords.x,  currentCraftingTable.coords.y, currentCraftingTable.coords.z + 1.1, true, false, true)
    SetEntityHeading(craftableEntity, GetEntityHeading(cache.ped) + 180)
    lib.showContext('stevo_portablecrafting_'..data.tabletype..'_'..data.item)
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
                args = {craftable = craftable, item = i, tabletype = tabletype},
                onSelect = previewCraftable,
            }

            table.insert(options[tabletype], option)
    
            local requiredItems = {}
            for _, item in ipairs(craftable.requiredItems) do
                table.insert(requiredItems, item.amount .. 'x ' .. item.label)
            end
    
            local secondaryOptions = { 
                {
                    title = locale('menu.requiredItems'),
                    icon = 'info-circle',
                    description = table.concat(requiredItems, ', '),
                },
                {
                    title = locale('menu.craft'),
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
                    DeleteObject(craftableEntity)
                end,
                canClose = false,
                options = secondaryOptions
            })
    
        end
    end
    
    return options
end

local function isAllowed(groups)
    local job, gang = stevo_lib.GetPlayerGroups()
    local groupAuth = false

    for _, group in pairs (groups) do
        
        if group == job then 
            groupAuth = true
        end

        if gang then
            if group == gang then 
                groupAuth = true
            end
        end

    end

    return groupAuth
end

local function openCraftingMenu(table)
    
    if table.groups then 
        if not isAllowed(table.groups) then 
            stevo_lib.Notify(locale("notify.denyJob"), 'error', 5000)
            return 
        end
    elseif config.craftingTables[table.type].groups then 
        if not isAllowed(config.craftingTables[table.type].groups) then 
            stevo_lib.Notify(locale("notify.denyJob"), 'error', 5000)
            return 
        end
    end


    lib.registerContext({
        id =  'stevo_portablecrafting',
        onExit = function()
            currentlyCrafting = false
            currentCraftingTable = {}
            toggleCam(false)
        end,
        title = table.name,
        options = CraftingOptions[table.type]
    })

    lib.showContext('stevo_portablecrafting')
    currentlyCrafting = true

    CreateThread(function()
        while currentlyCrafting do 
            SetEntityLocallyInvisible(cache.ped)
            Wait(0)
        end
    end)

    toggleCam(true, table.coords, table.heading)
end

local function initTable(table)
    local options = {
        options = not table.permanent and {
            {
                name = 'open_table',
                type = "client",
                action = function() 
                    currentCraftingTable = table
                    openCraftingMenu(table) 
                end,
                icon = config.interaction.openCraftingIcon,
                label = locale("target.openCrafting"),
            },
            {
                name = 'pickup_table',
                type = "client",
                action = function() 

                    pickupTable(table.id, table.type) 
                end,
                icon = config.interaction.pickupTableOption,
                label = locale("target.pickupCrafting"),
            } 
        } or {
            {
                name = 'open_table',
                type = "client",
                action = function() 
                    currentCraftingTable = table
                    openCraftingMenu(table) 
                end,
                icon = config.interaction.openCraftingIcon,
                label = locale("target.openCrafting"),
            }
        },
        distance = config.interaction.interactDistance,
        rotation = 45
    }
    stevo_lib.target.AddBoxZone('stevoportablecrafting'..table.id, vec3(table.coords.x, table.coords.y, table.coords.z), vec3(3, 3, 3), options)  


    local tableModel = config.craftingTables[table.type].model

    lib.requestModel(tableModel)
    TableEntities[table.id] = CreateObject(tableModel, table.coords.x, table.coords.y, table.coords.z, false)
    SetEntityHeading(TableEntities[table.id], table.heading)
    FreezeEntityPosition(TableEntities[table.id], true)
    SetModelAsNoLongerNeeded(tableModel)
end

local function onPlayerLoaded()
    CraftingOptions = registerCraftables()
    local tables = lib.callback.await('stevo_portablecrafting:loadTables', false)
    

    for i, table in pairs(tables) do 
        initTable(table)
    end
end

RegisterNetEvent('stevo_portablecrafting:itemUsed', function(tabletype)
    if cache.vehicle then
        return stevo_lib.Notify(locale('notify.placeInVehicle'), 'error', 5000)
    end
        
    placeTable(tabletype)
end)

RegisterNetEvent('stevo_portablecrafting:networkSync', function(action, tableId, table)
    if action == 'delete' then 
        stevo_lib.target.RemoveZone('stevoportablecrafting'..tableId)

        local tableEntity = TableEntities[tableId]

        if DoesEntityExist(tableEntity) then
            DeleteEntity(tableEntity)
        end
    elseif action == 'create' then 
        initTable(table)
    end
end)

AddEventHandler('stevo_lib:playerLoaded', function()
    onPlayerLoaded()
end)

AddEventHandler('onResourceStop', function(resource)
    if cache.resource ~= resource then return end

    for entityId, entity in pairs(TableEntities) do

        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        stevo_lib.target.RemoveZone('stevoportablecrafting'..entityId)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if cache.resource ~= resource then return end

    onPlayerLoaded()
end)












