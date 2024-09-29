return {

    saveToDatabase = true,
    dropCheaters = true, -- If cheaters should be kicked.


    craftingTables = {
        ['weap_craftingtable'] = { -- TableType, use the name of the table item
            
            model = 'gr_prop_gr_bench_04b',

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
                    increment = 1

                }
            },
        },
        ['item_craftingtable'] = { -- TableType, use the name of the table item
            
            model = 'gr_prop_gr_bench_02a',

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
                    blueprintRequired = false,
                    craftMultiple = false

                },
            },
        }
    },

    permCraftingTables = { -- Set to false if you dont want any tables.
        ['weap_craftingtable'] = vec4(1753.4373, 2648.1467, 44.5649, 134.0989)
    },

    interaction = { 
        targetLabel = 'Open Crafting',
        deleteTargetLabel = 'Pickup Table',
        targetradius = 3.0, 
        targeticon = 'fas fa-screwdriver-wrench', -- https://fontawesome.com/icons
        deleteTargeticon = 'fas fa-x', -- https://fontawesome.com/icons
        targetdistance = 2.0,
    },
    
}