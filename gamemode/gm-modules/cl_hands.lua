hook.Add("PostDrawViewModel", "DrawHands", function( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end

end)