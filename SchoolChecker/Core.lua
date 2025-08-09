SchoolChecker = SchoolChecker or {};
SchoolChecker.version = GetAddOnMetadata("SchoolChecker", "Version");
local localization = GetLocale();
local ru = localization == "ruRU" or false;

SchoolChecker_DB = SchoolChecker_DB or {
    locked = false,
};

local uiScale = GetCVar("uiScale") or 1;
local backdrop = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    insets = { left = -5, right = -5, top = -5, bottom = -5 }
};

local frame = CreateFrame("ScrollingMessageFrame", nil, UIParent);
frame:SetFont("Interface\\AddOns\\SchoolChecker\\fonts\\FRIZQT__.TTF", 18, "OUTLINE");
frame:SetMovable(true);
frame:EnableMouse(true);
frame:SetResizable(true);
-- frame:SetFrameStrata("HIGH");
frame:RegisterForDrag("LeftButton");
frame:SetClampedToScreen(true);

frame:SetScript("OnDragStart", function(self)
    if not SchoolChecker_DB.locked then
        self:StartMoving();
    end
end);

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing();

    local point, _, relativePoint, xOfs, yOfs = self:GetPoint();
    SchoolChecker_DB.point = point;
    SchoolChecker_DB.relativePoint = relativePoint;
    SchoolChecker_DB.x = xOfs;
    SchoolChecker_DB.y = yOfs;
end);

frame:SetWidth(350);
frame:SetHeight(100);
frame:SetBackdrop(backdrop);
frame:SetBackdropColor(0, 0, 0, 1);
frame:SetFontObject("CombatLogFont");
frame:SetTimeVisible(10);
frame:SetFadeDuration(5);
frame:SetMaxLines(7);
frame:SetFading(false);
frame:SetAlpha(1);
frame:Show();

local resizeHandleRight = CreateFrame("Button", nil, frame);
resizeHandleRight:Show();
resizeHandleRight:SetFrameLevel(frame:GetFrameLevel() + 10);
resizeHandleRight:SetNormalTexture("Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripRight");
resizeHandleRight:SetHighlightTexture("Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripRight");
resizeHandleRight:SetWidth(16);
resizeHandleRight:SetHeight(16);
resizeHandleRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5);
resizeHandleRight:EnableMouse(true);

resizeHandleRight:SetScript("OnMouseDown", function(self, button)
    if not SchoolChecker_DB.locked and button == "LeftButton" then
        frame.isResizing = true;
        frame:StartSizing("BOTTOMRIGHT");
    end;
end);

resizeHandleRight:SetScript("OnMouseUp", function(self, button)
    if frame.isResizing == true then
        frame:StopMovingOrSizing();

        SchoolChecker_DB.width = frame:GetWidth();
        SchoolChecker_DB.height = frame:GetHeight();
        frame.isResizing = false;
    end
end);

local resizeHandleLeft = CreateFrame("Button", nil, frame);
resizeHandleLeft:Show();
resizeHandleLeft:SetFrameLevel(frame:GetFrameLevel() + 10);
resizeHandleLeft:SetNormalTexture("Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripLeft");
resizeHandleLeft:SetHighlightTexture("Interface\\AddOns\\SchoolChecker\\textures\\ResizeGripLeft");
resizeHandleLeft:SetWidth(16);
resizeHandleLeft:SetHeight(16);
resizeHandleLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -5, -5);
resizeHandleLeft:EnableMouse(true);

resizeHandleLeft:SetScript("OnMouseDown", function(self, button)
    if not SchoolChecker_DB.locked and button == "LeftButton" then
        frame.isResizing = true;
        frame:StartSizing("BOTTOMLEFT");
    end
end);

resizeHandleLeft:SetScript("OnMouseUp", function(self, button)
    if frame.isResizing == true then
        frame:StopMovingOrSizing();

        SchoolChecker_DB.width = frame:GetWidth();
        SchoolChecker_DB.height = frame:GetHeight();
        frame.isResizing = false;
    end;
end);

local function UpdateMaxLines()
    local lineHeight = select(2, CombatLogFont:GetFont());
    local frameHeight = frame:GetHeight();
    local maxLines = math.floor(frameHeight / lineHeight);

    frame:SetMaxLines(maxLines);
end;

frame:SetScript("OnSizeChanged", function(self)
    UpdateMaxLines();
end);

UpdateMaxLines();

function SchoolChecker:EnableFrame(frame)
    if SchoolChecker_DB.point then
        frame:ClearAllPoints();
        frame:SetPoint(SchoolChecker_DB.point, nil, SchoolChecker_DB.relativePoint, SchoolChecker_DB.x, SchoolChecker_DB.y);
    else
        frame:SetPoint("CENTER", nil, "CENTER", -160, -220);
    end
    if SchoolChecker_DB.locked then
        resizeHandleRight:Hide();
        resizeHandleLeft:Hide();
    else
        resizeHandleRight:Show();
        resizeHandleLeft:Show();
    end
end;

function SchoolChecker:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "SchoolChecker" then
        SchoolChecker:EnableFrame(frame);
        if SchoolChecker_DB.width and SchoolChecker_DB.height then
            frame:SetWidth(SchoolChecker_DB.width);
            frame:SetHeight(SchoolChecker_DB.height);
        end
    end
end;

local SCHOOL_MASKS = {
    [1]   = { name = "Physical", color = "cfff2f2b0" },
    [2]   = { name = "Holy",     color = "cffffcc00" },
    [4]   = { name = "Fire",     color = "cffff4444" },
    [8]   = { name = "Nature",   color = "cff33ff33" },
    [16]  = { name = "Frost",    color = "cff00ccff" },
    [32]  = { name = "Shadow",   color = "cff6666ff" },
    [64]  = { name = "Arcane",   color = "cffcc66ff" },
};

local SPECIAL_SCHOOL_MASKS = {
    [3]   = { name = "Holystrike", color = "cfff8df58" },  -- Светло-желтый (смешение Physical и Holy)
    [5]   = { name = "Flamestrike", color = "cfff89b7a" },  -- Оранжево-розовый
    [6]   = { name = "Holyfire", color = "cffff8822" },     -- Ярко-оранжевый
    [9]   = { name = "Stormstrike", color = "cff92f871" },  -- Светло-зеленый
    [10]  = { name = "Holystorm", color = "cff99e519" },    -- Желто-зеленый
    [12]  = { name = "Firestorm", color = "cff99a13b" },    -- Желто-коричневый
    [17]  = { name = "Froststrike", color = "cff79dfd7" },  -- Светло-голубой
    [20]  = { name = "Frostfire", color = "cff7f88a1" },    -- Сине-розовый
    [24]  = { name = "Froststorm", color = "cff19e599" },   -- Бирюзовый
    [28]  = { name = "Elemental", color = "cff66af7c" },    -- Зелено-голубой
    [33]  = { name = "Shadowstrike", color = "cffacacd7" }, -- Светло-фиолетовый
    [34]  = { name = "Twilight", color = "cffb2997f" },     -- Розово-желтый
    [36]  = { name = "Shadowflame", color = "cffb255a1" },  -- Красно-фиолетовый
    [40]  = { name = "Plague", color = "cff4cb299" },       -- Темно-зеленый с фиолетовым
    [49]  = { name = "Shadowfrost", color = "cff72b6e4" },  -- Голубо-фиолетовый
    [66]  = { name = "Divine", color = "cffe5997f" },       -- Розово-желтый
    [68]  = { name = "Spellfire", color = "cffe555a1" },    -- Магента
    [72]  = { name = "Spellstorm", color = "cff7fb299" },   -- Фиолетово-зеленый
    [80]  = { name = "Spellfrost", color = "cff6699ff" },   -- Сине-фиолетовый
    [96]  = { name = "Spellshadow", color = "cff9966ff" },  -- Фиолетовый
    [126] = { name = "Magic", color = "cff9ea897" },        -- Серо-зеленый (смешение всех магических)
    [127] = { name = "Chaos", color = "cff909b93" },        -- Серо-розовый (все стихии)
};

local function GetSchoolDisplay(mask)
    local parts = {};
    for flag, data in pairs(SCHOOL_MASKS) do
        if bit.band(mask, flag) ~= 0 then
            tinsert(parts, format("|%s%s|r", data.color, data.name));
        end
    end

    local expanded = #parts > 0 and table.concat(parts, " + ") or "|cffff0000Unknown|r";

    local special = SPECIAL_SCHOOL_MASKS[mask];
    if special then
        return format("|%s%s|r (%s)", special.color, special.name, expanded);
    else
        return expanded;
    end
end;

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

frame:SetScript("OnEvent", function(self, event, ...)
    local _, type, _, _, _, destGUID, destName, _, spellId, spellName, spellSchool = ...

    if (type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE") then
        if (destGUID == UnitGUID("player") or destName == UnitName("player")) then
            local schoolText = GetSchoolDisplay(spellSchool or 0);
			local message
			if ru then
				message = format("|cff00ff00Урон от:|r |cffffffff%s|r (|cffffffffID: %d|r) - СТИХИЯ: %s", spellName, spellId, schoolText)
			else
				message = format("|cff00ff00Damage from:|r |cffffffff%s|r (|cffffffffID: %d|r) - SCHOOL: %s", spellName, spellId, schoolText)
			end
			frame:AddMessage(message);
        end
    end
end);

frame:SetScript("OnMouseUp", function(self, button)
    if not SchoolChecker_DB.locked and button ~= "RightButton" then
        if self.isMoving then
            self.isMoving = nil;
            self:StopMovingOrSizing();

            local point, _, relativePoint, xOfs, yOfs = self:GetPoint();
            SchoolChecker_DB.point = point;
            SchoolChecker_DB.relativePoint = relativePoint;
            SchoolChecker_DB.x = xOfs;
            SchoolChecker_DB.y = yOfs;
        end
    elseif button == "RightButton" then
        if SchoolChecker_DB.locked then
            SchoolChecker_DB.locked = false;
            DEFAULT_CHAT_FRAME:AddMessage("SchoolChecker: Unlocked");
            resizeHandleRight:Show();
            resizeHandleLeft:Show();
        else
            SchoolChecker_DB.locked = true
            DEFAULT_CHAT_FRAME:AddMessage("SchoolChecker: Locked");
            resizeHandleRight:Hide();
            resizeHandleLeft:Hide();
        end
    end
end);

SchoolChecker:OnEvent("ADDON_LOADED", "SchoolChecker");