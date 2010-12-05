local addon = CreateFrame("Frame", "phbMapCoords", Minimap)

phbMapCoordsDefaultObjects = {
	MiniMapWorldMapButton = false,
	MinimapZoomIn = false,
	MinimapZoomOut = false,
	MinimapBorderTop = false,
	MinimapZoneTextButton = true,
	MiniMapTracking = false,
	GameTimeFrame = false,
	phbMiniMapCoordText = true,
	phbWorldMapCoordText = true,
	TimeManagerClockButton  = false,
}

MinimapCluster:SetMovable(true)
MinimapCluster:SetUserPlaced(true)

Minimap:SetScript("OnMouseDown", function(self)
	if(IsAltKeyDown()) then
		MinimapCluster:ClearAllPoints()
		MinimapCluster:StartMoving()
	else
		Minimap_OnClick(self)
	end
end)

Minimap:SetScript("OnMouseUp", function()
	MinimapCluster:StopMovingOrSizing()
end)
	
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, z)
	local c = Minimap:GetZoom()
	if(z > 0 and c < 5) then
		Minimap:SetZoom(c + 1)
	elseif(z < 0 and c > 0) then
		Minimap:SetZoom(c - 1)
	end
end)

addon.MiniMapFrame = CreateFrame("Frame", nil, Minimap)

addon.MiniMapFrame:EnableMouse(false)
addon.MiniMapFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
addon.MiniMapFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
addon.MiniMapFrame:EnableMouseWheel(true)

addon.MiniMapFrameCoords = CreateFrame("Frame", "phbMiniMapCoordText", addon.MiniMapFrame)
addon.MiniMapFrameCoords:SetWidth(40)
addon.MiniMapFrameCoords:SetHeight(16)
addon.MiniMapFrameCoords:EnableMouse(false)
addon.MiniMapFrameCoords:SetPoint("BOTTOM", addon.MiniMapFrame, "BOTTOM", 0,-22)
addon.MiniMapFrameCoords.loc = addon.MiniMapFrameCoords:CreateFontString(nil, "OVERLAY")
addon.MiniMapFrameCoords.loc:SetWidth(40)
addon.MiniMapFrameCoords.loc:SetHeight(16)
addon.MiniMapFrameCoords.loc:SetPoint("BOTTOM", addon.MiniMapFrameCoords, "BOTTOM")
addon.MiniMapFrameCoords.loc:SetJustifyH("CENTER")
addon.MiniMapFrameCoords.loc:SetFontObject(GameFontNormalSmall)
addon.MiniMapFrameCoords:Show()

addon.WorldMapFrame = CreateFrame("Frame","phbWorldMapCoordText", WorldMapFrame)
addon.WorldMapFrame.loc = addon.WorldMapFrame:CreateFontString(nil, "OVERLAY")
addon.WorldMapFrame.loc:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM", 0, 10)
addon.WorldMapFrame.loc:SetJustifyH("CENTER")
addon.WorldMapFrame.loc:SetFontObject(GameFontNormal)

local miniMapUpdate = function ()
	x,y=GetPlayerMapPosition("player")
	addon.MiniMapFrameCoords.loc:SetText(string.format("%s,%s", floor(x*100) or "", floor(y*100) or ""))
end

local worldMapUpdate = function ()
	if (not WorldMapFrame:IsVisible()) then
		return
	end
	local output = ""
	local OFFSET_X = 0.0022
	local OFFSET_Y = -0.0262


	local x, y = GetCursorPosition()
	local scale = WorldMapFrame:GetScale()
	x = x / scale
	y = y / scale
	local width = WorldMapButton:GetWidth()
	local height = WorldMapButton:GetHeight()
	local centerX, centerY = WorldMapFrame:GetCenter()
	local adjustedX = (x - (centerX - (width/2))) / width
	local adjustedY = (centerY + (height/2) - y) / height
	x = (adjustedX + OFFSET_X) * 100
	y = (adjustedY + OFFSET_Y) * 100
	output = PHBMAPCOORDS_CURSORCOORDS..format("%d,%d",x,y)

	local px, py = GetPlayerMapPosition("player")
	output = output..PHBMAPCOORDS_PLAYERCOORDS..floor(px * 100)..","..floor(py * 100)

	addon.WorldMapFrame.loc:SetText(output)
end

function addon:Init()
	if (phbMapCoordsDB == nil) then
		phbMapCoordsDB = {}
	end
	if (phbMapCoordsDB.Objects == nil) then
		phbMapCoordsDB.Objects = {}
		phbMapCoordsDB.Objects = phbMapCoordsDefaultObjects
	end
end

function addon:Setup()
	for i,j in next, phbMapCoordsDB.Objects do
		local obj = getglobal(TEXT(i))
		if (obj ~= nil) then
			if ( phbMapCoordsDB.Objects[i]) then
				obj:Show()
			else
				obj:Hide()
			end
		end
	end
end

function addon:VARIABLES_LOADED()
	SetMapToCurrentZone()
	self.Init()
	phbMapCoordsDB.Update = true
	addon.MiniMapFrame:SetScript("OnUpdate", miniMapUpdate)
	addon.WorldMapFrame:SetScript("OnUpdate", worldMapUpdate)
end

function addon:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end

addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

addon:SetScript("OnUpdate", function()
	if (phbMapCoordsDB.Update) then
		addon.Setup()
		phbMapCoordsDB.Update = false
	end
end)

hooksecurefunc(InterfaceOptionsFrame, "Show", function()
	if ( not IsAddOnLoaded("phbMapCoordsOptions") ) then
		LoadAddOn("phbMapCoordsOptions");
	end
end);

addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")
addon:RegisterEvent("VARIABLES_LOADED")