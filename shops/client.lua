

local shops = {}
_menuPool = MenuPool.New()

local function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('HelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('HelpNotification', false)
	else
		if (beep == nil or beep == false) then beep = false else beep = true end
		BeginTextCommandDisplayHelp('HelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

-- ShowAdvancedNotification("You've purchased " .. items, "Bank", "Store Purchase", "CHAR_BANK_FLEECA", 0, true, 2)

------------------------------
for _, shop in ipairs(Config.Shops) do
    shops[shop.Label] = UIMenu.New(Config.MenuName)
    local menu = shops[shop.Label]

    for key, categories in pairs(shop.Categories) do
        local category = _menuPool:AddSubMenu(menu, key)

        for k, items in pairs(categories) do
            category:AddItem(UIMenuItem.New(k, items.Description .. ". Purchase for " .. items.Price))
            category.OnItemSelect = function(sender, item, index)
                if item == items then
                    ShowAdvancedNotification("You've purchased " .. items .. " for " .. items.Price, "Bank", "Store Purchase", "CHAR_BANK_FLEECA", 0, true, 2)
                end
            end
        end
    end
    _menuPool:Add(menu)
end

_menuPool:RefreshIndex()

CreateThread(function()
    local isOpen = false

    while true do
        Wait(0)
        local player = PlayerPedId()

        for _, shop in pairs(Config.Shops) do
            for _, coords in pairs(shop.Coords) do
                local radius = 2
                if #(GetEntityCoords(player) - coords) < radius then
                    ShowHelpNotification("Press ~INPUT_CONTEXT~ To Open Shop", true, true, 5)
                    _menuPool:ProcessMenus()
                    if IsControlJustReleased(0, 51) then
                        isOpen = true
                        local menu = shops[shop.Label]
                        menu:Visible(isOpen)
                    end

                    isOpen = false
                end
            end
        end
    end
end)
--------------------

function ShowAdvancedNotification(message, sender, subject, textureDict, iconType, saveToBrief, color)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    ThefeedNextPostBackgroundColor(color)
    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(false, saveToBrief)
end

local function CreateShopBlips(x,y,z, name)
    local blip = AddBlipForCoord(x,y,z)

    SetBlipSprite(blip, 52)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 2)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)

    return blip
end

CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        for _, coords in pairs(shop.Coords) do
            CreateShopBlips(coords.x, coords.y, coords.z, shop.Label)
        end
    end
end)