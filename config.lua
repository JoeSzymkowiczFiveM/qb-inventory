Config = {}

Config.BinObjects = {
    "prop_bin_05a",
}

Config.VendingItem = {
    [1] = {
        name = "kurkakola",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 1,
    },
    [2] = {
        name = "water_bottle",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 2,
    },
}

Config.Masks = {
    [2] = true,
    [3] = true,
    [4] = true,
    [51] = true,
    [54] = true,
    [57] = true,
    [69] = true,
    [115] = true,
    [147] = true,
}

Config.CraftingItems = {
    [1] = {
        name = "lockpick",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 10,
        },
        type = "item",
        slot = 1,
        threshold = 0,
        points = 1,
    },
    [2] = {
        name = "screwdriverset",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 30,
            ["plastic"] = 42,
        },
        type = "item",
        slot = 2,
        threshold = 0,
        points = 2,
    },
    [3] = {
        name = "electronickit",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 30,
            ["plastic"] = 45,
            ["aluminum"] = 28,
        },
        type = "item",
        slot = 3,
        threshold = 0,
        points = 3,
    },
    [4] = {
        name = "vpn",
        amount = 50,
        info = {},
        costs = {
            ["transmitter"] = 1,
            ["electronickit"] = 2,
            ["plastic"] = 52,
            ["steel"] = 40,
        },
        type = "item",
        slot = 4,
        threshold = 80,
        points = 4,
    },
    [5] = {
        name = "gatecrack",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 10,
            ["plastic"] = 50,
            ["aluminum"] = 30,
            ["iron"] = 17,
            ["electronickit"] = 1,
        },
        type = "item",
        slot = 5,
        threshold = 120,
        points = 5,
    },
    [6] = {
        name = "handcuffs",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 36,
            ["steel"] = 24,
            ["aluminum"] = 28,
        },
        type = "item",
        slot = 6,
        threshold = 160,
        points = 6,
    },
    [7] = {
        name = "repairkit",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 32,
            ["steel"] = 43,
            ["plastic"] = 61,
        },
        type = "item",
        slot = 7,
        threshold = 200,
        points = 7,
    },
    [8] = {
        name = "pistol_ammo",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 50,
            ["steel"] = 37,
            ["copper"] = 26,
        },
        type = "item",
        slot = 8,
        threshold = 250,
        points = 8,
    },
    [9] = {
        name = "thermite",
        amount = 50,
        info = {},
        costs = {
            ["glass"] = 35,
            ["steel"] = 65,
            ["copper"] = 95,
        },
        type = "item",
        slot = 9,
        threshold = 300,
        points = 10,
    },
    [10] = {
        name = "armor",
        amount = 50,
        info = {},
        costs = {
            ["iron"] = 33,
            ["steel"] = 44,
            ["plastic"] = 55,
            ["aluminum"] = 22,
        },
        type = "item",
        slot = 10,
        threshold = 350,
        points = 11,
    },
    [11] = {
        name = "hygrometer",
        amount = 50,
        info = {},
        costs = {
            ["transmitter"] = 1,
            ["electronickit"] = 1,
            ["glass"] = 10,
            ["plastic"] = 10,
            ["copper"] = 10,
        },
        type = "item",
        slot = 11,
        threshold = 410,
        points = 11,
    },
    [12] = {
        name = "radio",
        amount = 50,
        info = {},
        costs = {
            ["transmitter"] = 2,
            ["electronickit"] = 2,
            ["screwdriverset"] = 3,
            ["plastic"] = 50,
            ["aluminum"] = 100,
        },
        type = "item",
        slot = 12,
        threshold = 425,
        points = 11,
    },
    [13] = {
        name = "drill",
        amount = 50,
        info = {},
        costs = {
            ["iron"] = 50,
            ["steel"] = 50,
            ["screwdriverset"] = 3,
            ["advancedlockpick"] = 2,
        },
        type = "item",
        slot = 13,
        threshold = 500,
        points = 15,
    },
}

Config.AttachmentCrafting = {
    ["coords"] = vector3(587.87603, -3276.786, 6.0695638), 
    ["location"] = "Elysian Island",
    ["items"] = {
        [1] = {
            name = "pistol_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 20,
                ["steel"] = 20,
                ["rubber"] = 10,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        [2] = {
            name = "pistol_suppressor",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 165,
                ["steel"] = 285,
                ["rubber"] = 75,
            },
            type = "item",
            slot = 2,
            threshold = 10,
            points = 2,
        },
        [3] = {
            name = "rifle_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 190,
                ["steel"] = 305,
                ["rubber"] = 85,
                ["smg_extendedclip"] = 1,
            },
            type = "item",
            slot = 7,
            threshold = 25,
            points = 8,
        },
        [4] = {
            name = "rifle_drummag",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 205,
                ["steel"] = 340,
                ["rubber"] = 110,
                ["smg_extendedclip"] = 2,
            },
            type = "item",
            slot = 8,
            threshold = 50,
            points = 8,
        },
        [5] = {
            name = "smg_flashlight",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 230,
                ["steel"] = 365,
                ["rubber"] = 130,
            },
            type = "item",
            slot = 3,
            threshold = 75,
            points = 3,
        },
        [6] = {
            name = "smg_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 255,
                ["steel"] = 390,
                ["rubber"] = 145,
            },
            type = "item",
            slot = 4,
            threshold = 100,
            points = 4,
        },
        [7] = {
            name = "smg_suppressor",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 270,
                ["steel"] = 435,
                ["rubber"] = 155,
            },
            type = "item",
            slot = 5,
            threshold = 150,
            points = 5,
        },
        [8] = {
            name = "smg_scope",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 300,
                ["steel"] = 469,
                ["rubber"] = 170,
            },
            type = "item",
            slot = 6,
            threshold = 200,
            points = 6,
        },
    }
}
--[[ 
Config.MechanicCraftingLocations = {
    [1] = vector3(1001.813598, -1499.18469, 31.47834205),
    [2] = vector3(948.4946289, -969.322021, 39.52670288),
} ]]

Config.MechanicCrafting = {
    ["coords"] = {
        [1] = vector3(1001.813598, -1499.18469, 31.47834205),
        [2] = vector3(948.4946289, -969.322021, 39.52670288),
    },
    ["location"] = "Murrieta Heights",
    ["items"] = {
        [1] = {
            name = "repairkit",
            amount = 10,
            info = {},
            costs = {
                ["metalscrap"] = 5,
                ["steel"] = 5,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        [2] = {
            name = "advancedrepairkit",
            amount = 10,
            info = {},
            costs = {
                ["metalscrap"] = 8,
                ["steel"] = 8,
            },
            type = "item",
            slot = 2,
            threshold = 0,
            points = 1,
        },
        [3] = {
            name = "tires_drift",
            amount = 10,
            info = {},
            costs = {
                ["rubber"] = 200,
            },
            type = "item",
            slot = 3,
            threshold = 0,
            points = 5,
        },
        [4] = {
            name = "mechanic_turbo",
            amount = 1,
            info = {},
            costs = {
                ["aluminum"] = 200,
                ["metalscrap"] = 200,
                ["steel"] = 200,
            },
            type = "item",
            slot = 4,
            threshold = 50,
            points = 20,
        },
        [5] = {
            name = "mechanic_engine2",
            amount = 1,
            info = {},
            costs = {
                ["aluminum"] = 125,
                ["metalscrap"] = 125,
                ["steel"] = 125,
            },
            type = "item",
            slot = 5,
            threshold = 100,
            points = 25,
        },
        [6] = {
            name = "mechanic_engine3",
            amount = 1,
            info = {},
            costs = {
                ["aluminum"] = 200,
                ["metalscrap"] = 200,
                ["steel"] = 200,
            },
            type = "item",
            slot = 6,
            threshold = 100,
            points = 45,
        },
        [7] = {
            name = "mechanic_engine4",
            amount = 1,
            info = {},
            costs = {
                ["aluminum"] = 400,
                ["metalscrap"] = 400,
                ["steel"] = 400,
            },
            type = "item",
            slot = 7,
            threshold = 100,
            points = 50,
        },
        [8] = {
            name = "plate_removal_tool",
            amount = 10,
            info = {},
            costs = {
                ["steel"] = 500,
                ["metalscrap"] = 500,
            },
            type = "item",
            slot = 8,
            threshold = 200,
            points = 10,
        },
    }
}

Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

MaxInventorySlots = 41 --41 for secret slot

BackEngineVehicles = {
    'ninef',
    'adder',
    'vagner',
    't20',
    'infernus',
    'zentorno',
    'reaper',
    'comet2',
    'comet3',
    'jester',
    'jester2',
    'cheetah',
    'cheetah2',
    'prototipo',
    'turismor',
    'pfister811',
    'ardent',
    'nero',
    'nero2',
    'tempesta',
    'vacca',
    'bullet',
    'osiris',
    'entityxf',
    'turismo2',
    'fmj',
    're7b',
    'tyrus',
    'italigtb',
    'penetrator',
    'monroe',
    'ninef2',
    'stingergt',
    'surfer',
    'surfer2',
    'comet6',
}

Config.CustomTrunkPosition = { --custom trunk positions, typically needed for job vehicle stuffs
    [-1705304628] = {x = 0.0, y = -4.5, z = 0.0}, --rubble mining truck
    [-2137348917] = {x = 0.0, y = -0.5, z = 0.0}, --phantom fueling truck
    [-730904777] = {x = 0.0, y = -6.5, z = -1.0}, --fueling trailer
    [1747439474] = {x = 0.0, y = -3.55, z = 1.1}, --stockade
}

Config.MaximumAmmoValues = {
    ["pistol"] = 250,
    ["smg"] = 250,
    ["shotgun"] = 200,
    ["rifle"] = 250,
}

Config.DurabilityBlockedWeapons = {
    --"weapon_pistol_mk2",
    --"weapon_pistol",
    --"weapon_stungun",
    --"weapon_pumpshotgun",
    --"weapon_smg",
    --"weapon_carbinerifle",
    --"weapon_nightstick",
    "weapon_flashlight",
    "weapon_unarmed",
    "weapon_petrolcan",
}

Config.StressBlockedWeapons = {
    --"weapon_pistol_mk2",
    --"weapon_pistol",
    ["weapon_stungun"] = true,
    ["weapon_unarmed"] = true,
    ["weapon_snowball"] = true,
    ["weapon_petrolcan"] = true,
    ["weapon_fireextinguisher"] = true,
    ["weapon_hammer"] = true,
    ["weapon_bat"] = true,
    ["weapon_nightstick"] = true,
}

Config.AlertsBlockedWeapons = {
    "weapon_bzgas",
    --"weapon_pistol",
    "weapon_stungun",
    "weapon_unarmed",
    "weapon_snowball",
    "weapon_petrolcan",
    "weapon_fireextinguisher",
    "weapon_hammer",
    "weapon_bat",
    "weapon_nightstick",
}

Config.DurabilityMultiplier = {
    --["weapon_unarmed"] 				 = 0.15,
    ["weapon_knife"] 				 = 0.15,
    ["weapon_nightstick"] 			 = 0.15,
    ["weapon_hammer"] 				 = 0.15,
    ["weapon_bat"] 					 = 0.15,
    ["weapon_golfclub"] 			 = 0.15,
    ["weapon_crowbar"] 				 = 0.15,
    ["weapon_pistol"] 				 = 0.50,
    ["weapon_pistol_mk2"] 			 = 0.15,
    ["weapon_combatpistol"] 		 = 0.15,
    ["weapon_appistol"] 			 = 0.15,
    ["weapon_pistol50"] 			 = 0.15,
    ["weapon_microsmg"] 			 = 0.15,
    ["weapon_smg"] 				 	 = 0.15,
    ["weapon_assaultsmg"] 			 = 0.15,
    ["weapon_assaultrifle"] 		 = 0.15,
    ["weapon_carbinerifle"] 		 = 0.15,
    ["weapon_advancedrifle"] 		 = 0.15,
    ["weapon_mg"] 					 = 0.15,
    ["weapon_combatmg"] 			 = 0.15,
    ["weapon_pumpshotgun"] 			 = 0.15,
    ["weapon_sawnoffshotgun"] 		 = 0.15,
    ["weapon_assaultshotgun"] 		 = 0.15,
    ["weapon_bullpupshotgun"] 		 = 0.15,
    ["weapon_stungun"] 				 = 0.50,
    ["weapon_sniperrifle"] 			 = 0.15,
    ["weapon_heavysniper"] 			 = 0.15,
    ["weapon_remotesniper"] 		 = 0.15,
    ["weapon_grenadelauncher"] 		 = 0.15,
    ["weapon_grenadelauncher_smoke"] = 0.15,
    ["weapon_rpg"] 					 = 0.15,
    ["weapon_minigun"] 				 = 0.15,
    ["weapon_grenade"] 				 = 0.15,
    ["weapon_stickybomb"] 			 = 0.15,
    ["weapon_smokegrenade"] 		 = 0.15,
    ["weapon_bzgas"] 				 = 0.15,
    ["weapon_molotov"] 				 = 0.15,
    ["weapon_fireextinguisher"] 	 = 0.15,
    --["weapon_petrolcan"] 			 = 0.15,
    ["weapon_briefcase"] 			 = 0.15,
    ["weapon_briefcase_02"] 		 = 0.15,
    ["weapon_ball"] 				 = 0.15,
    ["weapon_flare"] 				 = 0.15,
    ["weapon_snspistol"] 			 = 0.15,
    ["weapon_bottle"] 				 = 0.15,
    ["weapon_gusenberg"] 			 = 0.15,
    ["weapon_specialcarbine"] 		 = 0.15,
    ["weapon_heavypistol"] 			 = 0.15,
    ["weapon_bullpuprifle"] 		 = 0.15,
    ["weapon_dagger"] 				 = 0.15,
    ["weapon_vintagepistol"] 		 = 0.15,
    ["weapon_firework"] 			 = 0.15,
    ["weapon_musket"] 			     = 0.15,
    ["weapon_heavyshotgun"] 		 = 0.15,
    ["weapon_marksmanrifle"] 		 = 0.15,
    ["weapon_hominglauncher"] 		 = 0.15,
    ["weapon_proxmine"] 			 = 0.15,
    ["weapon_snowball"] 		     = 0.15,
    ["weapon_flaregun"] 			 = 0.15,
    ["weapon_garbagebag"] 			 = 0.15,
    ["weapon_handcuffs"] 			 = 0.15,
    ["weapon_combatpdw"] 			 = 0.15,
    ["weapon_marksmanpistol"] 		 = 0.15,
    ["weapon_knuckle"] 				 = 0.15,
    ["weapon_hatchet"] 				 = 0.15,
    ["weapon_railgun"] 				 = 0.15,
    ["weapon_machete"] 				 = 0.15,
    ["weapon_machinepistol"] 		 = 0.15,
    ["weapon_switchblade"] 			 = 0.15,
    ["weapon_revolver"] 			 = 0.15,
    ["weapon_dbshotgun"] 			 = 0.15,
    ["weapon_compactrifle"] 		 = 0.15,
    ["weapon_autoshotgun"] 			 = 0.15,
    ["weapon_battleaxe"] 			 = 0.15,
    ["weapon_compactlauncher"] 		 = 0.15,
    ["weapon_minismg"] 				 = 0.15,
    ["weapon_pipebomb"] 			 = 0.15,
    ["weapon_poolcue"] 				 = 0.15,
    ["weapon_wrench"] 				 = 0.15,
    ["weapon_autoshotgun"] 		 	 = 0.15,
    ["weapon_bread"] 				 = 0.15,
    ["weapon_p90fm"] 				 = 0.15,
    ["weapon_m4a1fm"] 				 = 0.15,
    ["weapon_akm"] 		 	         = 0.15,
    ["weapon_m870"] 				 = 0.15,
    ["weapon_pp19"] 				 = 0.15,
    ["weapon_mk18"] 				 = 0.15,   
    ["weapon_m700a"] 				 = 0.95,
    ["weapon_rpk16"] 				 = 0.25, 
    ["weapon_g45"] 				     = 0.25, 
    ["weapon_2011"] 				 = 0.25,
    ["weapon_sr25"] 				 = 0.25, 
    --continue to add new weapons here
}

Config.WeaponRepairPoints = {
    {
        coords = {x = -342.485, y = 6097.686, z = 31.31021, h = 230.0, r = 1.0},
        IsRepairing = false,
        RepairingData = {},
    }
}

Config.WeaponRepairCosts = {
    ["pistol"] = 1000,
    ["smg"] = 3000,
    ["rifle"] = 5000,
    ["sniper"] = 3000,
}

Config.WeaponAttachments = {
    ["WEAPON_SNSPISTOL"] = {
        ["extendedclip"] = {
            {
                component = "COMPONENT_SNSPISTOL_CLIP_02",
                label = "Extended Clip",
                item = "pistol_extendedclip",
                type = 'extendedclip',
            }
        },
    },
    ["WEAPON_VINTAGEPISTOL"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AT_PI_SUPP",
                label = "Suppressor",
                item = "pistol_suppressor",
                type = 'suppressor',
            }
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_VINTAGEPISTOL_CLIP_02",
                label = "Extended Clip",
                item = "pistol_extendedclip",
                type = 'extendedclip',
            }
        },
    },
    ["WEAPON_PISTOL"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AT_PI_SUPP_02",
                label = "Suppressor",
                item = "pistol_suppressor",
                type = 'suppressor',
            }
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_AT_PI_FLSH",
                label = "Flashlight",
                item = "smg_flashlight",
                type = 'flashlight',
            }
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_PISTOL_CLIP_02",
                label = "Extended Clip",
                item = "pistol_extendedclip",
                type = 'extendedclip',
            }
        },                                                     
    },
    ["WEAPON_MICROSMG"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AT_AR_SUPP_02",
                label = "Suppressor",
                item = "smg_suppressor",
                type = 'suppressor',
            }
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_MICROSMG_CLIP_02",
                label = "Extended Clip",
                item = "smg_extendedclip",
                type = 'extendedclip',
            }
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_AT_PI_FLSH",
                label = "Flashlight",
                item = "smg_flashlight",
                type = 'flashlight',
            }
        },
        ["scope"] = {
            {
                component = "COMPONENT_AT_SCOPE_MACRO",
                label = "Scope",
                item = "smg_scope",
                type = 'scope',
            }
        },
    },
    ["WEAPON_MINISMG"] = {
        ["extendedclip"] = {
            {
                component = "COMPONENT_MINISMG_CLIP_02",
                label = "Extended Clip",
                item = "smg_extendedclip",
                type = 'extendedclip',
            }
        },
    },
    ["WEAPON_COMPACTRIFLE"] = {
        ["extendedclip"] = {
            {
                component = "COMPONENT_COMPACTRIFLE_CLIP_02",
                label = "Extended Clip",
                item = "rifle_extendedclip",
                type = 'extendedclip',
            }
        },
        ["drummag"] = {
            {
                component = "COMPONENT_COMPACTRIFLE_CLIP_03",
                label = "Drum Mag",
                item = "rifle_drummag",
                type = 'drummag',
            }
        },
    },
    ["WEAPON_P90FM"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_P90_BARREL_02",
                label = "Suppressor",
                item = "p90fm_suppressor",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_P90_BARREL_03",
                label = "Extended Barrel",
                item = "p90fm_extended_barrel",
                type = 'suppressor',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_P90_SCOPE_02",
                label = "Scope 1",
                item = "p90fm_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_03",
                label = "Scope 2",
                item = "p90fm_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_04",
                label = "Scope 3",
                item = "p90fm_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_05",
                label = "Scope 4",
                item = "p90fm_scope4",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_06",
                label = "Scope 5",
                item = "p90fm_scope5",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_07",
                label = "Scope 6",
                item = "p90fm_scope6",
                type = 'scope',
            },
            {
                component = "COMPONENT_P90_SCOPE_08",
                label = "Scope 7",
                item = "p90fm_scope7",
                type = 'scope',
            },
            
        },
        ["stock"] = {
            {
                component = "COMPONENT_P90_BUTTPAD_02",
                label = "Butt Stock",
                item = "p90fm_buttpad1",
                type = 'stock',
            }
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_P90_FLSH_01",
                label = "Flashlight 1",
                item = "p90fm_flashlight1",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_02",
                label = "Flashlight 2",
                item = "p90fm_flashlight2",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_03",
                label = "Flashlight 3",
                item = "p90fm_flashlight3",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_04",
                label = "Flashlight 4",
                item = "p90fm_flashlight4",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_05",
                label = "Flashlight 5",
                item = "p90fm_flashlight5",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_06",
                label = "Flashlight 6",
                item = "p90fm_flashlight6",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_P90_FLSH_07",
                label = "Flashlight 7",
                item = "p90fm_flashlight7",
                type = 'flashlight',
            },
        },
    },
    ["WEAPON_M4A1FM"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_M4A1FM_BARREL_03",
                label = "Suppressor",
                item = "m4a1fm_suppressor",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_M4A1FM_BARREL_02",
                label = "Extended Barrel",
                item = "m4a1fm_extended_barrel",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_M4A1FM_BARREL_04",
                label = "Extended Suppressor",
                item = "m4a1fm_extended_suppressor",
                type = 'suppressor',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_M4A1FM_SCOPE_02",
                label = "Scope 1",
                item = "m4a1fm_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_M4A1FM_SCOPE_03",
                label = "Scope 2",
                item = "m4a1fm_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_M4A1FM_SCOPE_04",
                label = "Scope 3",
                item = "m4a1fm_scope3",
                type = 'scope',
            },
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_M4A1FM_FLSH_01",
                label = "Flashlight 1",
                item = "m4a1fm_flashlight1",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_M4A1FM_FLSH_02",
                label = "Flashlight 2",
                item = "m4a1fm_flashlight2",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_M4A1FM_FLSH_03",
                label = "Flashlight 3",
                item = "m4a1fm_flashlight3",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_M4A1FM_FLSH_04",
                label = "Flashlight 4",
                item = "m4a1fm_flashlight4",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_M4A1FM_FLSH_05",
                label = "Flashlight 5",
                item = "m4a1fm_flashlight5",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_M4A1FM_FLSH_06",
                label = "Flashlight 6",
                item = "m4a1fm_flashlight6",
                type = 'flashlight',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_M4A1FM_CLIP_02",
                label = "Extended Clip 1",
                item = "m4a1fm_clip1",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_M4A1FM_CLIP_03",
                label = "Extended Clip 2",
                item = "m4a1fm_clip2",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_M4A1FM_CLIP_04",
                label = "Extended Clip 3",
                item = "m4a1fm_clip3",
                type = 'extendedclip',
            },
        },
    },
    ["WEAPON_AKM"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AKM_SUPP_01",
                label = "Suppressor 1",
                item = "akm_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_AKM_SUPP_02",
                label = "Suppressor 2",
                item = "akm_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_AKM_SUPP_03",
                label = "Suppressor 3",
                item = "akm_suppressor3",
                type = 'suppressor',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_AKM_SCOPE_01",
                label = "Scope 1",
                item = "akm_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_AKM_SCOPE_02",
                label = "Scope 2",
                item = "akm_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_AKM_SCOPE_03",
                label = "Scope 3",
                item = "akm_scope3",
                type = 'scope',
            },
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_M4A1FM_FLSH_01",
                label = "Flashlight 1",
                item = "m4a1fm_flashlight1",
                type = 'flashlight',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_M4A1FM_CLIP_02",
                label = "Extended Clip 1",
                item = "m4a1fm_clip1",
                type = 'extendedclip',
            },
        },
    },
    ["WEAPON_M870"] = {
        ["handguard"] = {
            {
                component = "COMPONENT_M870_HANDGUARD_02",
                label = "Handguard 1",
                item = "m870_handguard1",
                type = 'handguard',
            },
            {
                component = "COMPONENT_M870_HANDGUARD_03",
                label = "Handguard 2",
                item = "m870_handguard2",
                type = 'handguard',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_M870_STOCK_02",
                label = "Stock 1",
                item = "m870_stock1",
                type = 'stock',
            },
            {
                component = "COMPONENT_M870_STOCK_03",
                label = "Stock 2",
                item = "m870_stock2",
                type = 'stock',
            },
            {
                component = "COMPONENT_M870_STOCK_04",
                label = "Stock 3",
                item = "m870_stock3",
                type = 'stock',
            },
            {
                component = "COMPONENT_M870_STOCK_05",
                label = "Stock 4",
                item = "m870_stock4",
                type = 'stock',
            },
            {
                component = "COMPONENT_M870_STOCK_06",
                label = "Stock 5",
                item = "m870_stock5",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_M870_SCOPE_01",
                label = "Scope 1",
                item = "m870_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_M870_SCOPE_02",
                label = "Scope 2",
                item = "m870_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_M870_SCOPE_03",
                label = "Scope 3",
                item = "m870_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_M870_SCOPE_04",
                label = "Scope 4",
                item = "m870_scope4",
                type = 'scope',
            },
        },
        ["barrel"] = {
            {
                component = "COMPONENT_M870_BARREL_02",
                label = "Barrel 1",
                item = "m870_barrel1",
                type = 'barrel',
            },
            {
                component = "COMPONENT_M870_BARREL_03",
                label = "Barrel 2",
                item = "m870_barrel2",
                type = 'barrel',
            },
            {
                component = "COMPONENT_M870_BARREL_04",
                label = "Barrel 3",
                item = "m870_barrel3",
                type = 'barrel',
            },
            {
                component = "COMPONENT_M870_BARREL_05",
                label = "Barrel 4",
                item = "m870_barrel4",
                type = 'barrel',
            },
            {
                component = "COMPONENT_M870_BARREL_06",
                label = "Barrel 5",
                item = "m870_barrel5",
                type = 'barrel',
            },
            {
                component = "COMPONENT_M870_BARREL_07",
                label = "Barrel 6",
                item = "m870_barrel6",
                type = 'barrel',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_M870_CLIP_02",
                label = "Extended Clip 1",
                item = "m870_clip1",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_M870_CLIP_03",
                label = "Extended Clip 2",
                item = "m870_clip2",
                type = 'extendedclip',
            },
        },
    },
    ["WEAPON_PP19"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_PP19_MUZZLE_02",
                label = "Barrel 1",
                item = "pp19_barrel1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_PP19_MUZZLE_03",
                label = "Barrel 2",
                item = "pp19_barrel2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_PP19_MUZZLE_04",
                label = "Barrel 3",
                item = "pp19_barrel3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_PP19_MUZZLE_05",
                label = "Barrel 4",
                item = "pp19_barrel4",
                type = 'suppressor',
            },
        },
        ["handguard"] = {
            {
                component = "COMPONENT_PP19_HANDGUARD_02",
                label = "Handguard 1",
                item = "pp19_handguard1",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_03",
                label = "Handguard 2",
                item = "pp19_handguard2",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_04",
                label = "Handguard 3",
                item = "pp19_handguard3",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_05",
                label = "Handguard 4",
                item = "pp19_handguard4",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_06",
                label = "Handguard 5",
                item = "pp19_handguard5",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_07",
                label = "Handguard 6",
                item = "pp19_handguard6",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_08",
                label = "Handguard 7",
                item = "pp19_handguard7",
                type = 'handguard',
            },
            {
                component = "COMPONENT_PP19_HANDGUARD_09",
                label = "Handguard 8",
                item = "pp19_handguard8",
                type = 'handguard',
            },
        },
    },
    ["WEAPON_MK18"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_MK18_SUPPRESSOR_01",
                label = "Suppressor 1",
                item = "mk18_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MK18_SUPPRESSOR_02",
                label = "Suppressor 2",
                item = "mk18_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MK18_SUPPRESSOR_03",
                label = "Suppressor 3",
                item = "mk18_suppressor3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MK18_SUPPRESSOR_04",
                label = "Suppressor 4",
                item = "mk18_suppressor4",
                type = 'suppressor',
            },
        },
        ["flash"] = {
            {
                component = "COMPONENT_MK18_FLASH_01",
                label = "Flashlight 1",
                item = "mk18_flash1",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_02",
                label = "Flashlight 2",
                item = "mk18_flash2",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_03",
                label = "Flashlight 3",
                item = "mk18_flash3",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_04",
                label = "Flashlight 4",
                item = "mk18_flash4",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_05",
                label = "Flashlight 5",
                item = "mk18_flash5",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_06",
                label = "Flashlight 6",
                item = "mk18_flash6",
                type = 'flash',
            },
            {
                component = "COMPONENT_MK18_FLASH_07",
                label = "Flashlight 7",
                item = "mk18_flash7",
                type = 'flash',
            },
        },
        ["frame"] = {
            {
                component = "COMPONENT_MK18_FRAME_02",
                label = "Frame 1",
                item = "mk18_frame1",
                type = 'frame',
            },
            {
                component = "COMPONENT_MK18_FRAME_03",
                label = "Frame 2",
                item = "mk18_frame2",
                type = 'frame',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_MK18_STOCK_02",
                label = "Stock 1",
                item = "mk18_stock1",
                type = 'stock',
            },
            {
                component = "COMPONENT_MK18_STOCK_03",
                label = "Stock 2",
                item = "mk18_stock2",
                type = 'stock',
            },
            {
                component = "COMPONENT_MK18_STOCK_04",
                label = "Stock 3",
                item = "mk18_stock3",
                type = 'stock',
            },
            {
                component = "COMPONENT_MK18_STOCK_05",
                label = "Stock 4",
                item = "mk18_stock4",
                type = 'stock',
            },
            {
                component = "COMPONENT_MK18_STOCK_06",
                label = "Stock 5",
                item = "mk18_stock5",
                type = 'stock',
            },
            {
                component = "COMPONENT_MK18_STOCK_07",
                label = "Stock 6",
                item = "mk18_stock6",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_MK18_SCOPE_02",
                label = "Scope 1",
                item = "mk18_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_03",
                label = "Scope 2",
                item = "mk18_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_04",
                label = "Scope 3",
                item = "mk18_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_05",
                label = "Scope 4",
                item = "mk18_scope4",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_06",
                label = "Scope 5",
                item = "mk18_scope5",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_07",
                label = "Scope 6",
                item = "mk18_scope6",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_08",
                label = "Scope 7",
                item = "mk18_scope7",
                type = 'scope',
            },
            {
                component = "COMPONENT_MK18_SCOPE_09",
                label = "Scope 8",
                item = "mk18_scope8",
                type = 'scope',
            },
        },
    },
    ["WEAPON_M700A"] = {
        ["barrel"] = {
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_01",
                label = "Barrel 1",
                item = "m700a_barrel1",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_02",
                label = "Barrel 2",
                item = "m700a_barrel2",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_03",
                label = "Barrel 3",
                item = "m700a_barrel3",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_04",
                label = "Barrel 4",
                item = "m700a_barrel4",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_05",
                label = "Barrel 5",
                item = "m700a_barrel5",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_06",
                label = "Barrel 6",
                item = "m700a_barrel6",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_07",
                label = "Barrel 7",
                item = "m700a_barrel7",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_08",
                label = "Barrel 8",
                item = "m700a_barrel8",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_09",
                label = "Barrel 9",
                item = "m700a_barrel9",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_10",
                label = "Barrel 10",
                item = "m700a_barrel10",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_MUZZLE_11",
                label = "Barrel 11",
                item = "m700a_barrel11",
                type = 'barrel',
            },
            {
                component = "COMPONENT_MARKOMODSM700_BARREL_02",
                label = "Barrel 12",
                item = "m700a_barrel12",
                type = 'barrel',
            },
        },
        ["clip"] = {
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_02",
                label = "Clip 1",
                item = "m700a_clip1",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_03",
                label = "Clip 2",
                item = "m700a_clip2",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_04",
                label = "Clip 3",
                item = "m700a_clip3",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_05",
                label = "Clip 4",
                item = "m700a_clip4",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_06",
                label = "Clip 5",
                item = "m700a_clip5",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_07",
                label = "Clip 6",
                item = "m700a_clip6",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_08",
                label = "Clip 7",
                item = "m700a_clip7",
                type = 'clip',
            },
            {
                component = "COMPONENT_MARKOMODSM700_CLIP_09",
                label = "Clip 8",
                item = "m700a_clip8",
                type = 'clip',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_MARKOMODSM700_STOCK_02",
                label = "Stock 1",
                item = "m700a_stock1",
                type = 'stock',
            },
            {
                component = "COMPONENT_MARKOMODSM700_STOCK_03",
                label = "Stock 2",
                item = "m700a_stock2",
                type = 'stock',
            },
            {
                component = "COMPONENT_MARKOMODSM700_STOCK_04",
                label = "Stock 3",
                item = "m700a_stock3",
                type = 'stock',
            },
            {
                component = "COMPONENT_MARKOMODSM700_STOCK_05",
                label = "Stock 4",
                item = "m700a_stock4",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_01",
                label = "Scope 1",
                item = "m700a_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_02",
                label = "Scope 2",
                item = "m700a_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_03",
                label = "Scope 3",
                item = "m700a_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_04",
                label = "Scope 4",
                item = "m700a_scope4",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_05",
                label = "Scope 5",
                item = "m700a_scope5",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_06",
                label = "Scope 6",
                item = "m700a_scope6",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSM700_SCOPE_07",
                label = "Scope 7",
                item = "m700a_scope7",
                type = 'scope',
            },
        },
    },
    ["WEAPON_RPK16"] = {
        ["barrel"] = {
            {
                component = "COMPONENT_RPK16_MUZZLE_02",
                label = "Barrel 1",
                item = "rpk16_suppressor1",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_03",
                label = "Barrel 2",
                item = "rpk16_suppressor2",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_04",
                label = "Barrel 3",
                item = "rpk16_suppressor3",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_05",
                label = "Barrel 4",
                item = "rpk16_suppressor4",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_06",
                label = "Barrel 5",
                item = "rpk16_suppressor5",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_07",
                label = "Barrel 6",
                item = "rpk16_suppressor6",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_08",
                label = "Barrel 7",
                item = "rpk16_suppressor7",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_09",
                label = "Barrel 8",
                item = "rpk16_suppressor8",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_MUZZLE_10",
                label = "Barrel 9",
                item = "rpk16_suppressor9",
                type = 'barrel',
            },
            {
                component = "COMPONENT_RPK16_BARREL_02",
                label = "Barrel 10",
                item = "rpk16_suppressor10",
                type = 'barrel',
            },
        },
    },
    ["WEAPON_G45"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_MARKOMODSG45_BARREL_02",
                label = "Suppressor 1",
                item = "g45_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG45_BARREL_03",
                label = "Suppressor 2",
                item = "g45_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG45_BARREL_04",
                label = "Suppressor 3",
                item = "g45_suppressor3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG45_BARREL_05",
                label = "Suppressor 4",
                item = "g45_suppressor4",
                type = 'suppressor',
            },
        },
    },
    ["WEAPON_GLOCK"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_SUPP_01",
                label = "Suppressor 1",
                item = "g17_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_02",
                label = "Suppressor 2",
                item = "g17_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_03",
                label = "Suppressor 3",
                item = "g17_suppressor3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_04",
                label = "Suppressor 4",
                item = "g17_suppressor4",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_05",
                label = "Suppressor 5",
                item = "g17_suppressor5",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_06",
                label = "Suppressor 6",
                item = "g17_suppressor6",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SUPP_07",
                label = "Suppressor 7",
                item = "g17_suppressor7",
                type = 'suppressor',
            },
        },
    },
    ["WEAPON_MP5"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AT_MP5_SUPP",
                label = "Suppressor 1",
                item = "mp5_suppressor1",
                type = 'suppressor',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_AT_SCOPE_MP5",
                label = "Scope 1",
                item = "mp5_scope1",
                type = 'scope',
            },
        },
        --[[ ["flashlight"] = {
            {
                component = "COMPONENT_M4A1FM_FLSH_01",
                label = "Flashlight 1",
                item = "m4a1fm_flashlight1",
                type = 'flashlight',
            },
        }, ]]
    },
    ["WEAPON_G36"] = {
        ["stock"] = {
            {
                component = "COMPONENT_MARKOMODSG36_STOCK_02",
                label = "Stock 1",
                item = "g36_stock1",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_02",
                label = "Scope 1",
                item = "g36_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_03",
                label = "Scope 2",
                item = "g36_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_04",
                label = "Scope 3",
                item = "g36_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_05",
                label = "Scope 4",
                item = "g36_scope4",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_06",
                label = "Scope 5",
                item = "g36_scope5",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_07",
                label = "Scope 6",
                item = "g36_scope6",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_08",
                label = "Scope 7",
                item = "g36_scope7",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_09",
                label = "Scope 8",
                item = "g36_scope8",
                type = 'scope',
            },
            {
                component = "COMPONENT_MARKOMODSG36_SCOPE_10",
                label = "Scope 9",
                item = "g36_scope9",
                type = 'scope',
            },
        },
        ["suppressor"] = {
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_02",
                label = "Suppressor 1",
                item = "g36_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_03",
                label = "Suppressor 2",
                item = "g36_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_04",
                label = "Suppressor 3",
                item = "g36_suppressor3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_05",
                label = "Suppressor 4",
                item = "g36_suppressor4",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_06",
                label = "Suppressor 5",
                item = "g36_suppressor5",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_07",
                label = "Suppressor 6",
                item = "g36_suppressor6",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_08",
                label = "Suppressor 7",
                item = "g36_suppressor7",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_MARKOMODSG36_BARREL_09",
                label = "Suppressor 8",
                item = "g36_suppressor8",
                type = 'suppressor',
            },
        },
        ["barrel"] = {
            {
                component = "COMPONENT_MARKOMODSG36_GRIP_01",
                label = "Barrel 1",
                item = "g36_grip1",
                type = 'barrel',
            },
        },
    },
    ["WEAPON_SCARSC"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_SCARSC_SUPP_01",
                label = "Suppressor 1",
                item = "scarsc_suppressor1",
                type = 'suppressor',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_SCARSC_STOCK_01",
                label = "Stock 1",
                item = "scarsc_stock1",
                type = 'stock',
            },
            {
                component = "COMPONENT_SCARSC_STOCK_02",
                label = "Stock 2",
                item = "scarsc_stock2",
                type = 'stock',
            },
            {
                component = "COMPONENT_SCARSC_STOCK_03",
                label = "Stock 3",
                item = "scarsc_stock3",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_SCARSC_SCOPE_01",
                label = "Scope 1",
                item = "scarsc_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCARSC_SCOPE_02",
                label = "Scope 2",
                item = "scarsc_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCARSC_SCOPE_03",
                label = "Scope 3",
                item = "scarsc_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCARSC_IRONSIGHT_01",
                label = "Scope 4",
                item = "scarsc_scope4",
                type = 'scope',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_SCARSC_CLIP_01",
                label = "Extended Clip 1",
                item = "scarsc_clip1",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARSC_CLIP_02",
                label = "Extended Clip 1",
                item = "scarsc_clip2",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARSC_CLIP_03",
                label = "Extended Clip 1",
                item = "scarsc_clip3",
                type = 'extendedclip',
            },
        },
    },
    ["WEAPON_SCARH"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_AT_AR_SUPP_02",
                label = "Suppressor 1",
                item = "scarh_suppressor1",
                type = 'suppressor',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_AT_AR_AFGRIP",
                label = "Stock 1",
                item = "scarh_stock1",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_AT_SCOPE_MEDIUM",
                label = "Scope 1",
                item = "scarh_scope1",
                type = 'scope',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_SCARH_CLIP_02",
                label = "Extended Clip 1",
                item = "scarh_clip1",
                type = 'extendedclip',
            },
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_AT_PI_FLSH",
                label = "Flashlight",
                item = "scarh_flashlight",
                type = 'flashlight',
            }
        },
    },
    ["WEAPON_SCAR17FM"] = {
        ["suppressor"] = {
            {
                component = "COMPONENT_SCAR_BARREL_02",
                label = "Suppressor 1",
                item = "scar17_suppressor1",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_03",
                label = "Suppressor 2",
                item = "scar17_suppressor2",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_04",
                label = "Suppressor 3",
                item = "scar17_suppressor3",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_05",
                label = "Suppressor 4",
                item = "scar17_suppressor4",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_06",
                label = "Suppressor 5",
                item = "scar17_suppressor5",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_07",
                label = "Suppressor 6",
                item = "scar17_suppressor6",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_08",
                label = "Suppressor 7",
                item = "scar17_suppressor7",
                type = 'suppressor',
            },
            {
                component = "COMPONENT_SCAR_BARREL_09",
                label = "Suppressor 8",
                item = "scar17_suppressor8",
                type = 'suppressor',
            },
        },
        ["stock"] = {
            {
                component = "COMPONENT_SCAR_BODY_02",
                label = "Stock 1",
                item = "scar17_stock1",
                type = 'stock',
            },
        },
        ["scope"] = {
            {
                component = "COMPONENT_SCAR_SCOPE_02",
                label = "Scope 1",
                item = "scar17_scope1",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_03",
                label = "Scope 2",
                item = "scar17_scope2",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_04",
                label = "Scope 3",
                item = "scar17_scope3",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_05",
                label = "Scope 4",
                item = "scar17_scope4",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_06",
                label = "Scope 5",
                item = "scar17_scope5",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_07",
                label = "Scope 6",
                item = "scar17_scope6",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_08",
                label = "Scope 7",
                item = "scar17_scope7",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_09",
                label = "Scope 8",
                item = "scar17_scope8",
                type = 'scope',
            },
            {
                component = "COMPONENT_SCAR_SCOPE_10",
                label = "Scope 9",
                item = "scar17_scope9",
                type = 'scope',
            },
        },
        ["extendedclip"] = {
            {
                component = "COMPONENT_SCARH_CLIP_02",
                label = "Extended Clip 1",
                item = "scar17_clip1",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARH_CLIP_03",
                label = "Extended Clip 2",
                item = "scar17_clip2",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARH_CLIP_04",
                label = "Extended Clip 3",
                item = "scar17_clip3",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARH_CLIP_05",
                label = "Extended Clip 4",
                item = "scar17_clip4",
                type = 'extendedclip',
            },
            {
                component = "COMPONENT_SCARH_CLIP_06",
                label = "Extended Clip 5",
                item = "scar17_clip5",
                type = 'extendedclip',
            },
        },
        ["flashlight"] = {
            {
                component = "COMPONENT_SCAR_FLSH_01",
                label = "Flashlight 1",
                item = "scar17_flashlight1",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_02",
                label = "Flashlight 2",
                item = "scar17_flashlight2",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_03",
                label = "Flashlight 3",
                item = "scar17_flashlight3",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_04",
                label = "Flashlight 4",
                item = "scar17_flashlight4",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_05",
                label = "Flashlight 5",
                item = "scar17_flashlight5",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_06",
                label = "Flashlight 6",
                item = "scar17_flashlight6",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_07",
                label = "Flashlight 7",
                item = "scar17_flashlight7",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_08",
                label = "Flashlight 8",
                item = "scar17_flashlight8",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_09",
                label = "Flashlight 9",
                item = "scar17_flashlight9",
                type = 'flashlight',
            },
            {
                component = "COMPONENT_SCAR_FLSH_10",
                label = "Flashlight 10",
                item = "scar17_flashlight10",
                type = 'flashlight',
            },

        },
    },
}