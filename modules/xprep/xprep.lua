DFRL:NewDefaults("Xprep", {
    enabled = { true },
    xprepDarkMode = {0, "slider", {0, 1}, nil, "appearance", 1, "Adjust dark mode intensity", nil, nil},
    showXpBar = {true, "checkbox", nil, nil, "experience Bar", 1, "Show or hide the XP bar", nil, nil},
    showXpText = {true, "checkbox", nil, nil, "experience Bar", 2, "Show or hide XP text on the XP bar", nil, nil},
    hoverXP = {true, "checkbox", nil, "showXpText", "experience Bar", 3, "Show XP text when hovering over the XP bar", nil, nil},
    showXpOnGain = {true, "checkbox", nil, "showXpText", "experience Bar", 4, "Show XP text for 5 seconds when gaining XP", nil, nil},
    xpBarTextSize = {12, "slider", {8, 20}, "showXpText", "experience Bar", 5, "Adjusts the font size of the XP bar text", nil, nil},
    xpBarHeight = {12, "slider", {5, 20}, "showXpBar", "experience Bar", 6, "Adjusts the height of the XP bar", nil, nil},
    xpBarWidth = {400, "slider", {200, 700}, "showXpBar", "experience Bar", 7, "Adjusts the width of the XP bar", nil, nil},
    barFont = {"Myriad-Pro", "dropdown", {
        "FRIZQT__.TTF",
        "Expressway",
        "Homespun",
        "Hooge",
        "Myriad-Pro",
        "Prototype",
        "PT-Sans-Narrow-Bold",
        "PT-Sans-Narrow-Regular",
        "RobotoMono",
        "BigNoodleTitling",
        "Continuum",
        "DieDieDie"
    }, nil, "font", 8, "Change the font used for the experience and reputation bar", nil, nil},
    showRepText = {true, "checkbox", nil, nil, "reputation Bar", 9, "Show or hide reputation text on the reputation bar", nil, nil},
    autoTrack = {true, "checkbox", nil, nil, "reputation Bar", 10, "Automatically track reputation for factions you gain reputation with", nil, nil},
    hoverRep = {true, "checkbox", nil, nil, "reputation Bar", 11, "Show reputation text when hovering over the reputation bar", nil, nil},
    showRepOnGain = {true, "checkbox", nil, nil, "reputation Bar", 12, "Show reputation text for 5 seconds when gaining reputation", nil, nil},
    repBarTextSize = {11, "slider", {8, 20}, nil, "reputation Bar", 13, "Adjusts the font size of the reputation bar text", nil, nil},
    repBarHeight = {10, "slider", {5, 20}, nil, "reputation Bar", 14, "Adjusts the height of the reputation bar", nil, nil},
    repBarWidth = {300, "slider", {200, 700}, nil, "reputation Bar", 15, "Adjusts the width of the reputation bar", nil, nil},
})

DFRL:NewMod("Xprep", 1, function()
    local f2 = CreateFrame("Frame")
    f2:RegisterEvent("PLAYER_ENTERING_WORLD")
    f2:SetScript("OnEvent", function()
        --=================
        -- SETUP
        --=================
        local Setup = {
            texpath = DFRL:GetInfoOrCons("tex") .. "xprep\\",
            fontpath = DFRL:GetInfoOrCons("font"),

            xpBar = nil,
            xpBarBg = nil,
            xpBarLeftBorder = nil,
            xpBarRightBorder = nil,
            xpBarText = nil,
            xpOnGainEnabled = false,
            xpOnGainTimer = 0,

            repBar = nil,
            repBarBg = nil,
            repBarLeftBorder = nil,
            repBarRightBorder = nil,
            repBarText = nil,

            colors = {
                dark = { 0.2, 0.2, 0.2 },
                light = { 1, 1, 1 },
            },

            repShowText = true,
            repAutoTrack = true,
        }

        function Setup:BlizzardBars()
            KillFrame(MainMenuBarPerformanceBarFrame)
            KillFrame(MainMenuExpBar)
            KillFrame(ReputationWatchBar)
        end

        function Setup:XPBar()
            self.xpBar = CreateFrame("StatusBar", "DFRL_XPBar", UIParent)
            self.xpBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 25)
            self.xpBar:SetWidth(512)
            self.xpBar:SetHeight(10)
            self.xpBar:SetStatusBarTexture(self.texpath .. "main.tga")
            self.xpBar:SetStatusBarColor(0.58, 0, 0.55)
            self.xpBar:EnableMouse(true)

            self.xpBarBg = self.xpBar:CreateTexture(nil, "BACKGROUND")
            self.xpBarBg:SetAllPoints(self.xpBar)
            self.xpBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self.xpBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.8)

            self.xpBarLeftBorder = self.xpBar:CreateTexture(nil, "OVERLAY", nil, 1)
            self.xpBarLeftBorder:SetTexture(self.texpath .. "border_half.tga")
            self.xpBarLeftBorder:SetPoint("RIGHT", self.xpBar, "CENTER", 1, 0)
            self.xpBarLeftBorder:SetWidth(203)
            self.xpBarLeftBorder:SetHeight(18)

            self.xpBarRightBorder = self.xpBar:CreateTexture(nil, "OVERLAY", nil, 1)
            self.xpBarRightBorder:SetTexture(self.texpath .. "border_half.tga")
            self.xpBarRightBorder:SetPoint("LEFT", self.xpBar, "CENTER", -1, 0)
            self.xpBarRightBorder:SetWidth(203)
            self.xpBarRightBorder:SetHeight(18)
            self.xpBarRightBorder:SetTexCoord(1, 0, 0, 1)
        end

        function Setup:XpBarText()
            self.xpBarText = self.xpBar:CreateFontString(nil, "OVERLAY")
            self.xpBarText:SetPoint("CENTER", self.xpBar, "CENTER", 0, 1)
            self.xpBarText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            self.xpBarText:Hide()
        end

        function Setup:UpdateXPBar()
            local currXP = UnitXP("player")
            local maxXP = UnitXPMax("player")
            local playerLevel = UnitLevel("player")
            local restXP = GetXPExhaustion()

            if playerLevel == 60 or not DFRL:GetTempDB("Xprep", "showXpBar") then
                self.xpBar:Hide()
            else
                self.xpBar:Show()
            end

            if maxXP == 0 then maxXP = 1 end
            self.xpBar:SetMinMaxValues(0, maxXP)
            self.xpBar:SetValue(currXP)

            if restXP and restXP > 0 then
                self.xpBar:SetStatusBarColor(0.2, 0.5, 0.9)
            else
                self.xpBar:SetStatusBarColor(0.85, 0.4, 0.85)
            end

            if self.xpBarText then
                local restPercent = 0
                if restXP and maxXP > 0 then
                    restPercent = math.floor((restXP / maxXP) * 100)
                end
                self.xpBarText:SetText(currXP .. " / " .. maxXP .. " (" .. restPercent .. "% rested)")
            end
        end

        function Setup:RepBar()
            self.repBar = CreateFrame("StatusBar", "DFRL_RepBar", UIParent)
            self.repBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 5)
            self.repBar:SetWidth(512)
            self.repBar:SetHeight(8)
            self.repBar:SetStatusBarTexture(self.texpath .. "main.tga")
            self.repBar:SetStatusBarColor(0, 0.6, 0.1)
            self.repBar:EnableMouse(true)

            self.repBarBg = self.repBar:CreateTexture(nil, "BACKGROUND")
            self.repBarBg:SetAllPoints(self.repBar)
            self.repBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self.repBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.8)

            self.repBarLeftBorder = self.repBar:CreateTexture(nil, "OVERLAY", nil, 1)
            self.repBarLeftBorder:SetTexture(self.texpath .. "border_half.tga")
            self.repBarLeftBorder:SetPoint("LEFT", self.repBar, "LEFT", -2, 0)
            self.repBarLeftBorder:SetWidth(203)
            self.repBarLeftBorder:SetHeight(18)

            self.repBarRightBorder = self.repBar:CreateTexture(nil, "OVERLAY", nil, 1)
            self.repBarRightBorder:SetTexture(self.texpath .. "border_half.tga")
            self.repBarRightBorder:SetPoint("RIGHT", self.repBar, "RIGHT", 2, 0)
            self.repBarRightBorder:SetWidth(203)
            self.repBarRightBorder:SetHeight(18)
            self.repBarRightBorder:SetTexCoord(1, 0, 0, 1)
        end

        function Setup:UpdateRepBar()
            local name, standing, min, max, value = GetWatchedFactionInfo()

            if name then
                self.repBar:Show()
                if max == min then max = min + 1 end
                self.repBar:SetMinMaxValues(min, max)
                self.repBar:SetValue(value)

                if standing == 1 then
                    -- hated - red
                    self.repBar:SetStatusBarColor(0.8, 0, 0)
                elseif standing == 2 then
                    -- hostile - red
                    self.repBar:SetStatusBarColor(0.8, 0, 0)
                elseif standing == 3 then
                    -- unfriendly - orange
                    self.repBar:SetStatusBarColor(0.8, 0.3, 0)
                elseif standing == 4 then
                    -- neutral - yellow
                    self.repBar:SetStatusBarColor(1, 0.82, 0)
                elseif standing == 5 then
                    -- friendly - light green
                    self.repBar:SetStatusBarColor(0.0, 0.6, 0.1)
                elseif standing == 6 then
                    -- honored - green
                    self.repBar:SetStatusBarColor(0, 0.7, 0.1)
                elseif standing == 7 then
                    -- revered - dark green
                    self.repBar:SetStatusBarColor(0, 0.8, 0.1)
                elseif standing == 8 then
                    -- exalted - teal
                    self.repBar:SetStatusBarColor(0, 0.8, 0.5)
                end

                if self.repBarText and self.repShowText then
                    local standingText = getglobal("FACTION_STANDING_LABEL"..standing)
                    self.repBarText:SetText(name .. " - " .. standingText .. " - " .. (value-min) .. "/" .. (max-min))
                    if not DFRL:GetTempDB("Xprep", "hoverRep") then
                        self.repBarText:Show()
                    end
                elseif self.repBarText then
                    self.repBarText:Hide()
                end
            else
                self.repBar:Hide()
                if self.repBarText then
                    self.repBarText:Hide()
                end
            end
        end

        function Setup:Run()
            Setup:BlizzardBars()
            Setup:XPBar()
            Setup:XpBarText()
            Setup:RepBar()
            Setup:UpdateRepBar()
        end

        --=================
        -- INIT
        --=================
        Setup:Run()

        --=================
        -- EXPOSE
        --=================
        DFRL.xpBar = Setup.xpBar
        DFRL.repBar = Setup.repBar

        --=================
        -- CALLBACKS
        --=================
        local callbacks = {}

        callbacks.showXpBar = function(value)
            if value then
                Setup.xpBar:Show()
            else
                Setup.xpBar:Hide()
            end
        end

        callbacks.xprepDarkMode = function(value)
            local intensity = DFRL:GetTempDB("Xprep", "xprepDarkMode") or 0
            local darkColor = {1 - intensity, 1 - intensity, 1 - intensity}
            local lightColor = {1, 1, 1}
            local color = (value and intensity > 0) and darkColor or lightColor

            if Setup.xpBarLeftBorder then
                Setup.xpBarLeftBorder:SetVertexColor(color[1], color[2], color[3])
            end
            if Setup.xpBarRightBorder then
                Setup.xpBarRightBorder:SetVertexColor(color[1], color[2], color[3])
            end

            if Setup.repBarLeftBorder then
                Setup.repBarLeftBorder:SetVertexColor(color[1], color[2], color[3])
            end
            if Setup.repBarRightBorder then
                Setup.repBarRightBorder:SetVertexColor(color[1], color[2], color[3])
            end
        end

        callbacks.barFont = function(value)
            local fontPath
            if value == "Expressway" then
                fontPath = Setup.fontpath .. "Expressway.ttf"
            elseif value == "Homespun" then
                fontPath = Setup.fontpath .. "Homespun.ttf"
            elseif value == "Hooge" then
                fontPath = Setup.fontpath .. "Hooge.ttf"
            elseif value == "Myriad-Pro" then
                fontPath = Setup.fontpath .. "Myriad-Pro.ttf"
            elseif value == "Prototype" then
                fontPath = Setup.fontpath .. "Prototype.ttf"
            elseif value == "PT-Sans-Narrow-Bold" then
                fontPath = Setup.fontpath .. "PT-Sans-Narrow-Bold.ttf"
            elseif value == "PT-Sans-Narrow-Regular" then
                fontPath = Setup.fontpath .. "PT-Sans-Narrow-Regular.ttf"
            elseif value == "RobotoMono" then
                fontPath = Setup.fontpath .. "RobotoMono.ttf"
            elseif value == "BigNoodleTitling" then
                fontPath = Setup.fontpath .. "BigNoodleTitling.ttf"
            elseif value == "Continuum" then
                fontPath = Setup.fontpath .. "Continuum.ttf"
            elseif value == "DieDieDie" then
                fontPath = Setup.fontpath .. "DieDieDie.ttf"
            else
                fontPath = "Fonts\\FRIZQT__.TTF"
            end

            if Setup.xpBarText then
                local _, size = Setup.xpBarText:GetFont()
                size = size or 10
                Setup.xpBarText:SetFont(fontPath, size, "OUTLINE")
            end
            if Setup.repBarText then
                local _, size = Setup.repBarText:GetFont()
                size = size or 9
                Setup.repBarText:SetFont(fontPath, size, "OUTLINE")
            end
        end

        callbacks.xpBarWidth = function(value)
            Setup.xpBar:SetWidth(value)
            Setup.xpBarLeftBorder:SetWidth(value / 2 + 3)
            Setup.xpBarRightBorder:SetWidth(value / 2 + 3)
        end

        callbacks.xpBarHeight = function(value)
            Setup.xpBar:SetHeight(value)
            Setup.xpBarLeftBorder:SetHeight(value + 9)
            Setup.xpBarRightBorder:SetHeight(value + 9)
        end

        callbacks.hoverXP = function(value)
            if value then
                Setup.xpBar:SetScript("OnEnter", function()
                    Setup.xpBarText:Show()
                end)
                Setup.xpBar:SetScript("OnLeave", function()
                    Setup.xpBarText:Hide()
                end)
                Setup.xpBarText:Hide()
            else
                Setup.xpBar:SetScript("OnEnter", nil)
                Setup.xpBar:SetScript("OnLeave", nil)
                if DFRL:GetTempDB("Xprep", "showXpText") then
                    Setup.xpBarText:Show()
                end
            end
        end

        callbacks.showXpOnGain = function(value)
            Setup.xpOnGainEnabled = value
            if value then
                Setup.xpBarText:Hide()
                Setup.xpOnGainTimer = 0
            else
                if DFRL:GetTempDB("Xprep", "showXpText") and not DFRL:GetTempDB("Xprep", "hoverXP") then
                    Setup.xpBarText:Show()
                end
            end
        end

        callbacks.xpBarTextSize = function(value)
            if Setup.xpBarText then
                local fontValue = DFRL:GetTempDB("Xprep", "barFont")
                local fontPath
                if fontValue == "Expressway" then
                    fontPath = Setup.fontpath .. "Expressway.ttf"
                elseif fontValue == "Homespun" then
                    fontPath = Setup.fontpath .. "Homespun.ttf"
                elseif fontValue == "Hooge" then
                    fontPath = Setup.fontpath .. "Hooge.ttf"
                elseif fontValue == "Myriad-Pro" then
                    fontPath = Setup.fontpath .. "Myriad-Pro.ttf"
                elseif fontValue == "Prototype" then
                    fontPath = Setup.fontpath .. "Prototype.ttf"
                elseif fontValue == "PT-Sans-Narrow-Bold" then
                    fontPath = Setup.fontpath .. "PT-Sans-Narrow-Bold.ttf"
                elseif fontValue == "PT-Sans-Narrow-Regular" then
                    fontPath = Setup.fontpath .. "PT-Sans-Narrow-Regular.ttf"
                elseif fontValue == "RobotoMono" then
                    fontPath = Setup.fontpath .. "RobotoMono.ttf"
                elseif fontValue == "BigNoodleTitling" then
                    fontPath = Setup.fontpath .. "BigNoodleTitling.ttf"
                elseif fontValue == "Continuum" then
                    fontPath = Setup.fontpath .. "Continuum.ttf"
                elseif fontValue == "DieDieDie" then
                    fontPath = Setup.fontpath .. "DieDieDie.ttf"
                else
                    fontPath = "Fonts\\FRIZQT__.TTF"
                end
                Setup.xpBarText:SetFont(fontPath, value, "OUTLINE")
            end
        end

        callbacks.showXpText = function(value)
            if value then
                local currXP = UnitXP("player")
                local maxXP = UnitXPMax("player")
                local restXP = GetXPExhaustion() or 0
                local restPercent = 0
                if maxXP > 0 then
                    restPercent = math.floor((restXP / maxXP) * 100)
                end
                Setup.xpBarText:SetText(currXP .. " / " .. maxXP .. " (" .. restPercent .. "% rested)")
                if not DFRL:GetTempDB("Xprep", "hoverXP") and not DFRL:GetTempDB("Xprep", "showXpOnGain") then
                    Setup.xpBarText:Show()
                else
                    Setup.xpBarText:Hide()
                end
            else
                Setup.xpBarText:Hide()
            end
        end

        callbacks.repBarWidth = function(value)
            Setup.repBar:SetWidth(value)
            Setup.repBarLeftBorder:SetWidth(value / 2 + 3)
            Setup.repBarRightBorder:SetWidth(value / 2 + 3)
        end

        callbacks.repBarHeight = function(value)
            Setup.repBar:SetHeight(value)
            Setup.repBarLeftBorder:SetHeight(value + 9)
            Setup.repBarRightBorder:SetHeight(value + 9)
        end

        callbacks.showRepText = function(value)
            if not Setup.repBarText and value then
                Setup.repBarText = Setup.repBar:CreateFontString(nil, "OVERLAY")
                Setup.repBarText:SetPoint("CENTER", Setup.repBar, "CENTER", 0, 1)
                Setup.repBarText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
                Setup.repBarText:Hide()
            end

            Setup.repShowText = value

            if Setup.repBarText then
                if value then
                    local name, standing, min, max, val = GetWatchedFactionInfo()
                    if name then
                        local standingText = getglobal("FACTION_STANDING_LABEL"..standing)
                        Setup.repBarText:SetText(name .. " - " .. standingText .. " - " .. (val-min) .. "/" .. (max-min))
                        if not DFRL:GetTempDB("Xprep", "hoverRep") then
                            Setup.repBarText:Show()
                        else
                            Setup.repBarText:Hide()
                        end
                    else
                        Setup.repBarText:Hide()
                    end
                else
                    Setup.repBarText:Hide()
                end
            end
        end

        callbacks.showRepOnGain = function(value)
            Setup.repOnGainEnabled = value
            if value then
                if Setup.repBarText then
                    Setup.repBarText:Hide()
                end
                Setup.repOnGainTimer = 0
            else
                if Setup.repBarText then
                    if DFRL:GetTempDB("Xprep", "showRepOnGain") then
                        Setup.repBarText:Show()
                    end
                end
            end
        end

        callbacks.repBarTextSize = function(value)
            if Setup.repBarText then
                local fontValue = DFRL:GetTempDB("Xprep", "barFont")
                local fontPath
                if fontValue == "Expressway" then
                    fontPath = Setup.fontpath .. "Expressway.ttf"
                elseif fontValue == "Homespun" then
                    fontPath = Setup.fontpath .. "Homespun.ttf"
                elseif fontValue == "Hooge" then
                    fontPath = Setup.fontpath .. "Hooge.ttf"
                elseif fontValue == "Myriad-Pro" then
                    fontPath = Setup.fontpath .. "Myriad-Pro.ttf"
                elseif fontValue == "Prototype" then
                    fontPath = Setup.fontpath .. "Prototype.ttf"
                elseif fontValue == "PT-Sans-Narrow-Bold" then
                    fontPath = Setup.fontpath .. "PT-Sans-Narrow-Bold.ttf"
                elseif fontValue == "PT-Sans-Narrow-Regular" then
                    fontPath = Setup.fontpath .. "PT-Sans-Narrow-Regular.ttf"
                elseif fontValue == "RobotoMono" then
                    fontPath = Setup.fontpath .. "RobotoMono.ttf"
                elseif fontValue == "BigNoodleTitling" then
                    fontPath = Setup.fontpath .. "BigNoodleTitling.ttf"
                elseif fontValue == "Continuum" then
                    fontPath = Setup.fontpath .. "Continuum.ttf"
                elseif fontValue == "DieDieDie" then
                    fontPath = Setup.fontpath .. "DieDieDie.ttf"
                else
                    fontPath = "Fonts\\FRIZQT__.TTF"
                end
                Setup.repBarText:SetFont(fontPath, value, "OUTLINE")
            end
        end

        callbacks.autoTrack = function(value)
            if not Setup.repBarTrackingFrame then
                Setup.repBarTrackingFrame = CreateFrame("Frame")
                Setup.repBarTrackingFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
                Setup.repBarTrackingFrame:SetScript("OnEvent", function()
                    if not Setup.repAutoTrack then return end
                    local startPos, endPos = string.find(arg1, "Your ", 1, true)
                    if startPos then
                        local restStart = string.find(arg1, " reputation has increased", endPos + 1, true)
                        if restStart then
                            local factionName = string.sub(arg1, endPos + 1, restStart - 1)

                            for i = 1, GetNumFactions() do
                                local name = GetFactionInfo(i)
                                if name == factionName then
                                    SetWatchedFactionIndex(i)
                                    Setup:UpdateRepBar()
                                    break
                                end
                            end
                        end
                    end
                end)
            end

            -- store
            Setup.repAutoTrack = value
        end

        callbacks.hoverRep = function(value)
            if Setup.repBarText then
                if value then
                    Setup.repBar:SetScript("OnEnter", function()
                        Setup.repBarText:Show()
                    end)
                    Setup.repBar:SetScript("OnLeave", function()
                        Setup.repBarText:Hide()
                    end)
                    Setup.repBarText:Hide()
                else
                    Setup.repBar:SetScript("OnEnter", nil)
                    Setup.repBar:SetScript("OnLeave", nil)
                    if DFRL:GetTempDB("Xprep", "showRepText") then
                        Setup.repBarText:Show()
                    end
                end
            end
        end

        --=================
        -- EVENT
        --=================
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_XP_UPDATE")
        f:RegisterEvent("PLAYER_LEVEL_UP")
        f:RegisterEvent("UPDATE_FACTION")
        f:RegisterEvent("UPDATE_EXHAUSTION")
        f:SetScript("OnEvent", function()
            Setup:UpdateXPBar()

            if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_FACTION" then
                Setup:UpdateRepBar()
            end

            -- XP gain logic
            if Setup.xpOnGainEnabled and event == "PLAYER_XP_UPDATE" then
                if Setup.xpBarText then
                    Setup.xpBarText:Show()
                    Setup.xpOnGainTimer = 5
                    f:SetScript("OnUpdate", function()
                        Setup.xpOnGainTimer = Setup.xpOnGainTimer - arg1
                        if Setup.xpOnGainTimer <= 0 then
                            Setup.xpBarText:Hide()
                            this:SetScript("OnUpdate", nil)
                            DFRL.activeScripts["XpGainTimerScript"] = false
                        else
                            DFRL.activeScripts["XpGainTimerScript"] = true
                        end
                    end)
                end
            end
        end)
        Setup:UpdateXPBar()
        DFRL:NewCallbacks("Xprep", callbacks)

        -- -- Apply hover setting after everything is initialized
        -- if DFRL:GetTempDB("Xprep", "hoverXP") then
        --     callbacks.hoverXP(true)
        -- end

        f2:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end)
end)
