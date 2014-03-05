hook.Add("CreateMove", "BHop", function(ucmd)
	if IsValid(LocalPlayer()) and bit.band(ucmd:GetButtons(), IN_DUCK) > 0 then
		if LocalPlayer():OnGround() then
			ucmd:SetButtons( bit.bor(ucmd:GetButtons(), IN_JUMP) )
		end
	end
end)