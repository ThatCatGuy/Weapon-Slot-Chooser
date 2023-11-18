WeaponSlots = WeaponSlots || {}

// Config
local makechanges 			= "Make Changes"
local makechangesfont		= "Trebuchet24" 
local makechangesbtn 		= Color(41, 123, 207, 100)
local makechangesbtnhover 	= Color(48, 133, 219, 220)

local resetslots 			= "Reset"
local resetslotsfont		= "Trebuchet24" 
local resetbtn 				= Color(41, 123, 207, 100)
local resetbtnhover 		= Color(48, 133, 219, 220)

local close 				= "X"
local closefont				= "Trebuchet24" 
local closebtn 				= Color(255, 0, 0, 50)
local closebtnhover 		= Color(255, 0, 0, 100)

local slotsfont				= "Trebuchet24" 
local slotsbtn 				= Color(41, 123, 207, 100)

local framebg 				= Color(55, 55, 55, 255)
local titlebarbg 			= Color(41, 123, 207, 100)

local swepslotbg 			= Color(40, 40, 40, 100)
local swepslotbghover 		= Color(55, 55, 55, 255)

local function UpdateFile()
	if !file.IsDir("weapons", "DATA") then
		file.CreateDir("weapons")
	end
	file.Write("weapons/weapon_slots.dat", util.TableToJSON(WeaponSlots))
end

local function ChangeWeaponSlot(real_wep, slot, slot_pos)
	real_wep.Slot = slot
	real_wep.SlotPos = slot_pos
	if slot_pos then
		WeaponSlots[real_wep.ClassName] = {slot, slot_pos}
	end
	UpdateFile()
end

concommand.Add("reset_weapon_slots", function(ply, cmd, args)
	table.Empty(WeaponSlots)
	if file.Exists("weapons/weapon_slots.dat", "DATA") then
		file.Delete("weapons/weapon_slots.dat")
	end
	LocalPlayer():ChatPrint( "Your settings have been removed, please relog so weapons can go back to their default slots." )
end)

hook.Add("InitPostEntity", "WeaponSlots.Load", function()
	if file.Exists("weapons/weapon_slots.dat", "DATA") then
		local data = file.AsyncRead("weapons/weapon_slots.dat", "DATA", function(x, y, status, data)
			if status == FSASYNC_OK then
				WeaponSlots = util.JSONToTable(data)
				for class, info in pairs(WeaponSlots) do
					local real_wep = weapons.GetStored(class)
					if real_wep then
						real_wep.Slot = info[1] 
						real_wep.SlotPos = info[2] 
					end
				end
			end
		end)
	end
end)

local function MakeChanges(tbl)
	for desired_slot, weps in pairs(tbl) do
		for k, wep in pairs(weps) do
			local real_wep = weapons.GetStored(wep.ClassName)
			if real_wep && (real_wep.Slot != desired_slot || k != real_wep.SlotPos) then
				ChangeWeaponSlot(real_wep, desired_slot, k)
				wep.Slot = desired_slot
				wep.SlotPos = k
			end
		end
	end
	LocalPlayer():ChatPrint( "Weapon slots updated. Respawn to apply updates." )
end

concommand.Add("weapon_slots", function(ply, cmd, args)
	if wepfr and IsValid(wepfr) then wepfr:Close() wepfr = nil end
	local fr = vgui.Create("WDFrame")
	wepfr = fr
	fr:SetSize(ScrW() * 0.6, ScrH() * 0.9)
	fr:ShowCloseButton(false)
	fr:Center()
	fr:SetTitle("")
	fr:SetDraggable(false)
	fr.OnKeyCodePressed = function(self, key)
		if key == KEY_F4 then
			fr:Close()
		end
	end
	fr.Paint = function(self, w, h)
		surface.DrawOutlinedRect(1, 1, w, h)
	    draw.RoundedBox(0, 0, 0, w, h, framebg)
	    surface.SetDrawColor(titlebarbg)
		surface.DrawRect(1, 1, fr:GetWide() - 331, 29)
		draw.SimpleTextOutlined( "Weapon Slots", "Trebuchet24", 5, 3, color_white, 0, 0, 1, color_black)
	end
	local cbtn = vgui.Create("DButton", fr)
	cbtn:SetText("")
	cbtn:SetSize(30, 30)
	cbtn:SetPos(fr:GetWide() - cbtn:GetWide(), 0)
	cbtn.Paint = function()
		surface.SetDrawColor(closebtn)
		if cbtn.Hovered then
	    	surface.SetDrawColor(closebtnhover)
	    end
	    surface.DrawRect(1, 1, cbtn:GetWide() - 2, cbtn:GetTall())
	    draw.SimpleTextOutlined(close, closefont, cbtn:GetWide()/2, cbtn:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end
	cbtn.DoClick = function()
		fr:Close()
	end

	local btn = vgui.Create("DButton", fr)
	btn:SetText("")
	btn:SetSize(150, 30)
	btn:SetPos(cbtn.x - btn:GetWide(), 0)
	btn.Paint = function()
		surface.SetDrawColor(makechangesbtn)
		if btn.Hovered then
	    	surface.SetDrawColor(makechangesbtnhover)
	    end	    
	    surface.DrawRect(1, 1, btn:GetWide(), btn:GetTall())
		draw.SimpleTextOutlined(makechanges, makechangesfont, btn:GetWide()/2, btn:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end
	local listz = {}
	btn.DoClick = function()
		local changes = {}
		for slot, icons in pairs(listz) do
			changes[slot] = {}
			for k, v in pairs(icons:GetChildren()) do
				if v.Weapon != false && v.Weapon != nil then
					table.insert(changes[slot], v.Weapon)
				end
			end
		end
		MakeChanges(changes)
		fr:Close()
	end
	local reset = vgui.Create("DButton", fr)
	reset:SetText("")
	reset:SetSize(150, 30)
	reset:SetPos(btn.x - reset:GetWide(), 0)
	reset.Paint = function()
		surface.SetDrawColor(resetbtn)
		if reset.Hovered then
	    	surface.SetDrawColor(resetbtnhover)	    	
	    end
	    surface.DrawRect( 1, 1, reset:GetWide(), reset:GetTall() )
	    draw.SimpleTextOutlined(resetslots, resetslotsfont, reset:GetWide()/2, reset:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	end
	reset.DoClick = function()
		local confirm = vgui.Create("WDConfirm")
		confirm:SetQuestion("Are you sure you want to reset?")
		confirm.OnYes = function()
			RunConsoleCommand("reset_weapon_slots")
			confirm:Remove()
			fr:Close()
		end
	end
	local width = fr:GetWide() / 7
	for i=0, 6 do
		local pnl = vgui.Create("DButton", fr)
		pnl:SetSize(width, 20)
		pnl:SetPos(i * pnl:GetWide(), 30)
		pnl:SetText("")
		pnl.Paint = function()
			surface.SetDrawColor( slotsbtn )
		    surface.DrawRect( 1, 1, pnl:GetWide(), pnl:GetTall() )
			if i == 6 then 
				draw.SimpleTextOutlined("Disabled", slotsfont, pnl:GetWide()/2, pnl:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			else
				draw.SimpleTextOutlined(i + 1, slotsfont, pnl:GetWide()/2, pnl:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			end
		end
		local scroll = vgui.Create("WDScrollPanel", fr)
		scroll:SetSize(pnl:GetWide(), fr:GetTall() - 50)
		scroll:SetPos(pnl.x, 50)

		local icons = vgui.Create("DListLayout", scroll)
		icons:SetSize(pnl:GetWide(), fr:GetTall() - pnl:GetTall())
		icons:SetPos(pnl.x, 50)
		icons:SetPaintBackground(true)
		icons:SetBackgroundColor(swepslotbg)
		icons:MakeDroppable("WeaponSlots")
		icons.Index = i
		icons.OnModified = function()
			timer.Simple(0.1, function()
				scroll:InvalidateLayout()	
				scroll:PerformLayout()
			end)
		end

		local pnl = icons:Add("DPanel")
		pnl:SetSize(width, 5)
		pnl.Paint = function()
			surface.SetDrawColor(swepslotbg)
		    surface.DrawRect(1, 1, pnl:GetWide() - 2, pnl:GetTall())
		end
		scroll:AddItem(icons)
		listz[i] = icons
	end

	for k, v in SortedPairsByMemberValue(LocalPlayer():GetWeapons(), "SlotPos") do
		if v.Slot && listz[v.Slot] then
			local pnl = v.Slot and listz[v.Slot]:Add("DPanel")
			pnl:SetSize(width, fr:GetTall() * 0.1)
			pnl:SetCursor("hand")
			pnl.Paint = function()
				surface.SetDrawColor(swepslotbg)
				if pnl.Hovered then
			    	surface.SetDrawColor(swepslotbghover)	    	
			    end
			    surface.DrawRect(1, 1, pnl:GetWide() - 2, pnl:GetTall())
			end
			pnl.Weapon = v
			local icon = vgui.Create("SpawnIcon", pnl)
			icon:SetModel(v.WorldModel != "" and v.WorldModel or "models/props_lab/clipboard.mdl")
			icon:SetSize(pnl:GetSize())
			icon:SetMouseInputEnabled(false)
			icon.Paint = function()
			    surface.DrawRect(1, 1, icon:GetWide(), icon:GetTall())
			end
			local lbl = vgui.Create( "DLabel", pnl)
			lbl:SetPos(5, pnl:GetTall() - lbl:GetTall())
			lbl:SetText( v.PrintName )
			lbl:SetFont("HudHintTextLarge")
			if v.Slot == 6 then
				lbl:SetTextColor( Color( 255, 0, 0) )
			end
			lbl:SizeToContents()
			lbl:SetDark(false)
		end
	end
end)
