local PANEL = {}

PANEL.BGColor = Color(11, 13, 17)
PANEL.BGColorHover = Color(44, 112, 232)
PANEL.TextColor = Color(220, 220, 220)
PANEL.BActive = false

function PANEL:Paint(w, h)
	draw.RoundedBox(self:GetTall() / 2, 0, 0, w, h, (self.Hovered or self.BActive) and self.BGColorHover or self.BGColor)

	surface.SetFont('sbox_Button')
	local tw, th = surface.GetTextSize(self:GetText())
	surface.SetTextPos((w - tw) / 2, (h - th) / 2)
	surface.SetTextColor(self.TextColor)
	surface.DrawText(self:GetText())

	return true
end

return vgui.RegisterTable(PANEL, 'DButton')