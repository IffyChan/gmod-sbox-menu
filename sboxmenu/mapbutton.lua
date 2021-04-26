local PANEL = {}

PANEL.BGColor = Color(48, 47, 49)
PANEL.BGColorHover = Color(19, 120, 208)
PANEL.TextColor = Color(220, 220, 220)

local borderMat = Material('../lua/menu/sboxmenu/assets/border.png')
local stencilMat = Material('../lua/menu/sboxmenu/assets/stencil.png')

function PANEL:Init()
	self:SetSize(165, 183 + 30)
	self.borderAlpha = 0
end

function PANEL:SetPreview(mat)
	self.matPreview = mat
end

function PANEL:Paint(w, h)
	h = h - 30

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(self.matPreview)
	surface.DrawTexturedRect((w - h) / 2, 0, h, h)

	surface.SetDrawColor(self.CornersColor)
	surface.SetMaterial(stencilMat)
	surface.DrawTexturedRect(0, 0, w, h)

	if self.Hovered and self.borderAlpha < 255 then
		self.borderAlpha = self.borderAlpha + FrameTime() * 1000
	elseif not self.Hovered and self.borderAlpha > 0 then
		self.borderAlpha = self.borderAlpha - FrameTime() * 1000
	end

	if self.borderAlpha > 0 then
		DisableClipping(true)
		surface.SetDrawColor(ColorAlpha(self.BGColorHover, self.borderAlpha))
		surface.SetMaterial(borderMat)
		surface.DrawTexturedRect(-14, -14, 194, 212)
		DisableClipping(false)
	end

	surface.SetFont('sbox_Gamemode')
	surface.SetTextPos(0, h + 8)
	surface.SetTextColor(self.TextColor)
	surface.DrawText(self:GetText())

	return true
end

return vgui.RegisterTable(PANEL, 'DButton')