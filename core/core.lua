-- mainframe
DFRL = CreateFrame("Frame", nil, UIParent)

-- tables
DFRL_PROFILES = {}
DFRL_DB_SETUP = {}
DFRL_CUR_PROFILE = {}
DFRL_FRAMEPOS = {}

DFRL.env = {}
DFRL.tools = {}
DFRL.hooks = {}
DFRL.tempDB = {}
DFRL.modules = {}
DFRL.defaults = {}
DFRL.profiles = {}
DFRL.callbacks = {}
DFRL.performance = {}
DFRL.activeScripts = {}
DFRL.gui = {}

-- db version
DFRL.DBversion = "1.0"

-- boot flag
local boot = false

-- utility
function DFRL:GetInfoOrCons(type)
    local name = "DragonflightReloaded"
    if type == "name" then
        return name
    elseif type == "version" then
        return GetAddOnMetadata(name, "Version")
    elseif type == "author" then
        return GetAddOnMetadata(name, "Author")
    elseif type == "path" then
        return "Interface\\AddOns\\" .. name .. "\\"
    elseif type == "media" then
        return "Interface\\AddOns\\" .. name .. "\\media\\"
    elseif type == "tex" then
        return "Interface\\AddOns\\" .. name .. "\\media\\tex\\"
    elseif type == "font" then
        return "Interface\\AddOns\\" .. name .. "\\media\\fnt\\"
    end
end

function DFRL:CheckAddon(name)
    if name == "ShaguTweaks" then
        self.addon1 = true
    elseif name == "ShaguTweaks-extras" then
        self.addon2 = true
    elseif name == "Bagshui" then
        self.addon3 = true
    end

    if IsAddOnLoaded("ShaguTweaks") then
        self.addon1 = true
    elseif IsAddOnLoaded("ShaguTweaks-extras") then
        self.addon2 = true
    elseif IsAddOnLoaded("Bagshui") then
        self.addon3 = true
    end
end

function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100DFRL: |r" .. tostring(msg))
end

DFRL.locales = {
    enUS = {},
    zhCN = {
        ["Welcome to |cffffd200Dragonflight:|r Reloaded."] = "欢迎使用 |cffffd200Dragonflight:|r 重制版。",
        ["Open menu via |cffddddddESC|r or |cffdddddd/df|r."] = "按 |cffddddddESC|r 或输入 |cffdddddd/df|r 打开菜单。",

        ["Addon Manager"] = "插件管理",
        ["|cFFFFD100Donation Rewards"] = "|cFFFFD100捐赠奖励",
        ["Video Options"] = "视频选项",
        ["Sound Options"] = "声音选项",
        ["UI Options"] = "界面选项",
        ["Key Bindings"] = "按键绑定",
        ["Macros"] = "宏",
        ["Logout"] = "注销",
        ["Exit Game"] = "退出游戏",
        ["Resume Game"] = "返回游戏",

        ["Language: English"] = "语言：英语",
        ["Language: Chinese"] = "语言：中文",
        ["Toggle Language"] = "切换语言",

        ["Okay"] = "确定",
        ["OK"] = "确定",
        ["Menu"] = "菜单",
        ["Light Mode"] = "亮色模式",
        ["Dark Mode"] = "暗色模式",

        ["|cFFFFFFFFWelcome to|r |cFFFFD700Dragonflight|r: |cFFFFFFFFReloaded|r |cFFFFD7002.0"] = "|cFFFFFFFF欢迎使用|r |cFFFFD700Dragonflight|r: |cFFFFFFFF重制版|r |cFFFFD7002.0",
        ["Tip:\nHold CTRL + SHIFT + ALT to move frames.\n\n\nBefore reporting bugs:\n|cffff6060Please disable all other addons|n except for Dragonflight: Reloaded.|r\n\n90% of bug reports lead to conflicts with other addons.\nThank you for helping us keep bug reports accurate.\n\nEnjoy |cFFFFD700Dragonflight|r and dont forget to update. "] =
            "提示：\n按住 CTRL + SHIFT + ALT 可移动框体。\n\n\n提交 Bug 前：\n|cffff6060请先禁用除 Dragonflight: Reloaded 之外的所有插件。|r\n\n90% 的 Bug 报告来自与其他插件冲突。\n感谢你帮助我们保持报告准确。\n\n祝你玩得开心，别忘了更新 |cFFFFD700Dragonflight|r。",

        ["Home"] = "主页",
        ["Info"] = "信息",
        ["Profiles"] = "配置",
        ["Modules"] = "模块",
        ["ShaguTweaks"] = "ShaguTweaks",
        ["Actionbars"] = "动作条",
        ["Bags"] = "背包",
        ["Castbar"] = "施法条",
        ["Chat"] = "聊天",
        ["Interface"] = "界面",
        ["Micromenu"] = "微型菜单",
        ["Minimap"] = "小地图",
        ["Third Party"] = "第三方",
        ["Unitframes"] = "单位框体",
        ["Xprep"] = "经验/声望条",

        ["Profile:"] = "配置：",
        ["FPS:"] = "帧率：",
        ["Current:"] = "当前：",
        ["Manage"] = "管理",
        ["Usage:\n\n\n1) new profile: create and switch to a new profile\n\n2) switch: change active profile\n\n3) copy: copies all settings into active profile\n\n4) delete: delete profile and switch back to default\n\n5)reset: reset active profile to the default settings\n\n\ndoes not affect shagutweaks\n\nBUG: DOUBLE CLICK DELETE AFTER NEW PROFILE\n\nBUG: ENTER PROFILE NAME STAYS"] =
            "用法：\n\n\n1）新建配置：创建并切换到新配置\n\n2）切换：更改当前启用的配置\n\n3）复制：把所选配置的所有设置复制到当前配置\n\n4）删除：删除所选配置并切回默认\n\n5）重置：把当前配置重置为默认设置\n\n\n不会影响 ShaguTweaks\n\n已知问题：新建配置后需要双击删除\n\n已知问题：输入配置名后文本不会消失",
        ["Switch"] = "切换",
        ["Copy"] = "复制",
        ["Delete"] = "删除",
        ["switched to %s"] = "已切换到 %s",
        ["profile copied from %s"] = "已从 %s 复制配置",
        ["%s deleted"] = "已删除 %s",

        ["LAST UPDATE WAS ON |CFFFF0000%s|r."] = "上次更新日期：|CFFFF0000%s|r。",
        ["Remember to update |cFFFFD100Dragonflight:|r Reloaded."] = "记得更新 |cFFFFD100Dragonflight:|r 重制版。",
        ["Days to remind again:"] = "下次提醒间隔（天）：",
        ["never"] = "从不",
        ["OK"] = "确定",
        ["N/A"] = "无",

        ["Addon Version:"] = "插件版本：",
        ["Database Version:"] = "数据库版本：",
        ["Last Update:"] = "上次更新：",
        ["Active Modules:"] = "启用模块：",
        ["Client Version:"] = "客户端版本：",
        ["Build Number:"] = "构建号：",
        ["Locale:"] = "语言环境：",
        ["Realm:"] = "服务器：",
        ["Installed"] = "已安装",
        ["Not installed"] = "未安装",
        ["Never"] = "从未",
        ["TOTAL:"] = "总计：",
        ["ON"] = "开",
        ["OFF"] = "关",

        ["|cffffd200Dragonflight:|r Movable mode enabled"] = "|cffffd200Dragonflight:|r 框体移动模式已开启",
        ["|cffffd200Dragonflight:|r Movable mode disabled"] = "|cffffd200Dragonflight:|r 框体移动模式已关闭",
        ["close"] = "关闭",
        ["min"] = "最小化",
        ["|cffffd200Dragonflight:|r Mode movable non disponible"] = "|cffffd200Dragonflight:|r 框体移动模式不可用",
        ["|cFFFFD100Dragonflight:|r Reloaded"] = "|cFFFFD100Dragonflight:|r 重制版",
        ["|cffff9999Horde"] = "|cffff9999部落",
        ["|cffddddddHorde"] = "|cffdddddd部落",
        ["|cff99ccffAlliance"] = "|cff99ccff联盟",
        ["|cffddddddAlliance"] = "|cffdddddd联盟",
    },
}

function DFRL:GetAddonLocale()
    local setting = DFRL_DB_SETUP and DFRL_DB_SETUP.language
    if setting and setting ~= "auto" then
        return setting
    end

    local loc = (GetLocale and GetLocale()) or "enUS"
    if loc == "zhCN" or loc == "zhTW" then
        return "zhCN"
    end

    return "enUS"
end

function DFRL:InitLocale()
    if not DFRL_DB_SETUP then
        DFRL_DB_SETUP = {}
    end
    if not DFRL_DB_SETUP.language then
        DFRL_DB_SETUP.language = "auto"
    end

    self.addonLocale = self:GetAddonLocale()
    self.env.LOCALE = self.addonLocale
end

function DFRL:TrText(text)
    if not text then
        return text
    end

    local locale = self.addonLocale or self:GetAddonLocale()
    if locale == "enUS" then
        return text
    end

    local map = self.locales and self.locales[locale]
    if map and map[text] then
        return map[text]
    end

    return text
end

function DFRL:TrKeyLabel(key)
    local pretty = string.gsub(key, "(%l)(%u)", "%1 %2")
    pretty = string.upper(string.sub(pretty, 1, 1)) .. string.sub(pretty, 2)

    local locale = self.addonLocale or self:GetAddonLocale()
    if locale ~= "zhCN" then
        return pretty
    end

    local dict = {
        show = "显示",
        hide = "隐藏",
        enable = "启用",
        enabled = "启用",
        disable = "禁用",
        disabled = "禁用",
        toggle = "切换",
        mode = "模式",
        dark = "暗色",
        light = "亮色",
        font = "字体",
        size = "大小",
        scale = "缩放",
        alpha = "透明度",
        width = "宽度",
        height = "高度",
        color = "颜色",
        colour = "颜色",
        text = "文字",
        time = "时间",
        spacing = "间距",
        buttons = "按钮",
        button = "按钮",
        bar = "条",
        bars = "条",
        frame = "框体",
        minimap = "小地图",
        chat = "聊天",
        tooltip = "提示",
        target = "目标",
        player = "玩家",
        bags = "背包",
        bag = "背包",
        map = "地图",
        range = "距离",
        indicator = "指示器",
        x = "X",
        y = "Y",
        fps = "帧率",
        xp = "经验",
        rep = "声望",
        xprep = "经验条",
    }

    local parts = {}
    local mappedAny = false
    for word in string.gfind(pretty, "%S+") do
        local lower = string.lower(word)
        local mapped = dict[lower]
        if mapped then
            mappedAny = true
            table.insert(parts, mapped)
        else
            table.insert(parts, word)
        end
    end

    if mappedAny then
        return table.concat(parts, "")
    end

    return pretty
end

function DFRL:SetAddonLanguage(lang)
    if not DFRL_DB_SETUP then
        DFRL_DB_SETUP = {}
    end
    DFRL_DB_SETUP.language = lang or "auto"
    ReloadUI()
end

function DFRL:ToggleAddonLanguage()
    local cur = DFRL_DB_SETUP and DFRL_DB_SETUP.language or "auto"
    if cur == "zhCN" then
        self:SetAddonLanguage("enUS")
    else
        self:SetAddonLanguage("zhCN")
    end
end

-- environment
function DFRL:GetEnv()
    self.env._G = getfenv(0)
    self.env.T = self.tools
    return self.env
end

setmetatable(DFRL.env, { __index = getfenv(0) })

-- modules
function DFRL:NewDefaults(mod, defaults)
    if not self.defaults[mod] then
        self.defaults[mod] = {}
    end

    local count = 0
    for key, value in pairs(defaults) do
        self.defaults[mod][key] = value
        count = count + 1
    end
end

function DFRL:NewMod(name, prio, func)
    if self.modules[name] then return end
    self.modules[name] = { func = func, priority = prio }
end

function DFRL:RunMods()
    local list = {}
    for name, data in pairs(self.modules) do
        tinsert(list, { name = name, func = data.func, priority = data.priority })
    end

    table.sort(list, function(a, b) return a.priority < b.priority end)

    for i = 1, table.getn(list) do
        local name = list[i].name
        local func = list[i].func
        local enabled = self.tempDB[name] and self.tempDB[name].enabled
        if enabled == true then
            collectgarbage()
            local start = GetTime()
            local mem = gcinfo()
            setfenv(func, self:GetEnv())
            local success, err = pcall(func)
            if success then
                self.performance[name] = {
                    time = GetTime() - start,
                    memory = gcinfo() - mem
                }
            else
                geterrorhandler()(err)
            end
        end
    end
end

-- database
function DFRL:InitTempDB()
    self:VersionCheckDB()

    -- set default profile if none exists
    local char = UnitName("player")

    if not DFRL_CUR_PROFILE[char] then
        DFRL_CUR_PROFILE[char] = "Default"
    end

    local cur = DFRL_CUR_PROFILE[char]

    -- ensure profile exists
    if not DFRL_PROFILES[cur] then
        DFRL_PROFILES[cur] = {}
    end

    local settings = 0
    local defaults = 0

    -- copy existing module settings from current profile
    for mod, tbl in pairs(DFRL_PROFILES[cur]) do
        if type(tbl) == "table" then
            self.tempDB[mod] = self.tempDB[mod] or {}
            for key, value in pairs(tbl) do
                self.tempDB[mod][key] = value
                settings = settings + 1
            end
        end
    end

    -- add missing defaults
    for mod, def in pairs(self.defaults) do
        self.tempDB[mod] = self.tempDB[mod] or {}
        for key, val in pairs(def) do
            if self.tempDB[mod][key] == nil then
                self.tempDB[mod][key] = val[1]
                defaults = defaults + 1
            end
        end
    end
end

function DFRL:VersionCheckDB()
    if not DFRL_DB_SETUP.version or DFRL_DB_SETUP.version ~= self.DBversion then
        DFRL_PROFILES = {}
        DFRL_DB_SETUP = {}
        DFRL_CUR_PROFILE = {}
        DFRL_DB_SETUP.version = self.DBversion
        print("Version mismatch - wiping all DFRL DB's")
    end
end

function DFRL:SetTempDB(mod, key, value)
    self.tempDB[mod][key] = value
    local cb = mod .. "_" .. key .. "_changed"
    self:TriggerCallback(cb, value)
end

function DFRL:SetTempDBNoCallback(mod, key, value)
    if not self.tempDB[mod] then
        self.tempDB[mod] = {}
    end
    self.tempDB[mod][key] = value
end

-- will be replaceed by new
-- gettempDB after test phase
function DFRL:GetTempValue(name, key)
    if not self.tempDB[name] then
        return nil
    end

    return self.tempDB[name][key]
end

function DFRL:GetTempDB(mod, key)
    return self.tempDB[mod][key]
end

function DFRL:SaveTempDB()
    local count = 0
    for _, _ in pairs(self.tempDB) do
        count = count + 1
    end

    local char = UnitName("player")
    local cur = DFRL_CUR_PROFILE[char] or "Default"

    DFRL_PROFILES[cur] = self.tempDB
    DFRL_DB_SETUP.version = self.DBversion
end

function DFRL:ResetDB()
    self.tempDB = {}
    DFRL_PROFILES = {}
    DFRL_DB_SETUP = {}
    DFRL_CUR_PROFILE = {}
    DFRL_DB_SETUP.version = self.DBversion
    ReloadUI()
end

-- profiles
function DFRL:CreateProfile(name)
    DFRL_PROFILES[name] = {}
    for mod, def in pairs(self.defaults) do
        DFRL_PROFILES[name][mod] = {}
        for key, value in pairs(def) do
            DFRL_PROFILES[name][mod][key] = value[1]
        end
    end
end

function DFRL:SwitchProfile(name)
    local char = UnitName("player")
    local old = DFRL_CUR_PROFILE[char]
    DFRL_PROFILES[old] = self.tempDB
    DFRL_CUR_PROFILE[char] = name
    self:LoadProfile(name)
end

function DFRL:CopyProfile(from, tbl)
    local src
    if tbl then
        src = tbl
    else
        src = DFRL_PROFILES[from]
    end
    self.tempDB = {}
    for mod, data in pairs(src) do
        self.tempDB[mod] = {}
        for key, value in pairs(data) do
            self.tempDB[mod][key] = value
        end
    end
end

function DFRL:LoadProfile(name)
    self.tempDB = {}
    for mod, data in pairs(DFRL_PROFILES[name]) do
        self.tempDB[mod] = {}
        for key, value in pairs(data) do
            self.tempDB[mod][key] = value
        end
    end
end

function DFRL:DeleteProfile(name)
    DFRL_PROFILES[name] = nil
end

-- callbacks
function DFRL:NewCallbacks(mod, callbacks)
    local count = 0
    for key, func in pairs(callbacks) do
        local cb = mod .. "_" .. key .. "_changed"

        self.callbacks[cb] = {}
        tinsert(self.callbacks[cb], func)

        self:TriggerCallback(cb, self.tempDB[mod][key])

        count = count + 1
    end
end

function DFRL:TriggerCallback(cb, value)
    for _, func in ipairs(self.callbacks[cb]) do
        func(value)
    end
end

function DFRL:TriggerAllCallbacks()
    for cb, callbacks in pairs(self.callbacks) do
        local name = string.gsub(cb, "_changed$", "")
        local pos = string.find(name, "_[^_]*$")
        local mod = string.sub(name, 1, pos - 1)
        local key = string.sub(name, pos + 1)
        local value = self.tempDB[mod] and self.tempDB[mod][key]

        for _, func in ipairs(callbacks) do
            func(value)
        end
    end
end

-- init handler
DFRL:RegisterEvent("ADDON_LOADED")
DFRL:RegisterEvent("PLAYER_LOGOUT")
DFRL:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        DFRL:CheckAddon(arg1)
    end
    if event == "ADDON_LOADED" and arg1 == "DragonflightReloaded" then
        if boot then return end
        DFRL:InitTempDB()
        DFRL:InitLocale()
        DFRL:RunMods()
        print(DFRL:TrText("Welcome to |cffffd200Dragonflight:|r Reloaded."))
        print(DFRL:TrText("Open menu via |cffddddddESC|r or |cffdddddd/df|r."))
    end
    if event == "PLAYER_LOGOUT" then
        DFRL:SaveTempDB()
    end
end)
