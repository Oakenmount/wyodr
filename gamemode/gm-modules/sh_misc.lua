
ROUND_WAIT = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

wyodr.GetRoundState = function()
    return GetGlobalInt("roundstate", ROUND_WAIT)
end