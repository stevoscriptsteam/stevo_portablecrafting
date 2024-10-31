return {

    saveToDatabase = true,
    dropCheaters = true, -- If cheaters should be kicked.
    progressCircle = false, -- If lib progressCircle should be used instead of progressBar

    pickupPlaceDuration = 1, -- Seconds it takes to pickup/place the tables
    pickupPlaceProp = true, -- If a prop should display when placing/picking up tables

    craftingTables = {
        ['weap_craftingtable'] = { -- TableType, use the name of the table item
            
            model = 'gr_prop_gr_bench_04b',
            groups = {'ambulance'}, -- Gang or job roles required to open.

            craftables = {
                ['WEAPON_PISTOL'] = {
                    model = 'w_pi_pistol', 
                    name = 'Pistol',
                    icon = 'gun',
                    iconColor = '#339af0',
                    description = 'A compact, semi-automatic handgun designed for personal defense and close-quarters combat.',
                    
                    requiredItems = {
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Copper', item = 'copper', amount = 1}
                    },
                    blueprintRequired = 'stevo_exampleblueprint', -- Set to false for no blueprint requirement.
                    blueprintRequired_label = 'Blue Print Example',
                    craftMultiple = true,
                    craftMax = 10,
                    craftMin = 1,
                    increment = 1,
                    timeToCraft = 2000

                }
            },
        },
        ['item_craftingtable'] = { -- TableType, use the name of the table item
            
            model = 'gr_prop_gr_bench_02a',
            groups = false, 

            craftables = {
                ['veh_toolbox'] = {
                    model = 'v_ind_cs_toolbox4', 
                    name = 'Toolbox',
                    icon = 'toolbox',
                    iconColor = '#339af0',
                    description = 'A sturdy, portable container for storing and organizing tools. Ideal for mechanics, craftsmen, and DIY enthusiasts.',
                    
                    requiredItems = {
                        {label = 'Plastic', item = 'plastic', amount = 1},
                        {label = 'Steel', item = 'steel', amount = 1}
                    },
                    timeToCraft = 2000,
                    blueprintRequired = false,
                    craftMultiple = false

                },
                ['laptop'] = {
                    model = 'ex_prop_ex_laptop_01a', 
                    name = 'Laptop',
                    icon = 'laptop',
                    iconColor = '#339af0',
                    description = 'A high-performance laptop equipped with the latest technology, perfect for work, gaming, and browsing. Lightweight and portable for on-the-go use.',
                    
                    requiredItems = {
                        {label = 'Plastic', item = 'plastic', amount = 1},
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Iron', item = 'iron', amount = 1}
                    },
                    timeToCraft = 2000,
                    minigame = {{'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}},
                    blueprintRequired = false,
                    craftMultiple = false

                },
            },
        }
    },

    permCraftingTables = { -- Set to false if you dont want any tables.
        {
            type = 'item_craftingtable', 
            coords = vec4(-260.4243, 6313.0981, 36.6173, 131.9714),
            groups = {'ambulance'}, -- Gang or job roles required to open.
        },
        {
            type = 'item_craftingtable', 
            coords = vec4(-264.4575, 6317.9434, 36.6173, 134.8024)
        }
    },

    interaction = { 
        openCraftingIcon = 'fas fa-screwdriver-wrench', -- https://fontawesome.com/icons
        pickupTableOption = 'fas fa-x', -- https://fontawesome.com/icons
        interactDistance = 2.0,
    },

    skillCheck = function(data)
        return lib.skillCheck(data[1])
    end,
    
}