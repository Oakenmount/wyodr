
surface.CreateFont( "ScoreboardDefault",
{
	font= "Helvetica",
	size= 22,
	weight= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font= "Helvetica",
	size= 32,
	weight= 800
})

local function SaturateColor(clr, mul, dmul)
	mul = mul or 1
	dmul = dmul or mul
	local hue, sat, val = ColorToHSV(clr)
	return HSVToColor(hue, sat-0.2*mul, val-0.1*dmul)
end

local flag_materials = {}
-- Stupid Garry not using ISO standard for country names, thus this
local flag_mappings = {
	da = "dk",
	["sv-se"] = "se",
	["en"] = "gb",
	["en-pt"] = "us",
	["pt-br"] = "br",
	["es-ES"] = "es"
}
for _,country in pairs({"bg","cs","da","de","el","en","en-pt","es-ES","et","fi","fr","he","hr","hu","it","ja","ko","lt","nl","no","pl","pt-br","ru","sk","th","tr","uk","vi","sv-se"}) do
	flag_materials[(flag_mappings[country] or country)] = Material("resource/localization/" .. country .. ".png", "smooth")
end

local phone_mat = Material("icon16/phone.png")
local muted_mat = Material("icon16/ipod.png")
local cross_mat = Material("icon16/cross.png")

local mw3_colors = {
	[0] = Color(0, 0, 0),
	[1] = Color(255, 0, 0),
	[2] = Color(0, 255, 0),
	[3] = Color(255, 255, 0),
	[4] = Color(0, 0, 255),
	[5] = Color(0, 255, 255),
	[6] = Color(255, 192, 203),
	[7] = Color(255, 255, 255)
}

-- UTime pls
local function timeToStr( time )
    local tmp = time
    local s = tmp % 60
    tmp = math.floor( tmp / 60 )
    local m = tmp % 60
    tmp = math.floor( tmp / 60 )
    local h = tmp % 24
    tmp = math.floor( tmp / 24 )
    local d = tmp % 7
    local w = math.floor( tmp / 7 )
    
    return string.format( "%02iw %id %02ih %02im %02is", w, d, h, m, s )
end

local PLAYER_LINE = 
{
	Init = function( self )
	
		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
		
		self.Avatar= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )
		self.Avatar.PaintOver = function()
			local mat = flag_materials[string.lower(self.Player:GetNWString("countrycode") or "")]	
			if mat then
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 32-10, 16, 10	)
			end
			if IsValid(self.Player) and self.Player:VoiceVolume() > 0.3 then
				self.Player.HasMic = true	
			end
			if self.Player.HasMic then
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(phone_mat)
				surface.DrawTexturedRect(18, 32-16, 16, 16)
			end
			if self.Player:GetDeafMode() then
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(muted_mat)
				surface.DrawTexturedRect(16, 2, 16, 16)
				
				surface.SetDrawColor(255, 255, 255, 150)
				surface.SetMaterial(cross_mat)
				surface.DrawTexturedRect(16, 2, 16, 16)
			end
			draw.NoTexture()
		end
		
		--[[self.Name= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetColor(Color(255, 255, 255))
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:DockMargin( 8, 0, 0, 0 )]]
		
		self.Mute= self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )
		
		self:SetText("")
		
		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 2 )
	
	end,
	
	Setup = function( self, pl )
	
		self.Player = pl
		
		self.Avatar:SetPlayer( pl )
		--self.Name:SetText( pl:Nick() )
		
		self:Think( self )
	
		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )w
	
	end,
	
	Think = function( self )
	
		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end
		local tooltip = string.format("%s\n%s[%s]\n%dms", self.Player:Nick(),
														(self.Player:GetNWString("countryname") or ""),
														(self.Player:GetNWString("countrycode") or ""),
														self.Player:Ping())
		
		if LocalPlayer():IsAdmin() then
		    tooltip = string.format("%s\n%s", tooltip, timeToStr(self.Player:GetUTimeTotalTime()))
		end
		
		self:SetTooltip(tooltip)
		
		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil or self.Muted != self.Player:IsMuted() ) then
			
			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end
			
			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end
		
		end
		
		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end
		
		self:SetZPos( self.Player:EntIndex() ) -- Sort by join order
	
	end,
	
	Paint = function( self, w, h )
		
		if ( !IsValid( self.Player ) ) then
			return
		end
		
		
		local clr = team.GetColor(self.Player:Team())
		if not self.Player:Alive() then clr = SaturateColor(clr, 0.5, 2) end
		if self.Player:GetMoonMode() then clr = Color(170, 170, 170) end
		
		surface.SetDrawColor(clr)
		surface.DrawRect(0, 0, w, h)
		
		--surface.SetDrawColor(0, 0, 0)
		--surface.DrawOutlinedRect(0, 0, w, h)
		
		local pingfrac = math.min(self.Player:Ping() / 200, 1)
		
		surface.SetDrawColor(HSVToColor(math.Remap((1-pingfrac), 0, 1, -50, 120), 0.65, 0.95))
		surface.DrawRect(0, h-2, w*pingfrac, 2)
		
		surface.SetTextColor(255, 255, 255)
		surface.SetFont("ScoreboardDefault")
		surface.SetTextPos(40, 8)
		
		local nick = self.Player:Nick()
		local replaced = false
		nick:gsub( "([^%^]*)%^(%d)([^%^]*)", function( prefix, tag, postfix )
			surface.DrawText(prefix)
			--[[tag = tonumber(tag)
			if tag and mw3_colors[tag] then
				surface.SetTextColor(mw3_colors[tag])	
			end]]
			surface.DrawText(postfix)
			replaced = true
		end)
		if not replaced then surface.DrawText(nick) end
		
	end,
	
	DoRightClick = function(self)
		local menu = DermaMenu()
		local function addCmd(cmd, name)
			menu:AddOption(name, function()
				if LocalPlayer():query("ulx " .. cmd) then
					RunConsoleCommand("ulx", cmd, "$" .. self.Player:UserID())
				end	
			end)
		end
		addCmd("bring", "Bring")
		addCmd("goto", "Go To")
		addCmd("respawn", "Respawn")
		--addCmd("kick", "Kick")
		addCmd("slay", "Slay")
		addCmd("gag", "Gag")
		addCmd("mute", "Mute")
		menu:Open()	
	end
}

PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DButton" );

local TEAM_LABEL_LINE = 
{
	Init = function( self )
	
		self.Name= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetColor(Color(255, 255, 255))
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:DockMargin( 8, 0, 0, 0 )
		
		self:SetText("")
		
		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 4 )
	
	end,
--[[	
	DoClick = function(self)
		net.Start("teamChange")
		net.WriteUInt(self.TeamId, 8)
		net.SendToServer()	
	end,
]]	
	Paint = function( self, w, h )
		surface.SetDrawColor(0, 0, 0)
		surface.DrawOutlinedRect(0, 0, w, h)
		
		local clr = self.BGColor or Color(255, 255, 255)
		
		surface.SetDrawColor(clr)
		surface.DrawRect(0, 0, w, h)
		
		local val, max = 0, 0
		for _,ply in pairs(player.GetAll()) do
			if ply:Team() == self.TeamId  then
				max = max + 1	
				if ply:Alive() and not ply:GetMoonMode() then val = val + 1 end
			end	
		end
		draw.SimpleText(string.format("%d/%d", val, max), "ScoreboardDefault", w-12	, 19, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
TEAM_LABEL_LINE = vgui.RegisterTable( TEAM_LABEL_LINE, "DButton" );

local SCORE_BOARD = 
{
	Init = function( self )
	
		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )
		
		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		
		local s, e = pcall(function()
			self.EventLogScroll = self:Add("DScrollPanel")
			self.EventLogScroll.pnlCanvas:Dock(FILL)
			--self.EventLogScroll.pnlCanvas:SetSize(200, 800)
			self.EventLogScroll:Dock(RIGHT)
			
			wyodr.EventLogScrollElement = self.EventLogScroll
			
			self.EventLog = vgui.Create("DPanelList")
			self.EventLogScroll:AddItem(self.EventLog)
			--self.EventLog:Dock(FILL)
			self.EventLog:SetPaintBackground(false)
			
			wyodr.EventLogElement = self.EventLog
			
			
			timer.Simple(0.5, function() if IsValid(self.EventLogScroll) and IsValid(self.EventLogScroll.VBar) then self.EventLogScroll.VBar:AddScroll(99999) end end)
		end)
		if not s then MsgN("sb err: ", e) end
		
		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )
		
		self.TheScores = self:Add("DPanel")
		self.TheScores:SetPaintBackground(false)
		
		self.PScores = self.TheScores:Add( "DScrollPanel" )
		self.PScores:Dock(LEFT)
		
		local function AddTeamLblReceiver(teamlabel, teamname)
			teamlabel:Receiver("plydnd", function(self, dropped_panels, dropped)
				if not dropped then return end
				for _,pnl in pairs(dropped_panels) do
					if IsValid(pnl.Player) then
						LocalPlayer():ConCommand("ulx force $" .. pnl.Player:UserID() .. " " .. teamname)
					end
				end
			end)	
		end
		
		local teamlabel = vgui.CreateFromTable(TEAM_LABEL_LINE)
		teamlabel.Name:SetText(team.GetName(TEAM_RUNNER))
		teamlabel.TeamId = TEAM_RUNNER
		teamlabel.BGColor = SaturateColor(Color(231, 76, 60))
		AddTeamLblReceiver(teamlabel, "runner")
		self.PScores:AddItem(teamlabel)	
		AddTeamLblReceiver(self.PScores, "runner")
		
		self.SpecScores = self.TheScores:Add( "DScrollPanel" )
		self.SpecScores:Dock(FILL)
		
		local teamlabel = vgui.CreateFromTable(TEAM_LABEL_LINE)
		teamlabel.Name:SetText(team.GetName(TEAM_SPECTATOR))
		teamlabel.TeamId = TEAM_SPECTATOR
		teamlabel.BGColor = SaturateColor(Color(243, 156, 18))
		AddTeamLblReceiver(teamlabel, "spectator")
		self.SpecScores:AddItem(teamlabel)
		AddTeamLblReceiver(self.SpecScores, "spectator")
		
		self.GScores = self.TheScores:Add( "DScrollPanel" )
		self.GScores:Dock(RIGHT)
	
		local teamlabel = vgui.CreateFromTable(TEAM_LABEL_LINE)
		teamlabel.Name:SetText(team.GetName(TEAM_DEATH))
		teamlabel.TeamId = TEAM_DEATH
		teamlabel.BGColor = SaturateColor(Color(52, 73, 94))
		AddTeamLblReceiver(teamlabel, "death")
		self.GScores:AddItem(teamlabel)
		AddTeamLblReceiver(self.GScores, "death")
	end,
	
	PerformLayout = function( self )
		
		local width = 950
		
		local sb_x, sb_w = 250, ScrW()-250
		if ScrW() < 1200 then -- WTF
		    sb_x, sb_w = 0, ScrW()
		end
	
		self:SetSize( ScrW()-250, ScrH() - 200 )
		self:SetPos( 250, 100 )
		
		local elwidth = ScrW()/2-width/2
		self.EventLogScroll:SetPos(ScrW() - elwidth, 100)
		self.EventLogScroll:SetSize(elwidth, ScrH()-400)
		self.EventLog:SetSize(elwidth, #self.EventLog.Items * 14)
		
		local specwidth = 300
		
		self.TheScores:SetPos(200, 100)
		self.TheScores:SetSize(width, ScrH()-200)
		self.PScores:SetSize(width/2 - specwidth/2, 100)
		self.SpecScores:SetSize(specwidth, 100)
		self.GScores:SetSize(width/2 - specwidth/2, 100)
	
	end,
	
	Paint = function( self, w, h )
	
		--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
	
	end,
	
	Think = function( self, w, h )
	
		self.Name:SetText( GetHostName() )
		
		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do
			local targscore = self.SpecScores
			if pl:Team() == TEAM_RUNNER then
				targscore = self.PScores
			elseif pl:Team() == TEAM_DEATH then
				targscore = self.GScores	
			end
			local oldts
			if IsValid(pl.ScoreEntry) and pl.ScoreEntry.SBParent == targscore then continue end
			if IsValid(pl.ScoreEntry) then oldts = pl.ScoreEntry.SBParent pl.ScoreEntry:Remove() end
			
			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry.SBParent = targscore -- ??
			pl.ScoreEntry:Setup( pl )
			pl.ScoreEntry:Droppable("plydnd")
			
			targscore:AddItem( pl.ScoreEntry )
		
		end

	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

hook.Add("ScoreboardShow", "ShowScoreBoard", function()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Remove()
	end
	g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	
	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end
	
	return true
end)

hook.Add("ScoreboardHide", "HideScoreBoard", function()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end
	
	return true
end)

hook.Add("HUDDrawScoreBoard", "DrawScoreBoard", function()
    return true
end)

function CoolHUD()
	draw.RoundedBox(0,ScrW()/2,ScrH()-35,(LocalPlayer():GetVelocity():Length()/1000)*100,25,Color(100,100,100,205))

end
hook.Add( "HUDPaint", "CoolHUD", CoolHUD )
