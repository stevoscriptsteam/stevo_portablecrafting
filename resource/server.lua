if not lib.checkDependency('stevo_lib', '1.7.2') then error('stevo_lib 1.7.2 required for stevo_portablecrafting') end
lib.versionCheck('stevoscriptsteam/stevo_portablecrafting')
lib.locale()

local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local CraftingTables = {}


local function saveTableToDatabase(table)
    if config.saveToDatabase then 
        MySQL.query('REPLACE INTO `stevo_portable_crafting` (tableid, tabletype, owner, name, coords, heading) VALUES (?, ?, ?, ?, ?, ?)', {
            table.id,table.type, table.owner, table.name, json.encode(table.coords), table.heading
        })
    end
end

local function deleteTableFromDatabase(tableId)
    if config.saveToDatabase then 
        MySQL.query('DELETE FROM `stevo_portable_crafting` WHERE tableid = ?', { tableId })
    end
end

local function generateUniqueTableId()
    local id
    repeat
        id = math.random(100000, 999999)
    until not CraftingTables[id] 
    return id
end


lib.callback.register('stevo_portablecrafting:createTable', function(source, coords, heading, tabletype)
    local identifier = stevo_lib.GetIdentifier(source)
    local name = stevo_lib.GetName(source)

    stevo_lib.RemoveItem(source, tabletype, 1)

    local table = {
        name = locale('menu.tableTitle', name),
        type = tabletype,
        owner = identifier,
        coords = coords,
        heading = heading,
        id = generateUniqueTableId(),
        permanent = false
    }

    CraftingTables[table.id] = table
    saveTableToDatabase(table)

    TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'create', table.id, table)
end)

lib.callback.register('stevo_portablecrafting:pickupTable', function(source, tableId, tableType)
    if CraftingTables[tableId] ~= nil then 
        stevo_lib.AddItem(source, tableType, 1)
        deleteTableFromDatabase(tableId)
        CraftingTables[tableId] = nil

        TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'delete', tableId, false)
        return true
    else
        return false 
    end
end)

lib.callback.register('stevo_portablecrafting:loadTables', function(source)
    return CraftingTables
end)

lib.callback.register('stevo_portablecrafting:craftItem', function(source, itemName, amount, table)

    if not config.craftingTables[table.type].craftables[itemName] then 
        return locale('notify.missingItems'), 'error'
    end

    local item = config.craftingTables[table.type].craftables[itemName]

    if amount > 1 and not item.craftMultiple then 
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)

        lib.print.info(('User: %s (%s) tried to exploit stevo_portablecrafting'):format(name, identifier))

        if config.dropCheaters then 
            DropPlayer(source, 'Trying to exploit stevo_portablecrafting')
        end

        return locale('notify.missingItems'), 'error'
    end

    if item.blueprintRequired then 
        local hasItem = stevo_lib.HasItem(source, item.blueprintRequired)

        if not hasItem or hasItem < 1 then 
            return locale('notify.missingBlueprint', item.blueprintRequired_label), 'error'
        end
    end

    local hasItems = true 
    for i, item in pairs(item.requiredItems) do 
        local hasItem = stevo_lib.HasItem(source, item.item)
        local required = item.amount*amount
        if hasItem < required then 
            hasItems = false 
            break 
        end
    end

    if not hasItems then return locale('notify.missingItems'), 'error' end

    for i, item in pairs(item.requiredItems) do 
        local newAmount = item.amount*amount
        stevo_lib.RemoveItem(source, item.item, newAmount)
    end
    
    stevo_lib.AddItem(source, itemName, amount)
    return locale('notify.craftedItem', item.name), 'success'
end)

CreateThread(function()
    if config.saveToDatabase then 
        local success, _ = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_portable_crafting')

        if not success then
            MySQL.query([[CREATE TABLE IF NOT EXISTS `stevo_portable_crafting` (
                `tableid` INT NOT NULL,
                `tabletype` TEXT NOT NULL,
                `owner` VARCHAR(50) NOT NULL,
                `name` VARCHAR(50) NOT NULL,
                `coords` TEXT NOT NULL,
                `heading` TEXT NOT NULL,
                PRIMARY KEY (`tableid`)
            )]])
            lib.print.info('[Stevo Scripts] Added column `tabletype` to stevo_portable_crafting')
        end

        local tables = MySQL.query.await('SELECT * FROM `stevo_portable_crafting`', {})
        
        if tables then
            for i = 1, #tables do
                local row = tables[i]
                local coords = json.decode(row.coords)
                local heading = json.decode(row.heading)
                local groups = config.craftingTables[row.tabletype].groups

                local table = {
                    id = row.tableid,
                    type = row.tabletype,
                    name = row.name,
                    owner = row.owner,
                    groups = groups,
                    coords = vec3(coords.x, coords.y, coords.z),
                    heading = heading,
                    permanent = false
                }

                CraftingTables[table.id] = table
            end
        end

        if config.permCraftingTables then
            for _, permTable in pairs(config.permCraftingTables) do

                local table = {
                    id = generateUniqueTableId(),
                    type = permTable.type,
                    name = locale("menu.permTableTitle"),
                    owner = false,
                    groups = permTable.groups,
                    coords = vec3(permTable.coords.x, permTable.coords.y, permTable.coords.z),
                    heading = permTable.coords.w,
                    permanent = true
                }

                CraftingTables[table.id] = table
            end
        end
    end

    for tabletype, table in pairs(config.craftingTables) do
        stevo_lib.RegisterUsableItem(tabletype, function(source)
            TriggerClientEvent('stevo_portablecrafting:itemUsed', source, tabletype)
        end)
    end
end)
