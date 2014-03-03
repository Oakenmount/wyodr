hook.Add("HUDPaint", "swag", function()
    draw.SimpleText(tostring(wyodr.GetRoundState()), "DermaLarge", 100, 100)
        
    local roundProgress = (CurTime() - GetGlobalFloat("roundstart"))
    local roundEnd = (GetGlobalFloat("roundend") - CurTime())
        
    draw.SimpleText(string.ToMinutesSeconds(math.Round(roundEnd)), "DermaLarge", 100, 130)
end)