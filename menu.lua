include 'mount/mount.lua'
include 'getmaps.lua'
include 'sboxmenu/fonts.lua'
include 'sboxmenu/scripterror.lua'
local getWorkshopPreview = include 'sboxmenu/workshoppreview.lua'
local VGUI_BUTTON_MENU = include 'sboxmenu/menubutton.lua'
local VGUI_BUTTON_GAME = include 'sboxmenu/gamebutton.lua'
local VGUI_BUTTON_MAP = include 'sboxmenu/mapbutton.lua'
local VGUI_BUTTON_POWEROFF = include 'sboxmenu/poweroffbutton.lua'

local backgroundColor = Color(16, 18, 28)

local menuButtons = {
	{'home'},
	{'servers', 'OpenServerBrowser'},
	{'settings', 'OpenOptionsDialog'},
	{'disconnect', 'engine disconnect', function(b)
		function b:Think()
			self:SetVisible(IsInGame()) -- doesnt work wtf
		end
	end}
}

vgui.GetWorldPanel():Clear()
vgui.GetWorldPanel().Paint = function(self, w, h)
	surface.SetDrawColor(backgroundColor)
	surface.DrawRect(0, 0, w, h)
end

-- top menu buttons

local runCommand = function(self)
	RunGameUICommand(self.cmd)
end

for i, t in ipairs(menuButtons) do
	local b = vgui.CreateFromTable(VGUI_BUTTON_MENU)
	b:SetPos(104 + 150 * i, 71)
	b:SetSize(142, 38)
	b:SetText(t[1])
	b.BActive = i == 1

	local action = t[2]
	if action then
		if isstring(action) then
			b.DoClick = runCommand
			b.cmd = action
		else
			b.DoClick = action
		end
	end

	local customFunc = t[3]
	if customFunc then
		customFunc(b)
	end
end

local bClose = vgui.CreateFromTable(VGUI_BUTTON_POWEROFF)
bClose:SetPos(ScrW() - 100, 71)
bClose:SetSize(38, 38)
bClose.DoClick = runCommand
bClose.cmd = 'engine quit'


-- menu buttons

local homePanel = vgui.Create('Panel')
homePanel:SetPos(0, 200)
homePanel:SetSize(ScrW(), ScrH() - 200)
homePanel.Paint = function() end

local mapsPanel = vgui.Create('Panel')
mapsPanel:SetPos(0, 200)
mapsPanel:SetSize(ScrW(), ScrH() - 200)
mapsPanel.Paint = function() end

local maps_thumbnails = {}

local createMenu
local selectGamemode

-- suggestions
if not sql.TableExists('FavouriteGamemodes') then
	sql.Query('CREATE TABLE FavouriteGamemodes (gm text, numClicked integer, PRIMARY KEY (gm))')
end

-- gamemodes

createMenu = function()
	homePanel:SetVisible(true)
	mapsPanel:SetVisible(false)
	mapsPanel:Clear()
	homePanel:Clear()

	local lYourProjects = vgui.Create('DLabel', homePanel)
	lYourProjects:SetFont('sbox_Title')
	lYourProjects:SetText('Your Projects')
	lYourProjects:SetPos(75, 0)
	lYourProjects:SetSize(300, 34)

	local gamemodesTable = engine.GetGamemodes()

	local function makeGamemodeButton(gm, i, yPos)
		local b = vgui.CreateFromTable(VGUI_BUTTON_GAME, homePanel)
		b:SetRealPos(75 + i * (b:GetWide() + 12), yPos)
		b:SetText(gm.title)
		b.CornersColor = backgroundColor
		function b:DoClick()
			sql.Query( ('INSERT OR REPLACE INTO FavouriteGamemodes VALUES ("%s", %s);'):format(gm.name, gm.numClicked + 1) )
			selectGamemode(gm)
		end

		local logoPath = 'gamemodes/' .. gm.name .. '/logo.png'
		local logoMat = Material(logoPath, 'smooth')
		if not logoMat:IsError() then
			b:SetLogo(logoMat)
		end

		if gm.workshopid and gm.workshopid != 0 then
			getWorkshopPreview(gm.workshopid, function(mat)
				b:SetPreview(mat)
			end)
		end
	end

	local i = 0
	for _, gm in ipairs(gamemodesTable) do
		gm.numClicked = 0

		if not gm.menusystem then continue end

		makeGamemodeButton(gm, i, 59)

		local numClicked = sql.QueryValue('SELECT numClicked FROM FavouriteGamemodes WHERE gm = ' .. SQLStr(gm.name))
		if numClicked then
			gm.numClicked = tonumber(numClicked)
		end

		i = i + 1
	end

	local lFavourites = vgui.Create('DLabel', homePanel)
	lFavourites:SetFont('sbox_Title')
	lFavourites:SetText('Suggestions')
	lFavourites:SetPos(75, 317)
	lFavourites:SetSize(300, 34)

	table.SortByMember(gamemodesTable, 'numClicked')

	i = 0
	for _, gm in ipairs(gamemodesTable) do
		if gm.numClicked == 0 then break end

		makeGamemodeButton(gm, i, 376)

		i = i + 1
	end
end

createMenu()
hook.Add('WorkshopEnd', 'UpdateGamemode', createMenu)


-- maps

selectGamemode = function(gm)
	homePanel:SetVisible(false)
	mapsPanel:SetVisible(true)
	mapsPanel:Clear()
	homePanel:Clear()

	local scrollPanel = vgui.Create('DScrollPanel', mapsPanel)
	scrollPanel:SetPos(580, 0)
	scrollPanel:SetSize(1000, ScrH() - 200)

	local vbar = scrollPanel:GetVBar()
	vbar:SetHideButtons(true)

	local doNothing = function() return true end
	vbar.Paint = doNothing
	vbar.btnGrip.Paint = doNothing
	vbar.realScroll = 0

	function vbar:AddScroll(delta)
		local scroll = self.realScroll

		self.realScroll = math.Clamp(
			scroll + delta * 50,
			0,
			self.CanvasSize
		)

		return scroll ~= self:GetScroll()
	end

	function vbar:Think()
		self:SetScroll(Lerp(FrameTime() * 10, self:GetScroll(), self.realScroll))
	end

	local iconLayout = vgui.Create('DIconLayout', scrollPanel)
	iconLayout:SetSize(scrollPanel:GetSize())
	iconLayout:SetSpaceY(36)
	iconLayout:SetSpaceX(15)
	iconLayout:SetBorder(14)
	function iconLayout:Paint()
		render.SetScissorRect(580, 200, 1580, ScrH(), true)
	end

	function iconLayout:PaintOver()
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	local yPos = 18

	for category, maps in SortedPairs(GetMapList()) do
		local lMaps = vgui.Create('DLabel', mapsPanel)
		lMaps:SetFont('sbox_Title')
		lMaps:SetText(category)
		lMaps:SetPos(390, yPos)
		lMaps:SizeToContents()
		lMaps:SetMouseInputEnabled(true)
		lMaps:SetCursor('hand')
		function lMaps:DoClick()
			iconLayout:Clear()

			for i, map in ipairs(maps) do
				local b = vgui.CreateFromTable(VGUI_BUTTON_MAP, iconLayout)
				b:SetText(map)
				b.CornersColor = backgroundColor

				local mat = maps_thumbnails[map]

				if not mat then
					mat = string.format('maps/thumb/%s.png', map)

					if not file.Exists(mat, 'GAME') then
						mat = string.format('maps/%s.png', map)
					end

					if not file.Exists(mat, 'GAME') then
						mat = 'maps/thumb/noicon.png'
					end

					mat = Material(mat, 'mips smooth')
					maps_thumbnails[map] = mat
				end

				b:SetPreview(mat)

				function b:DoClick()
					RunConsoleCommand('progress_enable')
					RunConsoleCommand('map', map)
				end
			end
		end

		if category == 'Sandbox' then
			lMaps:DoClick()
		end

		yPos = yPos + 35
	end

	local bCancel = vgui.CreateFromTable(VGUI_BUTTON_MENU, mapsPanel)
	bCancel:SetPos(mapsPanel:GetWide() - 300, mapsPanel:GetTall() - 84)
	bCancel:SetSize(202, 42)
	bCancel:SetText('Cancel')
	bCancel.BGColor = Color(56, 56, 56)
	function bCancel:DoClick()
		createMenu()
	end

	RunConsoleCommand('gamemode', gm.name)
end

function UpdateMapList()
end