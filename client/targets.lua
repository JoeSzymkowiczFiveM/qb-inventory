local coffee = {
    `prop_vend_coffe_01`,  
}

local soda = {
    `prop_vend_soda_02`,
    `prop_vend_soda_01`,
}

local snacks = {
    `prop_vend_snak_01`,
    `prop_vend_snak_01_tu`,
}

local junk = {
    `sf_prop_sf_vend_drink_01a`,
}

exports.ox_target:addModel(coffee, 
    {
        {
            name = 'vending:coffee',
            event = "qb-shops:client:OpenCustomStore",
            parameter = "Coffee",
            icon = "fas fa-coffee",
            label = "Buy Coffee",
        },
    }
)

exports.ox_target:addModel(soda, 
    {
        {
            name = 'vending:soda',
            event = "qb-shops:client:OpenCustomStore",
            parameter = "Soda",
            icon = "fas fa-wine-bottle",
            label = "Buy Soda",
        },
    }
)

exports.ox_target:addModel(snacks, 
    {
        {
            name = 'vending:snacks',
            event = "qb-shops:client:OpenCustomStore",
            parameter = "Snacks",
            icon = "fas fa-candy-cane",
            label = "Buy Snacks",
        },
    }
)

exports.ox_target:addModel(junk, 
    {
        {
            name = 'vending:junk',
            event = "qb-shops:client:OpenCustomStore",
            parameter = "Junk",
            icon = "fa-solid fa-cup-straw-swoosh",
            label = "Buy Junk",
        },
    }
)

local workbench = {
    [1] = -573669520
}

exports.ox_target:addModel(workbench, 
    {
        {
            name = 'crafting:bench',
            parameter = "crafting",
            event = "qb-crafting:client:OpenCrafting",
            icon = "fas fa-toolbox",
            label = "Craft Items",
            distance = 1.5,
        },
    }
)

exports.ox_target:addBoxZone({
    coords = vector3(587.02, -3276.79, 6.07),
    size = vector3(2.25, 1.2, 1.4),
    rotation = 170,
    --debug = false,
    drawSprite = true,
    options = {
        {
            name = 'crafting:attachmentsbench',
            parameter = "attachment_crafting",
            event = 'qb-crafting:client:OpenCrafting',
            icon = "fas fa-toolbox",
            label = "Craft Weapons Attachments", 
            --groups = {courier=0}
            distance = 1.5,
        }
    }
})