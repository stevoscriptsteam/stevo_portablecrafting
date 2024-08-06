return {

    saveToDatabase = true,


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
                    
                    required_items = {
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Copper', item = 'copper', amount = 1}
                    },
                    required_blueprint = 'stevo_exampleblueprint', -- Set to false for no blueprint requirement.
                    required_blueprint_label = 'Blue Print Example',

                },
                ['WEAPON_CARBINERIFLE'] = {
                    model = 'w_ar_carbinerifle', 

                    name = 'Carbine Rifle',     
                    icon = 'gun',  
                    iconColor = '#339af0',
                    description = 'A versatile, automatic or semi-automatic firearm engineered for rapid-fire and high accuracy at mid range.',

                    required_items = {
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Copper', item = 'copper', amount = 1}
                    },
                    required_blueprint = false
                },
                ['WEAPON_PUMPSHOTGUN'] = {
                    model = 'w_sg_pumpshotgun', 

                    name = 'Pump Shotgun',     
                    icon = 'gun',  
                    iconColor = '#339af0',
                    description = 'A versatile, automatic or semi-automatic firearm engineered for rapid-fire and high accuracy at mid range.',

                    required_items = {
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Copper', item = 'copper', amount = 1}

                    },
                    required_blueprint = false
                },
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
                    
                    required_items = {
                        {label = 'Plastic', item = 'plastic', amount = 1},
                        {label = 'Steel', item = 'steel', amount = 1}
                    },
                    required_blueprint = false

                },
                ['laptop'] = {
                    model = 'ex_prop_ex_laptop_01a', 
                    name = 'Laptop',
                    icon = 'laptop',
                    iconColor = '#339af0',
                    description = 'A high-performance laptop equipped with the latest technology, perfect for work, gaming, and browsing. Lightweight and portable for on-the-go use.',
                    
                    required_items = {
                        {label = 'Plastic', item = 'plastic', amount = 1},
                        {label = 'Steel', item = 'steel', amount = 1},
                        {label = 'Iron', item = 'iron', amount = 1}
                    },
                    required_blueprint = false

                },
            },
        }
    },

    interaction = { 

        targetLabel = 'Open Crafting',
        deleteTargetLabel = 'Pickup Table',
        targetradius = 3.0, 
        targeticon = 'fas fa-screwdriver-wrench', -- https://fontawesome.com/icons
        deleteTargeticon = 'fas fa-x', -- https://fontawesome.com/icons
        targetdistance = 2.0,
    },

    locales = {
        no_placing_in_vehicle = 'You cannot place items while in a vehicle',
        placed_crafting_table = 'Placed crafting table',
        pickedup_crafting_table = 'Picked up crafting table',
        failed_to_pickup_crafting_table = 'Failed to pickup crafting table',

        craftable_required_items = 'Required Items',
        no_blueprint = 'You are missing %s',
        missing_required_items = 'You are missing required items!',
        crafted_item = 'Successfully crafted a %s'
    },
    
}