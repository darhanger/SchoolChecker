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

local function GetSchoolName(mask)
    local names = {};
    for flag, data in pairs(SCHOOL_MASKS) do
        if bit.band(mask, flag) ~= 0 then
            tinsert(names, format("|%s%s|r", data.color, data.name));
        end
    end
    return #names > 0 and table.concat(names, " + ") or "|cffff0000Unknown|r";
end;

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

frame:SetScript("OnEvent", function(self, event, ...)
    local _, type, _, _, _, destGUID, destName, _, spellId, spellName, spellSchool = ...

    if (type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE") then
        if (destGUID == UnitGUID("player") or destName == UnitName("player")) then
            local schoolText = GetSchoolName(spellSchool)
			local message
			if ru then
				message = format("|cff00ff00Получен урон от:|r |cffffffff%s|r (|cffffffff%d|r) - |cff00ff00стихия:|r %s", spellName, spellId, schoolText)
			else
				message = format("|cff00ff00Damage taken from:|r |cffffffff%s|r (|cffffffff%d|r) - |cff00ff00School:|r %s", spellName, spellId, schoolText)
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