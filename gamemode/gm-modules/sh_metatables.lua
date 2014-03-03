local Player = FindMetaTable("Player")
 
function Player:Error(type)
   self:SendLua(Error(type))
end
