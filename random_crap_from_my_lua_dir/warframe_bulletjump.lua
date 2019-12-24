local tag = "warframe_bulletjump"

local sounds = {
	"sound/warframe/BulletJump.ogg",
	"sound/warframe/BulletJumpA.ogg",
	"sound/warframe/BulletJumpC.ogg", -- rip B
}

local w_bulletjump

if SERVER then
	for _, v in ipairs(sounds) do
		resource.AddFile(v)
	end
else
	w_bulletjump = CreateClientConVar(tag, 1, true, true)
end

hook.Add("SetupMove", tag, function(ply, cmove, ccmd)
	if not IsFirstTimePredicted() then return end
	if ply.IsSitting and ply:IsSitting() then return end
	if (SERVER and ply:GetInfoNum(tag, 1) == 0) or (CLIENT and w_bulletjump and not w_bulletjump:GetBool()) then return end

	local crouching = bit.band(cmove:GetButtons(), IN_DUCK)
	local jumping = bit.band(cmove:GetButtons(), IN_JUMP)

	if ply:GetMoveType() == MOVETYPE_WALK and crouching ~= 0 and jumping ~= 0 and (not ply.is_bulletjumping or ply.is_bulletjumping < CurTime()) and not ply.is_pressing_space then
		ply.is_bulletjumping = CurTime() + 0.5
		ply.is_pressing_space = true
		cmove:SetVelocity(ply:GetAimVector() * 510)
		if CLIENT then
			sound.PlayFile(sounds[math.random(1, #sounds)], [[]], function() end)
		end
	end

	if jumping == 0 and ply.is_pressing_space and ply:IsOnGround() then
		ply.is_pressing_space = false
	end
end)
