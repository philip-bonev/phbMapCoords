local addonOptions = CreateFrame ("Frame", nil, InterfaceOptionsFramePanelContainer)

addonOptions.name = GetAddOnMetadata("phbMapCoords", "Title")
addonOptions:Hide()

addonOptions:SetScript("OnShow", function(self)
	-- Creates Title String
	local title = addonOptions:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOP', 0, -16)
	local titleString = GetAddOnMetadata("phbMapCoords", "Title") .. " " ..  
	        GetAddOnMetadata("phbMapCoords", "Version") .. " by " .. GetAddOnMetadata("phbMapCoords", "Author")
	title:SetText(titleString)

	-- Creates the checkboxes
	self.CheckButtons = {}
	local buttonIter = 0
	for i,j in next, phbMapCoordsDefaultObjects do
		-- Create checkbox
		self.CheckButtons[buttonIter] = CreateFrame('CheckButton', TEXT(i) .. "CheckButton", self, "InterfaceOptionsCheckButtonTemplate")
		getglobal(self.CheckButtons[buttonIter]:GetName() .. "Text"):SetText(PHBMAPCOORDSOPTIONOBJECTS[i])

		-- Set fallback string to know the original object name
		self.CheckButtons[buttonIter].MainObj = TEXT(i)
		self.CheckButtons[buttonIter]:SetScript("OnClick", function (self)
			phbMapCoordsDB.Objects[self.MainObj] = (self:GetChecked() == 1)
			-- If we set next one to true main addon will update visible objects
			phbMapCoordsDB.Update = true
		end)
		
		-- Position the new button
		if (buttonIter == 0) then
			self.CheckButtons[buttonIter]:SetPoint("TOPLEFT", 15, -50)
		else
			self.CheckButtons[buttonIter]:SetPoint('TOPLEFT', self.CheckButtons[buttonIter-1], 'BOTTOMLEFT', 0, 2)
		end
		
		-- Set new button state
		self.CheckButtons[buttonIter]:SetChecked(phbMapCoordsDB.Objects[self.CheckButtons[buttonIter].MainObj])
		self.CheckButtons[buttonIter]:Show()
		buttonIter = buttonIter + 1
	end	
end)

InterfaceOptions_AddCategory(addonOptions);