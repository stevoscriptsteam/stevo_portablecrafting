local Config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local CRAFTING_TABLES = {}

local function saveTableToDatabase(table)
    if Config.saveToDatabase then 
        MySQL.query('REPLACE INTO `stevo_portable_crafting` (tableid, owner, name, coords, heading) VALUES (?, ?, ?, ?, ?)', {
            table.id, table.owner, table.name, json.encode(table.coords), table.heading
        })
    end
end

local function deleteTableFromDatabase(tableId)
    if Config.saveToDatabase then 
        MySQL.query('DELETE FROM `stevo_portable_crafting` WHERE tableid = ?', { tableId })
    end
end

lib.callback.register('stevo_portablecrafting:createTable', function(source, coords, heading)
    local identifier = stevo_lib.GetIdentifier(source)
    local name = stevo_lib.GetName(source)

    stevo_lib.RemoveItem(source, Config.craftingTable.item, 1)

    local table = {
        name = name.. "'s Crafting Table",
        owner = identifier,
        coords = coords,
        heading = heading,
        id = math.random(100000, 999999),
    }

    CRAFTING_TABLES[table.id] = table
    saveTableToDatabase(table)

    TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'create', CRAFTING_TABLES, table)
end)

lib.callback.register('stevo_portablecrafting:pickupTable', function(source, tableId)
    if CRAFTING_TABLES[tableId] ~= nil then 
        stevo_lib.AddItem(source, Config.craftingTable.item, 1)
        deleteTableFromDatabase(tableId)
        CRAFTING_TABLES[tableId] = nil
        TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'delete', CRAFTING_TABLES, tableId)
        return true
    else
        return false 
    end
end)

lib.callback.register('stevo_portablecrafting:loadTables', function(source)
    return CRAFTING_TABLES
end)

lib.callback.register('stevo_portablecrafting:craftItem', function(source, itemName, item)
    if item.required_blueprint then 
        local hasItem = stevo_lib.HasItem(source, item.required_blueprint)
        if hasItem < 1 then 
            return 1
        end
    end

    local hasItems = true 
    for i, item in pairs(item.required_items) do 
        local hasItem = stevo_lib.HasItem(source, item.item)
        if hasItem < item.amount then 
            hasItems = false 
            break 
        end
    end

    if not hasItems then return 2 end

    for i, item in pairs(item.required_items) do 
        stevo_lib.RemoveItem(source, item.item, item.amount)
    end
    
    stevo_lib.AddItem(source, itemName, 1)
    return item.name
end)

stevo_lib.RegisterUsableItem(Config.craftingTable.item, function(source)
    TriggerClientEvent('stevo_portable_crafting', source)
end)

CreateThread(function()
    if Config.saveToDatabase then 
        local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_portable_crafting')

        if not success then
            MySQL.query([[CREATE TABLE IF NOT EXISTS `stevo_portable_crafting` (
                `tableid` INT NOT NULL,
                `owner` VARCHAR(50) NOT NULL,
                `name` VARCHAR(50) NOT NULL,
                `coords` TEXT NOT NULL,
                `heading` FLOAT NOT NULL,
                PRIMARY KEY (`tableid`)
            )]])
            print('[Stevo Scripts] Deployed database table for stevo_portable_crafting')
        end

        local tables = MySQL.query.await('SELECT * FROM `stevo_portable_crafting`', {})
        
        if tables then
            for i = 1, #tables do
                local row = tables[i]

                local table = {
                    id = row.tableid,
                    name = row.name,
                    owner = row.owner,
                    coords = json.decode(row.coords),
                    heading = row.heading,
                }

                CRAFTING_TABLES[table.id] = table
            end
        end
    end
end)
