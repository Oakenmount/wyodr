hook.Add("CreateMove", "BHop", function(ucmd)
	if IsValid(LocalPlayer()) and bit.band(ucmd:GetButtons(), IN_JUMP) > 0 then
		if LocalPlayer():OnGround() then
            ucmd:SetButtons( ucmd:GetButtons() + IN_JUMP )
		end
	end
end)