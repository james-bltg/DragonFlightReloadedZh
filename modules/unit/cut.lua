DFRL:NewDefaults("Cut-Out", {
    enabled = {true},
})

DFRL:NewMod("Cut-Out", 1, function()
    --=================
    -- SETUP
    --=================
    local Setup = {
        texpath = DFRL:GetInfoOrCons("tex") .. "unitframes\\",
        fadingFrames = {},
        fadeDuration = 0.5,
        textureAlpha = 0.7,
        textures = {
            health = "healthDF2.tga",
            mana = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status.tga"
        },
        unitFrames = {
            {PlayerFrameHealthBar, "health", "player"},
            {PlayerFrameManaBar, "mana", "player"},
            {TargetFrameHealthBar, "health", "target"},
            {TargetFrameManaBar, "mana", "target"},
            {TargetofTargetHealthBar, "health", "targettarget"},
            {TargetofTargetManaBar, "mana", "targettarget"}
        }
    }

    function Setup:CreateCutoutFrame(statusBar, barType, unit)
        local cutoutFrame = CreateFrame("Frame", nil, statusBar)
        cutoutFrame:SetFrameLevel(statusBar:GetFrameLevel() + 1)
        cutoutFrame:SetAllPoints(statusBar)

        local cutoutTexture = cutoutFrame:CreateTexture(nil, "OVERLAY")
        cutoutTexture:SetTexture(self.texpath .. self.textures[barType])
        cutoutTexture:SetVertexColor(1, 1, 1, self.textureAlpha)
        cutoutTexture:SetAllPoints(cutoutFrame)
        cutoutTexture:Hide()

        cutoutFrame.texture = cutoutTexture
        cutoutFrame.barType = barType
        cutoutFrame.unit = unit
        cutoutFrame.lastValue = nil
        cutoutFrame.initialized = false

        return cutoutFrame
    end

    function Setup:UpdateCutoutEffect(frame, unit)
        if UnitIsDead(unit) or UnitIsGhost(unit) then
            return
        end

        local currentValue, maxValue
        if frame.barType == "health" then
            currentValue, maxValue = UnitHealth(unit), UnitHealthMax(unit)
        else
            currentValue, maxValue = UnitMana(unit), UnitManaMax(unit)
        end

        if maxValue == 0 then
            return
        end

        if not frame.initialized then
            frame.lastValue = currentValue
            frame.initialized = true
            return
        end

        if currentValue >= frame.lastValue then
            frame.lastValue = currentValue
            return
        end

        local lostAmount = frame.lastValue - currentValue
        self:TriggerCutoutAnimation(frame, lostAmount, currentValue, maxValue)
        frame.lastValue = currentValue
    end

    function Setup:TriggerCutoutAnimation(frame, lostAmount, currentValue, maxValue)
        local statusBar = frame:GetParent()
        local width = statusBar:GetWidth()
        local xOffset = width * currentValue / maxValue
        local cutoutWidth = width * lostAmount / maxValue

        frame.texture:ClearAllPoints()
        frame.texture:SetPoint("TOPLEFT", statusBar, "TOPLEFT", xOffset, 0)
        frame.texture:SetPoint("BOTTOMLEFT", statusBar, "BOTTOMLEFT", xOffset, 0)
        frame.texture:SetWidth(cutoutWidth)
        frame.texture:Show()

        frame.fadeStart = GetTime()
        table.insert(self.fadingFrames, frame)
    end

    function Setup:ProcessFadeAnimations()
        local currentTime = GetTime()
        local i = 1
        while i <= table.getn(self.fadingFrames) do
            local frame = self.fadingFrames[i]
            local elapsed = currentTime - frame.fadeStart

            if elapsed >= self.fadeDuration then
                frame.texture:Hide()
                table.remove(self.fadingFrames, i)
            else
                frame.texture:SetAlpha(1 - elapsed / self.fadeDuration)
                i = i + 1
            end
        end
    end

    function Setup:HookUnitFrame(frameBar, barType, unit)
        if frameBar and not frameBar.cutoutFrame then
            frameBar.cutoutFrame = self:CreateCutoutFrame(frameBar, barType, unit)
            frameBar:SetScript("OnValueChanged", function()
                Setup:UpdateCutoutEffect(frameBar.cutoutFrame, unit)
            end)
        end
    end

    function Setup:ClearTargetCutouts()
        local i = 1
        while i <= table.getn(self.fadingFrames) do
            local frame = self.fadingFrames[i]
            if frame.unit == 'target' then
                frame.texture:Hide()
                table.remove(self.fadingFrames, i)
            else
                i = i + 1
            end
        end
    end

    function Setup:InitializeCutouts()
        for i = 1, table.getn(self.unitFrames) do
            local frameData = self.unitFrames[i]
            self:HookUnitFrame(frameData[1], frameData[2], frameData[3])
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:SetScript("OnEvent", function()
        if event == "PLAYER_ENTERING_WORLD" then
            Setup:InitializeCutouts()
            f:SetScript("OnUpdate", function()
                Setup:ProcessFadeAnimations()
            end)
            f:UnregisterEvent("PLAYER_ENTERING_WORLD")
        elseif event == "PLAYER_TARGET_CHANGED" then
            Setup:ClearTargetCutouts()
            if TargetFrameHealthBar and TargetFrameHealthBar.cutoutFrame then
                TargetFrameHealthBar.cutoutFrame.initialized = false
                TargetFrameHealthBar.cutoutFrame.lastValue = nil
            end
            if TargetFrameManaBar and TargetFrameManaBar.cutoutFrame then
                TargetFrameManaBar.cutoutFrame.initialized = false
                TargetFrameManaBar.cutoutFrame.lastValue = nil
            end
            if TargetofTargetHealthBar and TargetofTargetHealthBar.cutoutFrame then
                TargetofTargetHealthBar.cutoutFrame.initialized = false
                TargetofTargetHealthBar.cutoutFrame.lastValue = nil
            end
            if TargetofTargetManaBar and TargetofTargetManaBar.cutoutFrame then
                TargetofTargetManaBar.cutoutFrame.initialized = false
                TargetofTargetManaBar.cutoutFrame.lastValue = nil
            end
        end
    end)
end)
