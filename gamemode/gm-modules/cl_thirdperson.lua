
local tp_enabled = CreateClientConVar( "wyo_thirdperson", 0, true, false )
local tp_distance = CreateClientConVar( "wyo_thirdperson_dist", 50, true, false )

local startfakeangle, fakeangleoffset

hook.Add("CalcView", "MistL_CalcView", function(ply, origin, angles, fov, znear, zfar)

	if ply:Alive() and tp_enabled:GetBool() then

        if IsValid(ply:GetVehicle()) then return end
        if IsValid(ply:GetDrivingEntity()) then return end

        local view = {}
        view.origin = origin
        view.angles = angles
        view.fov = fov
        view.znear  = znear
        view.zfar   = zfar
        view.drawviewer = true
     
        local radius = tp_distance:GetFloat()

        -- Trace back from the original eye position, so we don't clip through walls/objects

        local TargetOrigin = view.origin + ( (wyolib.fakeangle or view.angles):Forward() * -radius )
        local WallOffset = 4;

        local tr = util.TraceHull({
            start   = view.origin,
            endpos  = TargetOrigin,
            filter = player.GetAll(),
            mins    = Vector( -WallOffset, -WallOffset, -WallOffset ),
            maxs    = Vector( WallOffset, WallOffset, WallOffset ),
        })

        view.origin = tr.HitPos
        view.drawviewer = true

        if wyolib.fakeangle then
            view.angles = wyolib.fakeangle
        end

        --
        -- If the trace hit something, put the camera there.
        --
        if ( tr.Hit && !tr.StartSolid) then
            view.origin = view.origin + tr.HitNormal * WallOffset
        end

		--[[local eyepos = ply:EyePos()

        local tp_dist = math.Clamp(tp_distance:GetInt(), 0, 500)
 
        local plyang = ply:GetAimVector()
        local tracedata = {}
        tracedata.start = eyepos
        tracedata.endpos = eyepos - (angles:Forward() * tp_dist)
        tracedata.filter = ply
        tracedata.mask = MASK_SOLID_BRUSHONLY
        local trace = util.TraceLine(tracedata)]]
 
	    return view

	end

end)

hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
    if IsValid(ply:GetVehicle()) then return end
    return tp_enabled:GetBool()
end)

--[[
function GM:CalcVehicleView( Vehicle, ply, view )

    if not tp_enabled:GetBool() then return view end

    -- Don't roll the camera
    -- view.angles.roll = 0

    --local mn, mx = Vehicle:GetRenderBounds()
    --local radius = (mn - mx):Length()
    --local radius = radius + radius * Vehicle:GetCameraDistance();
    local radius = tp_distance:GetFloat()

    -- Trace back from the original eye position, so we don't clip through walls/objects
    local TargetOrigin = view.origin + ( view.angles:Forward() * -radius )
    local WallOffset = 4;

    local tr = util.TraceHull({
        start   = view.origin,
        endpos  = TargetOrigin,
        filter  = Vehicle,
        mins    = Vector( -WallOffset, -WallOffset, -WallOffset ),
        maxs    = Vector( WallOffset, WallOffset, WallOffset ),
    })

    view.origin = tr.HitPos
    view.drawviewer = true

    --
    -- If the trace hit something, put the camera there.
    --
    if ( tr.Hit && !tr.StartSolid) then
        view.origin = view.origin + tr.HitNormal * WallOffset
    end

    return view

end]]

local amount = 15
hook.Add( "PlayerBindPress", "MistL_BindPressCamera", function( ply, bind, down )
        if IsValid(ply) and ply:Alive() and gmod.GetGamemode().Name == "Deathrun" then
        local newdist
        if string.find(bind, "invprev") then
            newdist = math.Clamp( tp_distance:GetInt() - amount, 0, 150)
        elseif string.find(bind, "invnext") then
            newdist = math.Clamp( tp_distance:GetInt() + amount, 0, 150)
        end

        if newdist then
            RunConsoleCommand("wyo_thirdperson", (newdist < 5 and "0" or "1s"))
            RunConsoleCommand("wyo_thirdperson_dist", tostring(newdist))
            return true
        end

   end
end)

hook.Add("InputMouseApply", "WW_ThirdPersonRotate", function(cmd, x, y, angle)
    --[[if LocalPlayer():KeyDown(IN_ATTACK2) and tp_enabled:GetBool() and not IsValid(LocalPlayer():GetDrivingEntity()) then
        if not wyolib.fakeangle then
            startfakeangle = angle
            angle = angle + (fakeangleoffset or Angle(0, 0, 0))
        end
        wyolib.fakeangle = (wyolib.fakeangle or angle)
        wyolib.fakeangle.y = wyolib.fakeangle.y + x * (0.035)
        wyolib.fakeangle.p = wyolib.fakeangle.p + y * (0.035)
        return true
    end
    if wyolib.fakeangle and startfakeangle then
        fakeangleoffset = wyolib.fakeangle - startfakeangle
    end
    wyolib.fakeangle = nil]]
end)