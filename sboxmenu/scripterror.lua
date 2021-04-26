local hook_Add = hook.Add
local table_insert = table.insert
local SysTime = SysTime
local math_Rand = math.Rand
local table_remove = table.remove
local surface_SetFont = CLIENT and surface.SetFont
local FrameTime = FrameTime
local ipairs = ipairs
local surface_SetTextColor = CLIENT and surface.SetTextColor
local surface_SetTextPos = CLIENT and surface.SetTextPos
local surface_DrawText = CLIENT and surface.DrawText
local surface_GetTextSize = CLIENT and surface.GetTextSize
local math_sin = math.sin
local surface_SetDrawColor = CLIENT and surface.SetDrawColor
local surface_DrawRect = CLIENT and surface.DrawRect

-- funny errors =)

local ERROR_TEXT = 'LUA ERROR'

local errors = {}
local lastError = 0

hook_Add('OnLuaError', 'MenuErrorHandler', function(str, realm, stack, addontitle, addonid)
	table_insert(errors, {SysTime() + 2, 20, 8, math_Rand(1, 10), math_Rand(-0.2, 0.2)})
	lastError = SysTime() + 2
end)

hook_Add('DrawOverlay', 'MenuDrawLuaErrors', function()
	if #errors > 0 then
		if errors[#errors][1] < SysTime() then
			table_remove(errors)
		end

		surface_SetFont('DermaDefaultBold')

		local delta = FrameTime() * 150
		for i, e in ipairs(errors) do
			e[4] = e[4] * 0.995
			e[2] = e[2] + e[4] * delta

			e[5] = e[5] * 0.99 + 0.03
			e[3] = e[3] + e[5] * delta

			surface_SetTextColor(230, 64, 32, (e[1] - SysTime()) * 255)
			surface_SetTextPos(e[2], e[3])
			surface_DrawText(ERROR_TEXT)
		end

		local tw, th = surface_GetTextSize(ERROR_TEXT)

		local val = 200 + math_sin(SysTime() * 20) * 128
		surface_SetDrawColor(255, val, 64, 255)
		surface_DrawRect(0, 0, tw + 16, th + 16)

		surface_SetDrawColor(70, 80, 90, 255)
		surface_DrawRect(4, 4, tw + 8, th + 8)

		surface_SetTextPos(8, 8)
		surface_SetTextColor(255, 0, 0, 255)
		surface_DrawText(ERROR_TEXT)

		if lastError < SysTime() then
			errors = {}
		end
	end
end)