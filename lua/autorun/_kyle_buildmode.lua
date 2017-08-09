local CATEGORY_NAME = "_Kyle_1"

------------------------------ Buildmode ------------------------------
--Weapons the player can spawn while in Buildmode
 _kyle_builderSpawnableWeapons={
 	"weapon_physgun",
	"gmod_tool",
	"gmod_camera"
}
--Weapons the player gets reset to when switched to Buildmode
 _kyle_builderWeapons={
 	"weapon_physgun",
 	"gmod_tool",
 	"gmod_camera"
}
function _kyle_buildweapons(ply)
	ply:StripWeapons()
	for i=1,#_kyle_builderWeapons do 
        ply:Give(_kyle_builderWeapons[i])
    end
end
hook.Add("PlayerGiveSWEP", "_kyle_Buildmode_TrySWEPGive", function(ply, wep)
     if ply.buildmode and !table.HasValue(_kyle_builderSpawnableWeapons,wep) then
        ply:SendLua("GAMEMODE:AddNotify(\"You cannot give yourself weapons while in Buildmode.\",NOTIFY_GENERIC, 5)")
        return false
    end
end)
hook.Add("PlayerSpawnSWEP", "_kyle_Buildmode_TrySWEPSpawn", function(ply, wep)
    if ply.buildmode and !table.HasValue(_kyle_builderSpawnableWeapons,wep) then
        ply:SendLua("GAMEMODE:AddNotify(\"You cannot spawn weapons while in Buildmode.\",NOTIFY_GENERIC, 5)")
        return false
    end
end)
hook.Add("PlayerCanPickupWeapon", "_kyle_Buildmode_TrySWEPPickup", function(ply, wep)
    local weapon = string.Explode("]", table.GetLastValue(string.Explode( "[", tostring(wep))))
    table.remove(weapon, 2)
    if ply.buildmode and !table.HasValue(_kyle_builderSpawnableWeapons,table.GetLastValue(weapon)) then
        if ply:GetNWInt("_kyle_buildNotify") == 1 then
            ply:SetNWInt("_kyle_buildNotify", 0)
            ply:SendLua("GAMEMODE:AddNotify(\"You cannot pick up weapons while in Buildmode.\",NOTIFY_GENERIC, 5)") 
            timer.Simple( 5, function()
                ply:SetNWInt("_kyle_buildNotify", 1)
            end)
        end
        return false   
    end
end)
hook.Add("PlayerShouldTakeDamage", "_kyle_Buildmode_TryTakeDamage", function(ply, v)
	if ply.buildmode or v.buildmode then
		return false
	end
end)
function ulx.buildmode( calling_ply, target_plys, should_revoke )
    local affected_plys = {}
	for i=1, #target_plys do
        local ply = target_plys[ i ]
        if ply.buildmode == nil && not should_revoke then
            ULib.getSpawnInfo( ply )
            ply:StripWeapons()
            _kyle_buildweapons(ply)
            ply.buildmode = true
        elseif ply.buildmode != nil && should_revoke then
            ply.buildmode = nil
            if ply:Alive() then
                local pos = ply:GetPos()
                ULib.spawn( ply, true )
                ply:SetPos( pos )
            end
        end
        table.insert( affected_plys, ply )
	end

	if should_revoke then
		ulx.fancyLogAdmin( calling_ply, "#A revoked Buildmode mode from #T", affected_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A granted Buildmode mode upon #T", affected_plys )
	end
end
local buildmode = ulx.command( CATEGORY_NAME, "ulx buildmode", ulx.buildmode, "!buildmode" )
buildmode:addParam{ type=ULib.cmds.PlayersArg }
buildmode:defaultAccess( ULib.ACCESS_ALL )
buildmode:addParam{ type=ULib.cmds.BoolArg, invisible=true }
buildmode:help( "Grants Buildmode mode to target(s)." )
buildmode:setOpposite( "ulx unbuildmode", {_, _, true}, "!unbuildmode" )
