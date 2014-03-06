local le_epik_taunts = {
    ["models/player/arnold_schwarzenegger.mdl"] = {
        "http://puu.sh/73BAs.mp3",
        "http://puu.sh/73BAU.mp3",
        "http://puu.sh/73BBw.mp3"
    },
    ["models/player/cj.mdl"] = {
        "http://puu.sh/73wYL.mp3",
        "http://puu.sh/73x4A.mp3",
        "http://puu.sh/73x68.mp3"
    },
    ["models/player/jack_sparrow.mdl"] = {
        "http://puu.sh/7b9va.mp3",
        "http://puu.sh/7b9vR.mp3",
        "http://puu.sh/7b9w6.mp3"
    },
    ["models/player/hagrid.mdl"] = {
        "http://puu.sh/77LXC.mp3"    
    },
    ["models/player/slow/mario.mdl"] = {
        "http://puu.sh/77MkZ.mp3"    
    },
    ["models/player/bloodz/slow_1.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/player/bloodz/slow_2.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/player/bloodz/slow_3.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/player/cripz/slow_1.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/player/cripz/slow_2.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/player/cripz/slow_2.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    },
    ["models/nba2k11/players/jordan/jordan.mdl"] = {
        "http://puu.sh/77S63.mp3",
        "http://puu.sh/77S8m.mp3",
        "http://puu.sh/77S9O.mp3"
    }
    
    
}


if SERVER then
    util.AddNetworkString("UseTaunt")
    util.AddNetworkString("EmmitTaunt")
    net.Receive("UseTaunt",function(len,ply)
        local ply_model = ply:GetModel()
        local rand_taunt = table.Random(le_epik_taunts[ply_model])
        if not ply:IsSupporter() then return end
        for k,v in pairs(player.GetAll()) do    
            net.Start("EmmitTaunt")
                net.WriteString(rand_taunt)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end)
end

if CLIENT then
    function SendTauntToServer()
        local ply = LocalPlayer()
        if le_epik_taunts[ply:GetModel()] then
            net.Start("UseTaunt")
            net.SendToServer()
        end
    end

        
    concommand.Add("jb_taunt",function(ply)
        if not ply.NextTaunt or ply.NextTaunt < CurTime() then
            if not ply:IsSupporter() then epicjb.NotifyPly(ply,"Supporter feature!") return end
            ply.NextTaunt = CurTime() + 5
            SendTauntToServer()
        end
    end)
        

    net.Receive("EmmitTaunt",function(len)
        local TauntSound = net.ReadString()
        local PL = net.ReadEntity()
        if PL:IsValid() and PL:Alive() then
            PlayThaURL(TauntSound,PL)
		end
    end)

    hook.Add("Think", "Move3dTauntSounds", function()
        for _,ply in pairs(player.GetAll()) do
            if IsValid(ply.TauntSound) then ply.TauntSound:SetPos(ply:EyePos()) end    
        end
    end)

    function PlayThaURL(url,PL)           
        sound.PlayURL(url, "3d", function(station)
    	    if not ( IsValid( station ) ) then return end
    	    if not IsValid(PL) then return end
    		station:SetPos( PL:EyePos() ) 
    		station:Play()
    		station:SetVolume( 1 )
    		
    		PL.TauntSound = station
    	end)
	end
	
end