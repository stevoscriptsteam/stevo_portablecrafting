if not lib.checkDependency('stevo_lib', '1.6.9') then error('stevo_lib 1.6.9 required for stevo_portablecrafting') end
lib.versionCheck('stevoscriptsteam/stevo_portablecrafting')
lib.locale()

local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local CRAFTING_TABLES = {}


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
    until not CRAFTING_TABLES[id] 
    return id
end


lib.callback.register('stevo_portablecrafting:createTable', function(source, coords, heading, tabletype)
    local identifier = stevo_lib.GetIdentifier(source)
    local name = stevo_lib.GetName(source)

    stevo_lib.RemoveItem(source, tabletype, 1)

    local table = {
        name = locale('menu.crafting_table_header', name),
        type = tabletype,
        owner = identifier,
        coords = coords,
        heading = heading,
        id = generateUniqueTableId(),
        permanent = false
    }

    CRAFTING_TABLES[table.id] = table
    saveTableToDatabase(table)

    TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'create', CRAFTING_TABLES, table)
end)

lib.callback.register('stevo_portablecrafting:pickupTable', function(source, table)
    if CRAFTING_TABLES[table.id] ~= nil then 
        stevo_lib.AddItem(source, table.type, 1)
        deleteTableFromDatabase(table.id)
        CRAFTING_TABLES[table.id] = nil
        TriggerClientEvent('stevo_portablecrafting:networkSync', -1, 'delete', CRAFTING_TABLES, table.id)
        return true
    else
        return false 
    end
end)

lib.callback.register('stevo_portablecrafting:loadTables', function(source)
    return CRAFTING_TABLES
end)

lib.callback.register('stevo_portablecrafting:craftItem', function(source, tabletype, itemName, item, amount)

    if not config.craftingTables[tabletype].craftables[itemName] then 
        return 
    end

    local item = config.craftingTables[tabletype].craftables[itemName]

    if amount > 1 and not item.craftMultiple then 
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)

        lib.print.info(('User: %s (%s) tried to exploit stevo_portablecrafting'):format(name, identifier))

        if config.dropCheaters then 
            DropPlayer(source, 'Trying to exploit stevo_portablecrafting')
        end

        return false
    end

    if item.blueprintRequired then 
        local hasItem = stevo_lib.HasItem(source, item.blueprintRequired)
        if hasItem < 1 then 
            return 1
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

    if not hasItems then return 2 end

    for i, item in pairs(item.requiredItems) do 
        local newAmount = item.amount*amount
        stevo_lib.RemoveItem(source, item.item, newAmount)
    end
    
    stevo_lib.AddItem(source, itemName, amount)
    return item.name
end)

CreateThread(function()
    if config.saveToDatabase then 
        local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_portable_crafting')

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
            lib.print.info('[Stevo Scripts] '..locale('altered_database'))
        else
            local columnExists = MySQL.scalar.await([[
                SELECT COUNT(*) FROM information_schema.COLUMNS 
                WHERE TABLE_NAME = 'stevo_portable_crafting' 
                AND COLUMN_NAME = 'tabletype'
            ]])

            if columnExists == 0 then
                MySQL.query('ALTER TABLE `stevo_portable_crafting` ADD COLUMN `tabletype` TEXT NOT NULL')
                lib.print.info('[Stevo Scripts] '..locale('altered_database'))
            end
        end

        local tables = MySQL.query.await('SELECT * FROM `stevo_portable_crafting`', {})
        
        if tables then
            for i = 1, #tables do
                local row = tables[i]
                local coords = json.decode(row.coords)

                local table = {
                    id = row.tableid,
                    type = row.tabletype,
                    name = row.name,
                    owner = row.owner,
                    coords = vec3(coords.x, coords.y, coords.z),
                    heading = json.decode(row.heading),
                    permanent = false
                }

                CRAFTING_TABLES[table.id] = table
            end
        end

        if config.permCraftingTables then
            for type, coords in pairs(config.permCraftingTables) do

                local table = {
                    id = generateUniqueTableId(),
                    type = type,
                    name = locale("menu.permanent_table_header"),
                    owner = false,
                    coords = vec3(coords.x, coords.y, coords.z),
                    heading = coords.w,
                    permanent = true
                }

                CRAFTING_TABLES[table.id] = table
            end
        end
    end

    for tabletype, table in pairs(config.craftingTables) do
        stevo_lib.RegisterUsableItem(tabletype, function(source)
            TriggerClientEvent('stevo_portable_crafting', source, tabletype)
        end)
    end
end)
