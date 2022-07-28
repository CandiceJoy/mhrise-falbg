local DEFAULT_TRIGGER = 2048

local PadButtons = require("falbg.pad_buttons")
local padDevice = sdk.find_type_definition("snow.Pad.Device");

local settings = {
    trigger = DEFAULT_TRIGGER
}
local questManager = nil
local appGamePad = nil

local function saveSettings()
	json.dump_file("falbg.json", settings)
end

local function loadSettings()
	local loadedSettings = json.load_file("falbg.json")
	if loadedSettings then
		settings = loadedSettings
	end
    if not settings.trigger then
        setting.trigger = DEFAULT_TRIGGER
    end
end

loadSettings()

sdk.hook(padDevice:get_method("update"), function(args) end,
function(retval)
    if appGamePad and playerManager then
        local players = playerManager:get_field("PlayerList")
        if #players > 0 then
            local player = players[0]
            if player and player:get_type_definition():get_full_name() == "snow.player.LightBowgun" then
                local on = appGamePad:get_field("_on")
                if on & settings.trigger ~= 0 then
                    local trg = appGamePad:get_field("_trg")
                    trg = trg | settings.trigger
                    appGamePad:set_field("_trg", trg)
                end
            end
        end
    end
    return retval
end)

re.on_pre_application_entry("UpdateBehavior", function()
    if not questManager then
        questManager = sdk.get_managed_singleton("snow.QuestManager")
    end

    if not playerManager then
        playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    end

    if not appGamePad then
        appGamePad = sdk.get_managed_singleton("snow.Pad"):get_field("app")
    end
end)

local settingTrigger = false
re.on_draw_ui(function()
    if settingTrigger then
        settings.trigger = 0
        local button = appGamePad:call("get_on")
        draw.text(tostring(button), 551, 11, 0xFF000000);
		draw.text(tostring(button), 550, 10, 0xFFFFFFFF);
        if button > 0 and PadButtons[button] ~= nil then
            settings.trigger = button
            settingTrigger = false
        end
    end

    if imgui.tree_node("Fully Automatic LBG") then
		if imgui.button("Save Settings") then
			saveSettings();
		end

        imgui.text("Trigger")
        imgui.same_line()
        if imgui.button(PadButtons[settings.trigger]) then
            if appGamePad then
                settingTrigger = true
            end
        end

        imgui.tree_pop();
    end

end)

re.on_config_save(function()
	saveSettings();
end)