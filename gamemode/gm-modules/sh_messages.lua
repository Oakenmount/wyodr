MSG_NOTIFY = 1
MSG_ERROR = 2

-- TODO move this stuff to wyolib

if SERVER then
    util.AddNetworkString("wyodrMsg")
	function wyodr.ErrorMsg(ply, ...)
		net.Start("wyodrMsg")
			net.WriteUInt(MSG_ERROR,8)
			net.WriteTable({...})
		net.Send(ply)
	end
	
	function wyodr.NotifyPly(ply, ...)
		net.Start("wyodrMsg")
			net.WriteUInt(MSG_NOTIFY,8)
			net.WriteTable({...})
		net.Send(ply)
	end
	
	function wyodr.Notify(...)
		net.Start("wyodrMsg")
			net.WriteUInt(MSG_NOTIFY,8)
			net.WriteTable({...})
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive("wyodrMsg",function()
		local type = net.ReadUInt(8)
		local things = net.ReadTable()
		if type == MSG_ERROR then 
			chat.AddText(Color(255,150,0),"[ERROR] ", unpack(things))
			surface.PlaySound("common/wpn_denyselect.wav")
		elseif type == MSG_NOTIFY then
			chat.AddText(Color(10,115,0),"[Deathrun] ",Color(255,255,255), unpack(things))
		end
		
	end)
	
	function wyodr.NotifySelf(...)
        chat.AddText(Color(10,115,0),"[Deathrun] ",Color(255,255,255), unpack({...}))
	end
	
end