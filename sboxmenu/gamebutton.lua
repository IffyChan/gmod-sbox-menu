local PANEL = {}

PANEL.BGColor = Color(48, 47, 49)
PANEL.BGColorHover = Color(19, 120, 208)
PANEL.TextColor = Color(220, 220, 220)
PANEL.CornersColor = Color(255, 255, 255)

local borderMat = Material('../lua/menu/sboxmenu/assets/border.png')
local stencilMat = Material('../lua/menu/sboxmenu/assets/stencil.png')

function PANEL:Init()
	self:SetSize(150, 183 + 30)
	self.realX = 0
	self.realY = 0
	self.animY = 0
	self.acceleration = 0
	self.lastTimeHovered = 0
end

function PANEL:SetRealPos(x, y)
	self:SetPos(x, y)
	self.realX = x
	self.realY = y
end

local function dropFunction(x)
	return math.abs(math.cos(x^2)) / ( (x^2) / 3 + 1 ) -- overcomplicated
end

function PANEL:Animate()
	if self.Hovered then
		self.animY = Lerp(FrameTime() * 20, self.animY, -8)
		self.lastTimeHovered = SysTime()
	else
		local time = (SysTime() - self.lastTimeHovered) * 5
		if time < 2.1708 then -- sqrt(6 * pi) / 2
			self.animY = -dropFunction(time) * 8
		else
			self.animY = 0
		end
	end

	self:SetPos(self.realX, self.realY + self.animY)
end

function PANEL:SetLogo(mat)
	self.matLogo = mat
	local w = mat:GetInt('$realwidth') or 288
	local h = mat:GetInt('$realheight') or 128

	self.logoWidth = math.min(w, 128)
	self.logoHeight = h * (self.logoWidth / w)
end

function PANEL:SetPreview(mat)
	self.matPreview = mat
end

function PANEL:Paint(w, h)
	h = h - 30

	-- draw bg

	surface.SetDrawColor(self.BGColor)
	surface.DrawRect(0, 0, w, h)

	if self.matPreview then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.matPreview)
		surface.DrawTexturedRect((w - h) / 2, 0, h, h)
	elseif self.matLogo then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.matLogo)
		surface.DrawTexturedRect((w - self.logoWidth) / 2, (h - self.logoHeight) / 2, self.logoWidth, self.logoHeight)
	end

	surface.SetDrawColor(self.CornersColor)
	surface.SetMaterial(stencilMat)
	surface.DrawTexturedRect(0, 0, w, h)

	if self.Hovered then
		DisableClipping(true)
		surface.SetDrawColor(self.BGColorHover)
		surface.SetMaterial(borderMat)
		surface.DrawTexturedRect(-14, -14, 179, 212)
		DisableClipping(false)
	end

	surface.SetFont('sbox_Gamemode')
	surface.SetTextPos(0, h + 8)
	surface.SetTextColor(self.TextColor)
	surface.DrawText(self:GetText())

	self:Animate()

	return true
end

return vgui.RegisterTable(PANEL, 'DButton')