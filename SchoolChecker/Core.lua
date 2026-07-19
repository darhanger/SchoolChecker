local ADDON_NAME = "SchoolChecker";
local PLAYER_UNIT = "player";
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 350, 100;
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark";

local bit_band = bit.band;
local CreateFrame = CreateFrame;
local GetAddOnMetadata = GetAddOnMetadata;
local GetLocale = GetLocale;
local GetSpellInfo = GetSpellInfo;
local GameTooltip = GameTooltip;
local UnitGUID = UnitGUID;
local UnitName = UnitName;
local lua_type = type;
local math_floor = math.floor;
local string_format = string.format;
local table_concat = table.concat;

SchoolChecker = SchoolChecker or {};
local SchoolChecker = SchoolChecker;
SchoolChecker.version = GetAddOnMetadata(ADDON_NAME, "Version");

local database;

local function InitializeDatabase()
    if lua_type(SchoolChecker_DB) ~= "table" then
        SchoolChecker_DB = {};
    end

    database = SchoolChecker_DB;
    database.locked = database.locked == true;
end

local DAMAGE_FORMAT;
local LOCKED_MESSAGE;
local UNLOCKED_MESSAGE;
local UNKNOWN_SCHOOL;
local UNKNOWN_SPELL;
local SCHOOL_DISPLAY = {};

-- Build every possible 7-bit school mask once; combat events only perform lookups.
do
    local schoolNames;
    local specialNames;

    if GetLocale() == "ruRU" then
        DAMAGE_FORMAT = "|cff00ff00Урон от:|r |T%s:14:14|t |cffffffff|Hspell:%d|h[%s]|h (ID: %d)|r - ШКОЛА: %s ";
        LOCKED_MESSAGE = "SchoolChecker: окно заблокировано";
        UNLOCKED_MESSAGE = "SchoolChecker: окно разблокировано";
        UNKNOWN_SCHOOL = "|cffff0000Неизвестно|r";
        UNKNOWN_SPELL = "Неизвестное заклинание";

        schoolNames = {
            "Физический",
            "Свет",
            "Огонь",
            "Природа",
            "Лёд",
            "Тьма",
            "Тайная магия",
        };

        specialNames = {
            [3]   = "Священный удар",
            [5]   = "Пламенный удар",
            [6]   = "Священный огонь",
            [9]   = "Удар бури",
            [10]  = "Священная буря",
            [12]  = "Огненная буря",
            [17]  = "Ледяной удар",
            [20]  = "Ледяной огонь",
            [24]  = "Ледяная буря",
            [28]  = "Стихии",
            [33]  = "Теневой удар",
            [34]  = "Сумерки",
            [36]  = "Тёмное пламя",
            [40]  = "Чума",
            [49]  = "Тёмный лёд",
            [66]  = "Божественная магия",
            [68]  = "Чародейский огонь",
            [72]  = "Чародейская буря",
            [80]  = "Чародейский лёд",
            [96]  = "Чародейская тьма",
            [126] = "Магия",
            [127] = "Хаос",
        };
    else
        DAMAGE_FORMAT = "|cff00ff00Damage from:|r |T%s:14:14|t |cffffffff|Hspell:%d|h[%s]|h (ID: %d)|r - SCHOOL: %s ";
        LOCKED_MESSAGE = "SchoolChecker: Locked";
        UNLOCKED_MESSAGE = "SchoolChecker: Unlocked";
        UNKNOWN_SCHOOL = "|cffff0000Unknown|r";
        UNKNOWN_SPELL = "Unknown spell";

        schoolNames = {
            "Physical",
            "Holy",
            "Fire",
            "Nature",
            "Frost",
            "Shadow",
            "Arcane",
        };

        specialNames = {
            [3]   = "Holystrike",
            [5]   = "Flamestrike",
            [6]   = "Holyfire",
            [9]   = "Stormstrike",
            [10]  = "Holystorm",
            [12]  = "Firestorm",
            [17]  = "Froststrike",
            [20]  = "Frostfire",
            [24]  = "Froststorm",
            [28]  = "Elemental",
            [33]  = "Shadowstrike",
            [34]  = "Twilight",
            [36]  = "Shadowflame",
            [40]  = "Plague",
            [49]  = "Shadowfrost",
            [66]  = "Divine",
            [68]  = "Spellfire",
            [72]  = "Spellstorm",
            [80]  = "Spellfrost",
            [96]  = "Spellshadow",
            [126] = "Magic",
            [127] = "Chaos",
        };
    end

    local schoolColors = {
        "fff2f2b0",
        "ffffcc00",
        "ffff4444",
        "ff33ff33",
        "ff00ccff",
        "ff6666ff",
        "ffcc66ff",
    };

    local specialColors = {
        [3]   = "fff8df58",
        [5]   = "fff89b7a",
        [6]   = "ffff8822",
        [9]   = "ff92f871",
        [10]  = "ff99e519",
        [12]  = "ff99a13b",
        [17]  = "ff79dfd7",
        [20]  = "ff7f88a1",
        [24]  = "ff19e599",
        [28]  = "ff66af7c",
        [33]  = "ffacacd7",
        [34]  = "ffb2997f",
        [36]  = "ffb255a1",
        [40]  = "ff4cb299",
        [49]  = "ff72b6e4",
        [66]  = "ffe5997f",
        [68]  = "ffe555a1",
        [72]  = "ff7fb299",
        [80]  = "ff6699ff",
        [96]  = "ff9966ff",
        [126] = "ff9ea897",
        [127] = "ff909b93",
    };

    local coloredSchools = {};
    local parts = {};

    for index = 1, 7 do
        coloredSchools[index] = string_format("|c%s%s|r", schoolColors[index], schoolNames[index]);
    end

    SCHOOL_DISPLAY[0] = UNKNOWN_SCHOOL;

    for mask = 1, 127 do
        local count = 0;
        local flag = 1;

        for index = 1, 7 do
            if bit_band(mask, flag) ~= 0 then
                count = count + 1;
                parts[count] = coloredSchools[index];
            end

            flag = flag * 2;
        end

        local expanded = table_concat(parts, " + ", 1, count);
        local specialName = specialNames[mask];

        if specialName then
            SCHOOL_DISPLAY[mask] = string_format(
                "|c%s%s|r (%s)",
                specialColors[mask],
                specialName,
                expanded
            );
        else
            SCHOOL_DISPLAY[mask] = expanded;
        end
    end
end

-- Messages are immutable, so one entry per spell/school pair avoids repeat formatting.
local messageCache = {};

local function GetDamageMessage(spellId, spellName, spellSchool)
    if not spellId then
        return nil;
    end

    local schoolText = SCHOOL_DISPLAY[spellSchool];
    if not schoolText then
        spellSchool = 0;
        schoolText = UNKNOWN_SCHOOL;
    end

    local cacheKey = spellId * 128 + spellSchool;
    local message = messageCache[cacheKey];

    if message then
        return message;
    end

    local localizedName, _, icon = GetSpellInfo(spellId);
    message = string_format(
        DAMAGE_FORMAT,
        icon or UNKNOWN_ICON,
        spellId,
        spellName or localizedName or UNKNOWN_SPELL,
        spellId,
        schoolText
    );
    messageCache[cacheKey] = message;

    return message;
end

local frame = CreateFrame("ScrollingMessageFrame", nil, UIParent);
local frameAddMessage = frame.AddMessage;
frame:Hide();
frame:SetMovable(true);
frame:EnableMouse(true);
if frame.SetHyperlinksEnabled then
    frame:SetHyperlinksEnabled(true);
end
frame:SetResizable(true);
frame:RegisterForDrag("LeftButton");
frame:SetClampedToScreen(true);
frame:SetWidth(DEFAULT_WIDTH);
frame:SetHeight(DEFAULT_HEIGHT);
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    insets = { left = -5, right = -5, top = -5, bottom = -5 },
});
frame:SetBackdropColor(0, 0, 0, 1);
frame:SetFontObject("CombatLogFont");
frame:SetTimeVisible(10);
frame:SetFadeDuration(5);
frame:SetFading(false);
frame:SetAlpha(1);

local _, lineHeight = CombatLogFont:GetFont();
if not lineHeight or lineHeight <= 0 then
    lineHeight = 14;
end

local currentMaxLines = 0;

local function UpdateMaxLines(self, _, height)
    height = height or self:GetHeight();

    local maxLines = math_floor(height / lineHeight);
    if maxLines < 1 then
        maxLines = 1;
    end

    if maxLines ~= currentMaxLines then
        currentMaxLines = maxLines;
        self:SetMaxLines(maxLines);
    end
end

local function SaveGeometry()
    local point, _, relativePoint, xOffset, yOffset = frame:GetPoint(1);

    database.point = point;
    database.relativePoint = relativePoint;
    database.x = xOffset;
    database.y = yOffset;
    database.width = frame:GetWidth();
    database.height = frame:GetHeight();
end

local resizeHandleRight;
local resizeHandleLeft;

local function UpdateResizeHandles()
    if database.locked then
        resizeHandleRight:Hide();
        resizeHandleLeft:Hide();
    else
        resizeHandleRight:Show();
        resizeHandleLeft:Show();
    end
end

local function FrameOnDragStart(self)
    if not database.locked then
        self:StartMoving();
    end
end

local function FrameOnDragStop(self)
    self:StopMovingOrSizing();

    if not database.locked then
        SaveGeometry();
    end
end

local function FrameOnMouseUp(_, button)
    if button ~= "RightButton" then
        return;
    end

    database.locked = not database.locked;
    UpdateResizeHandles();
    DEFAULT_CHAT_FRAME:AddMessage(database.locked and LOCKED_MESSAGE or UNLOCKED_MESSAGE);
end

local function FrameOnHyperlinkClick(self, link, _, button)
    if not link or (button and button ~= "LeftButton") then
        return;
    end

    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

local function FrameOnHyperlinkLeave(self)
    if GameTooltip:IsOwned(self) then
        GameTooltip:Hide();
    end
end

local function ResizeHandleOnMouseDown(self, button)
    if button == "LeftButton" and not database.locked then
        frame:StartSizing(self.resizePoint);
    end
end

local function ResizeHandleOnMouseUp(_, button)
    if button == "LeftButton" then
        frame:StopMovingOrSizing();

        if not database.locked then
            SaveGeometry();
        end
    end
end

local resizeFrameLevel = frame:GetFrameLevel() + 10;

local function CreateResizeHandle(point, texture, xOffset)
    local handle = CreateFrame("Button", nil, frame);
    handle.resizePoint = point;
    handle:SetFrameLevel(resizeFrameLevel);
    handle:SetNormalTexture(texture);
    handle:SetHighlightTexture(texture);
    handle:SetWidth(16);
    handle:SetHeight(16);
    handle:SetPoint(point, frame, point, xOffset, -5);
    handle:EnableMouse(true);
    handle:SetScript("OnMouseDown", ResizeHandleOnMouseDown);
    handle:SetScript("OnMouseUp", ResizeHandleOnMouseUp);

    return handle;
end

resizeHandleRight = CreateResizeHandle(
    "BOTTOMRIGHT",
    "Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripRight",
    5
);
resizeHandleLeft = CreateResizeHandle(
    "BOTTOMLEFT",
    "Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripLeft",
    -5
);

frame:SetScript("OnDragStart", FrameOnDragStart);
frame:SetScript("OnDragStop", FrameOnDragStop);
frame:SetScript("OnMouseUp", FrameOnMouseUp);
frame:SetScript("OnHyperlinkClick", FrameOnHyperlinkClick);
frame:SetScript("OnHyperlinkLeave", FrameOnHyperlinkLeave);
frame:SetScript("OnSizeChanged", UpdateMaxLines);
UpdateMaxLines(frame, nil, frame:GetHeight());

local VALID_POINTS = {
    TOPLEFT = true,
    TOP = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOMLEFT = true,
    BOTTOM = true,
    BOTTOMRIGHT = true,
};

function SchoolChecker:EnableFrame(targetFrame)
    local width = database.width;
    local height = database.height;

    if lua_type(width) == "number" and width > 0 then
        targetFrame:SetWidth(width);
    else
        targetFrame:SetWidth(DEFAULT_WIDTH);
    end

    if lua_type(height) == "number" and height > 0 then
        targetFrame:SetHeight(height);
    else
        targetFrame:SetHeight(DEFAULT_HEIGHT);
    end

    targetFrame:ClearAllPoints();

    local point = database.point;
    local xOffset = database.x;
    local yOffset = database.y;

    if VALID_POINTS[point] and lua_type(xOffset) == "number" and lua_type(yOffset) == "number" then
        local relativePoint = database.relativePoint;
        if not VALID_POINTS[relativePoint] then
            relativePoint = point;
        end

        targetFrame:SetPoint(point, UIParent, relativePoint, xOffset, yOffset);
    else
        targetFrame:SetPoint("CENTER", UIParent, "CENTER", -160, -220);
    end

    UpdateResizeHandles();
    targetFrame:Show();
end

local playerGUID;
local playerName;

local function UpdatePlayerIdentity()
    playerGUID = UnitGUID(PLAYER_UNIT);
    playerName = UnitName(PLAYER_UNIT);
end

function SchoolChecker:OnEvent(
    event,
    arg1,
    eventType,
    _sourceGUID,
    _sourceName,
    _sourceFlags,
    destGUID,
    destName,
    _destFlags,
    spellId,
    spellName,
    spellSchool
)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if eventType ~= "SPELL_DAMAGE" and eventType ~= "SPELL_PERIODIC_DAMAGE" then
            return;
        end

        if playerGUID then
            if destGUID ~= playerGUID then
                return;
            end
        elseif not playerName or destName ~= playerName then
            return;
        end

        local message = GetDamageMessage(spellId, spellName, spellSchool);
        if message then
            frameAddMessage(frame, message);
        end

        return;
    end

    if event == "PLAYER_ENTERING_WORLD" then
        UpdatePlayerIdentity();
        return;
    end

    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        frame:UnregisterEvent("ADDON_LOADED");
        InitializeDatabase();
        UpdatePlayerIdentity();
        SchoolChecker:EnableFrame(frame);
    end
end

frame:SetScript("OnEvent", SchoolChecker.OnEvent);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
