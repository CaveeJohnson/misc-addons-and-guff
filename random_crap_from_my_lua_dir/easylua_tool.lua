setfenv(1, _G)

g_ToolObj = g_ToolObj or {}

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function g_ToolObj:MakeGhostEntity( model, pos, angle )

	util.PrecacheModel( model )
	-- We do ghosting serverside in single player
	-- It's done clientside in multiplayer
	if ( SERVER && !game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end

	-- The reason we need this is because in multiplayer, when you holster a tool serverside,
	-- either by using the spawnnmenu's Weapons tab or by simply entering a vehicle,
	-- the Think hook is called once after Holster is called on the client, recreating the ghost entity right after it was removed.
	if ( self.GhostEntityLastDelete && self.GhostEntityLastDelete + 0.1 > CurTime() ) then return end

	-- Release the old ghost entity
	self:ReleaseGhostEntity()

	-- Don't allow ragdolls/effects to be ghosts
	if ( !util.IsValidProp( model ) ) then return end

	if ( CLIENT ) then
		self.GhostEntity = ents.CreateClientProp( model )
	else
		self.GhostEntity = ents.Create( "prop_physics" )
	end

	-- If there's too many entities we might not spawn..
	if ( !IsValid( self.GhostEntity ) ) then
		self.GhostEntity = nil
		return
	end

	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()

	self.GhostEntity:SetSolid( SOLID_VPHYSICS )
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true )
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ) )

end

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function g_ToolObj:StartGhostEntity( ent )

	-- We do ghosting serverside in single player
	-- It's done clientside in multiplayer
	if ( SERVER && !game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end

	self:MakeGhostEntity( ent:GetModel(), ent:GetPos(), ent:GetAngles() )

end

--[[---------------------------------------------------------
	Releases up the ghost entity
-----------------------------------------------------------]]
function g_ToolObj:ReleaseGhostEntity()

	if ( self.GhostEntity ) then
		if ( !IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end
		self.GhostEntity:Remove()
		self.GhostEntity = nil
		self.GhostEntityLastDelete = CurTime()
	end

	-- This is unused!
	if ( self.GhostEntities ) then

		for k,v in pairs( self.GhostEntities ) do
			if ( IsValid( v ) ) then v:Remove() end
			self.GhostEntities[ k ] = nil
		end

		self.GhostEntities = nil
		self.GhostEntityLastDelete = CurTime()
	end

	-- This is unused!
	if ( self.GhostOffset ) then

		for k,v in pairs( self.GhostOffset ) do
			self.GhostOffset[ k ] = nil
		end

	end

end

--[[---------------------------------------------------------
	Update the ghost entity
-----------------------------------------------------------]]
function g_ToolObj:UpdateGhostEntity()

	if ( self.GhostEntity == nil ) then return end
	if ( !IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end

	local trace = self:GetOwner():GetEyeTrace()
	if ( !trace.Hit ) then return end

	local Ang1, Ang2 = self:GetNormal( 1 ):Angle(), ( trace.HitNormal * -1 ):Angle()
	local TargetAngle = self:GetEnt( 1 ):AlignAngles( Ang1, Ang2 )

	self.GhostEntity:SetPos( self:GetEnt( 1 ):GetPos() )
	self.GhostEntity:SetAngles( TargetAngle )

	local TranslatedPos = self.GhostEntity:LocalToWorld( self:GetLocalPos( 1 ) )
	local TargetPos = trace.HitPos + ( self:GetEnt( 1 ):GetPos() - TranslatedPos ) + trace.HitNormal

	self.GhostEntity:SetPos( TargetPos )

end


function g_ToolObj:UpdateData()

	self:SetStage( self:NumObjects() )

end

function g_ToolObj:SetStage( i )

	if ( SERVER ) then
		self:GetWeapon():SetNWInt( "Stage", i, true )
	end

end

function g_ToolObj:GetStage()
	return self:GetWeapon():GetNWInt( "Stage", 0 )
end

function g_ToolObj:SetOperation( i )

	if ( SERVER ) then
		self:GetWeapon():SetNWInt( "Op", i, true )
	end

end

function g_ToolObj:GetOperation()
	return self:GetWeapon():GetNWInt( "Op", 0 )
end


-- Clear the selected objects
function g_ToolObj:ClearObjects()

	self:ReleaseGhostEntity()
	self.Objects = {}
	self:SetStage( 0 )
	self:SetOperation( 0 )

end

--[[---------------------------------------------------------
	Since we're going to be expanding this a lot I've tried
	to add accessors for all of this crap to make it harder
	for us to mess everything up.
-----------------------------------------------------------]]
function g_ToolObj:GetEnt( i )

	if ( !self.Objects[i] ) then return NULL end

	return self.Objects[i].Ent
end


--[[---------------------------------------------------------
	Returns the world position of the numbered object hit
	We store it as a local vector then convert it to world
	That way even if the object moves it's still valid
-----------------------------------------------------------]]
function g_ToolObj:GetPos( i )

	if ( self.Objects[i].Ent:EntIndex() == 0 ) then
		return self.Objects[i].Pos
	else
		if ( IsValid( self.Objects[i].Phys ) ) then
			return self.Objects[i].Phys:LocalToWorld( self.Objects[i].Pos )
		else
			return self.Objects[i].Ent:LocalToWorld( self.Objects[i].Pos )
		end
	end

end

-- Returns the local position of the numbered hit
function g_ToolObj:GetLocalPos( i )
	return self.Objects[i].Pos
end

-- Returns the physics bone number of the hit (ragdolls)
function g_ToolObj:GetBone( i )
	return self.Objects[i].Bone
end

function g_ToolObj:GetNormal( i )
	if ( self.Objects[i].Ent:EntIndex() == 0 ) then
		return self.Objects[i].Normal
	else
		local norm
		if ( IsValid( self.Objects[i].Phys ) ) then
			norm = self.Objects[i].Phys:LocalToWorld( self.Objects[i].Normal )
		else
			norm = self.Objects[i].Ent:LocalToWorld( self.Objects[i].Normal )
		end

		return norm - self:GetPos(i)
	end
end

-- Returns the physics object for the numbered hit
function g_ToolObj:GetPhys( i )

	if ( self.Objects[i].Phys == nil ) then
		return self:GetEnt(i):GetPhysicsObject()
	end

	return self.Objects[i].Phys
end


-- Sets a selected object
function g_ToolObj:SetObject( i, ent, pos, phys, bone, norm )

	self.Objects[i] = {}
	self.Objects[i].Ent = ent
	self.Objects[i].Phys = phys
	self.Objects[i].Bone = bone
	self.Objects[i].Normal = norm

	-- Worldspawn is a special case
	if ( ent:EntIndex() == 0 ) then

		self.Objects[i].Phys = nil
		self.Objects[i].Pos = pos

	else

		norm = norm + pos

		-- Convert the position to a local position - so it's still valid when the object moves
		if ( IsValid( phys ) ) then
			self.Objects[i].Normal = self.Objects[i].Phys:WorldToLocal( norm )
			self.Objects[i].Pos = self.Objects[i].Phys:WorldToLocal( pos )
		else
			self.Objects[i].Normal = self.Objects[i].Ent:WorldToLocal( norm )
			self.Objects[i].Pos = self.Objects[i].Ent:WorldToLocal( pos )
		end

	end

	if ( SERVER ) then
		-- Todo: Make sure the client got the same info
	end

end


-- Returns the number of objects in the list
function g_ToolObj:NumObjects()

	if ( CLIENT ) then

		return self:GetStage()

	end

	return #self.Objects

end


-- Returns the number of objects in the list
function g_ToolObj:GetHelpText()

	return "#tool." .. GetConVarString( "gmod_toolmode" ) .. "." .. self:GetStage()

end


if CLIENT then


-- Tool should return true if freezing the view angles
function g_ToolObj:FreezeMovement()
	return false
end

-- The tool's opportunity to draw to the HUD
function g_ToolObj:DrawHUD()
end


end


function g_ToolObj:Create()

	local o = {}

	setmetatable( o, self )
	self.__index = self

	o.Mode				= nil
	o.SWEP				= nil
	o.Owner				= nil
	o.ClientConVar		= {}
	o.ServerConVar		= {}
	o.Objects			= {}
	o.Stage				= 0
	o.Message			= "start"
	o.LastMessage		= 0
	o.AllowedCVar		= 0

	return o

end

function g_ToolObj:CreateConVars()

	local mode = self:GetMode()

	if ( CLIENT ) then

		for cvar, default in pairs( self.ClientConVar ) do

			CreateClientConVar( mode .. "_" .. cvar, default, true, true )

		end

		return
	end

	-- Note: I changed this from replicated because replicated convars don't work
	-- when they're created via Lua.

	if ( SERVER ) then

		self.AllowedCVar = CreateConVar( "toolmode_allow_" .. mode, 1, FCVAR_NOTIFY )

	end

end

function g_ToolObj:GetServerInfo( property )

	local mode = self:GetMode()

	return GetConVarString( mode .. "_" .. property )

end

function g_ToolObj:BuildConVarList()

	local mode = self:GetMode()
	local convars = {}

	for k, v in pairs( self.ClientConVar ) do convars[ mode .. "_" .. k ] = v end

	return convars

end

function g_ToolObj:GetClientInfo( property )

	return self:GetOwner():GetInfo( self:GetMode() .. "_" .. property )

end

function g_ToolObj:GetClientNumber( property, default )

	return self:GetOwner():GetInfoNum( self:GetMode() .. "_" .. property, tonumber( default ) or 0 )

end

function g_ToolObj:Allowed()

	if ( CLIENT ) then return true end
	return self.AllowedCVar:GetBool()

end

-- Now for all the g_ToolObj redirects

function g_ToolObj:Init() end

function g_ToolObj:GetMode()		return self.Mode end
function g_ToolObj:GetSWEP()		return self.SWEP end
function g_ToolObj:GetOwner()		return self:GetSWEP().Owner or self.Owner end
function g_ToolObj:GetWeapon()	return self:GetSWEP().Weapon or self.Weapon end

function g_ToolObj:LeftClick()	return false end
function g_ToolObj:RightClick()	return false end
function g_ToolObj:Reload()		self:ClearObjects() end
function g_ToolObj:Deploy()		self:ReleaseGhostEntity() return end
function g_ToolObj:Holster()		self:ReleaseGhostEntity() return end
function g_ToolObj:Think()		self:ReleaseGhostEntity() end

--[[---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
-----------------------------------------------------------]]
function g_ToolObj:CheckObjects()

	for k, v in pairs( self.Objects ) do

		if ( !v.Ent:IsWorld() && !v.Ent:IsValid() ) then
			self:ClearObjects()
		end

	end

end

local _toolmode
function easylua.StartTool(toolmode)
	if TOOL then easylua.Print("attempting to register tool before finishing: " .. toolmode) end

	TOOL = g_ToolObj:Create()
	TOOL.Mode = toolmode
	_toolmode = toolmode
end

function easylua.EndTool()
	if not TOOL then error("ending tool before starting", 2) end
	TOOL:CreateConVars()

	local real_tool = weapons.GetStored"gmod_tool".Tool
	real_tool[_toolmode or TOOL.mode] = TOOL

	TOOL = nil

	for _, v in ipairs(ents.FindByClass("gmod_tool")) do
		v.Tool = real_tool
		v:InitializeTools()
	end
end
