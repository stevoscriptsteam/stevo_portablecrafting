return {

    saveToDatabase = true,

    craftingTable = {
        item = 'stevo_craftingtable',
        model = 'gr_prop_gr_bench_02b'
    },


    blueprints = {
        ['stevo_blueprintexample'] = 2, -- Blueprint item name & uses.
    },

    craftables = {
        ['WEAPON_PISTOL'] = {
            model = 'w_pi_pistol', 
            name = 'Pistol',
            icon = 'gun',
            iconColor = '#339af0',
            description = 'A compact, semi-automatic handgun designed for personal defense and close-quarters combat.',
            
            required_items = {
                {label = 'Water Bottle', item = 'water', amount = 1},
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
                {label = 'Water Bottle', item = 'water', amount = 1},
            },
            required_blueprint = false, -- Set to false for no blueprint requirement.
            required_blueprint_label = '',
        },
        ['water'] = {
            model = 'prop_ld_flow_bottle', 

            name = 'Bottled Water',     
            icon = 'bottle-water',  
            iconColor = '#339af0',
            description = 'A bottle of water!.',

            required_items = {
                {label = 'Water Bottle', item = 'water', amount = 1},
            },
            required_blueprint = false, -- Set to false for no blueprint requirement.
            required_blueprint_label = '',
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