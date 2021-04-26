local PANEL = {}

PANEL.BGColor = Color(11, 13, 17)
PANEL.BGColorHover = Color(44, 112, 232)

local offButton = Material('../lua/menu/sboxmenu/assets/poweroff.png')

function PANEL:Paint(w, h)
	draw.RoundedBox(self:GetTall() / 2, 0, 0, w, h, self.Hovered and self.BGColorHover or self.BGColor)

	surface.SetDrawColor(220, 220, 220)
	surface.SetMaterial(offButton)
	surface.DrawTexturedRect((w-32) / 2, (h-32) / 2, 32, 32)

	return true
end

return vgui.RegisterTable(PANEL, 'DButton')