--[[
UTIL_PlayerDecalTrace( &tr, playernum );
void R_PlayerDecalShoot( IMaterial *material, void *userdata, int entity, const model_t *model,
	const Vector& position, const Vector *saxis, int flags, const color32 &rgbaColor )
{
	// The userdata that is passed in is actually
	// the player number (integer), not sure why it can't be zero.
	Assert( userdata != 0 );

	//
	// Linear search through decal pool to retire any other decals this
	// player has sprayed.  It appears that multiple decals can be
	// allocated for a single spray due to the way they are mapped to
	// surfaces.  We need to run through and clean them all up.  This
	// seems like the cleanest way to manage this - especially since
	// it doesn't happen that often.
	//
	int i;
	CUtlVector<decal_t *> decalVec;

	for ( i = 0; i<s_aDecalPool.Count(); i++ )
	{
		decal_t * decal = s_aDecalPool[i];

		if( decal &&
			decal->flags & FDECAL_PLAYERSPRAY &&
			decal->userdata == userdata )
		{
			decalVec.AddToTail( decal );
		}
	}

	// remove all the sprays we found
	for ( i = 0; i < decalVec.Count(); i++ )
	{
		R_DecalUnlink( decalVec[i], host_state.worldbrush );
	}

	// set this to be a player spray so it is timed out appropriately.
	flags |= FDECAL_PLAYERSPRAY;

	R_DecalShoot_( material, entity, model, position, saxis, flags, rgbaColor, userdata );
}

static void R_DecalShoot_( IMaterial *pMaterial, int entity, const model_t *model,
						  const Vector &position, const Vector *saxis, int flags, const color32 &rgbaColor, void *userdata = 0 )
{
	decalinfo_t decalInfo;
	VectorCopy( position, decalInfo.m_Position );	// Pass position in global

	if ( !model || model->type != mod_brush || !pMaterial )
		return;

	decalInfo.m_pModel = (model_t *)model;
	decalInfo.m_pBrush = model->brush.pShared;

	// Deal with the s axis if one was passed in
	if (saxis)
	{
		flags |= FDECAL_USESAXIS;
		VectorCopy( *saxis, decalInfo.m_SAxis );
	}

	// More state used by R_DecalNode()
	decalInfo.m_pMaterial = pMaterial;
	decalInfo.m_pUserData = userdata;

	// Don't optimize custom decals
	if ( !(flags & FDECAL_CUSTOM) )
		flags |= FDECAL_CLIPTEST;

	decalInfo.m_Flags = flags;
	decalInfo.m_Entity = entity;
	decalInfo.m_Size = pMaterial->GetMappingWidth() >> 1;
	if ( (int)(pMaterial->GetMappingHeight() >> 1) > decalInfo.m_Size )
		decalInfo.m_Size = pMaterial->GetMappingHeight() >> 1;

	// Compute scale of surface
	// FIXME: cache this?
	IMaterialVar *decalScaleVar;
	bool found;
	decalScaleVar = decalInfo.m_pMaterial->FindVar( "$decalScale", &found, false );
	if( found )
	{
		decalInfo.m_scale = 1.0f / decalScaleVar->GetFloatValue();
		decalInfo.m_Size *= decalScaleVar->GetFloatValue();
	}
	else
	{
		decalInfo.m_scale = 1.0f;
	}

	// compute the decal dimensions in world space
	decalInfo.m_decalWidth = pMaterial->GetMappingWidth() / decalInfo.m_scale;
	decalInfo.m_decalHeight = pMaterial->GetMappingHeight() / decalInfo.m_scale;
	decalInfo.m_Color = rgbaColor;

	decalInfo.m_aApplySurfs.Purge();

	// Clear the displacement tags because we use them in R_DecalNode.
	DispInfo_ClearAllTags( decalInfo.m_pBrush->hDispInfos );

	mnode_t *pnodes = decalInfo.m_pBrush->nodes + decalInfo.m_pModel->brush.firstnode;
	R_DecalNode( pnodes, &decalInfo );
}

static void R_DecalNode( mnode_t *node, decalinfo_t* decalinfo )
{
	cplane_t	*splitplane;
	float		dist;

	if (!node )
		return;
	if ( node->contents >= 0 )
	{
		R_DecalLeaf( (mleaf_t *)node, decalinfo );
		return;
	}

	splitplane = node->plane;
	dist = DotProduct (decalinfo->m_Position, splitplane->normal) - splitplane->dist;

	// This is arbitrarily set to 10 right now.  In an ideal world we'd have the
	// exact surface but we don't so, this tells me which planes are "sort of
	// close" to the gunshot -- the gunshot is actually 4 units in front of the
	// wall (see dlls\weapons.cpp). We also need to check to see if the decal
	// actually intersects the texture space of the surface, as this method tags
	// parallel surfaces in the same node always.
	// JAY: This still tags faces that aren't correct at edges because we don't
	// have a surface normal

	if (dist > decalinfo->m_Size)
	{
		R_DecalNode (node->children[0], decalinfo);
	}
	else if (dist < -decalinfo->m_Size)
	{
		R_DecalNode (node->children[1], decalinfo);
	}
	else
	{
		if ( dist < DECAL_DISTANCE && dist > -DECAL_DISTANCE )
			R_DecalNodeSurfaces( node, decalinfo );

		R_DecalNode (node->children[0], decalinfo);
		R_DecalNode (node->children[1], decalinfo);
	}
}

void R_DecalLeaf( mleaf_t *pLeaf, decalinfo_t *decalinfo )
{
	SurfaceHandle_t *pHandle = &host_state.worldbrush->marksurfaces[pLeaf->firstmarksurface];
	for ( int i = 0; i < pLeaf->nummarksurfaces; i++ )
	{
		SurfaceHandle_t surfID = pHandle[i];

		// only process leaf surfaces
		if ( MSurf_Flags( surfID ) & (SURFDRAW_NODE|SURFDRAW_NODECALS) )
			continue;

		if ( decalinfo->m_aApplySurfs.Find( surfID ) != -1 )
			continue;

		Assert( !MSurf_DispInfo( surfID ) );

		float dist = fabs( DotProduct(decalinfo->m_Position, MSurf_Plane( surfID ).normal) - MSurf_Plane( surfID ).dist);
		if ( dist < DECAL_DISTANCE )
		{
			R_DecalSurface( surfID, decalinfo, false );
		}
	}

	// Add the decal to each displacement in the leaf it touches.
	for ( int i = 0; i < pLeaf->dispCount; i++ )
	{
		IDispInfo *pDispInfo = MLeaf_Disaplcement( pLeaf, i );

		SurfaceHandle_t surfID = pDispInfo->GetParent();

		if ( MSurf_Flags( surfID ) & SURFDRAW_NODECALS )
			continue;

		// Make sure the decal hasn't already been added to it.
		if( pDispInfo->GetTag() )
			continue;

		pDispInfo->SetTag();

		// Trivial bbox reject.
		Vector bbMin, bbMax;
		pDispInfo->GetBoundingBox( bbMin, bbMax );
		if( decalinfo->m_Position.x - decalinfo->m_Size < bbMax.x && decalinfo->m_Position.x + decalinfo->m_Size > bbMin.x &&
			decalinfo->m_Position.y - decalinfo->m_Size < bbMax.y && decalinfo->m_Position.y + decalinfo->m_Size > bbMin.y &&
			decalinfo->m_Position.z - decalinfo->m_Size < bbMax.z && decalinfo->m_Position.z + decalinfo->m_Size > bbMin.z )
		{
			R_DecalSurface( pDispInfo->GetParent(), decalinfo, true );
		}
	}
}

void R_DecalSurface( SurfaceHandle_t surfID, decalinfo_t *decalinfo, bool bForceForDisplacement )
{
	// Get the texture associated with this surface
	mtexinfo_t* tex = MSurf_TexInfo( surfID );

	Vector4D &textureU = tex->textureVecsTexelsPerWorldUnits[0];
	Vector4D &textureV = tex->textureVecsTexelsPerWorldUnits[1];

	// project decal center into the texture space of the surface
	float s = DotProduct( decalinfo->m_Position, textureU.AsVector3D() ) +
		textureU.w - MSurf_TextureMins( surfID )[0];
	float t = DotProduct( decalinfo->m_Position, textureV.AsVector3D() ) +
		textureV.w - MSurf_TextureMins( surfID )[1];


	// Determine the decal basis (measured in world space)
	// Note that the decal basis vectors 0 and 1 will always lie in the same
	// plane as the texture space basis vectors	textureVecsTexelsPerWorldUnits.

	R_DecalComputeBasis( MSurf_Plane( surfID ).normal,
		(decalinfo->m_Flags & FDECAL_USESAXIS) ? &decalinfo->m_SAxis : 0,
		decalinfo->m_Basis );

	// Compute an effective width and height (axis aligned)	in the parent texture space
	// How does this work? decalBasis[0] represents the u-direction (width)
	// of the decal measured in world space, decalBasis[1] represents the
	// v-direction (height) measured in world space.
	// textureVecsTexelsPerWorldUnits[0] represents the u direction of
	// the surface's texture space measured in world space (with the appropriate
	// scale factor folded in), and textureVecsTexelsPerWorldUnits[1]
	// represents the texture space v direction. We want to find the dimensions (w,h)
	// of a square measured in texture space, axis aligned to that coordinate system.
	// All we need to do is to find the components of the decal edge vectors
	// (decalWidth * decalBasis[0], decalHeight * decalBasis[1])
	// in texture coordinates:

	float w = fabs( decalinfo->m_decalWidth  * DotProduct( textureU.AsVector3D(), decalinfo->m_Basis[0] ) ) +
		fabs( decalinfo->m_decalHeight * DotProduct( textureU.AsVector3D(), decalinfo->m_Basis[1] ) );

	float h = fabs( decalinfo->m_decalWidth  * DotProduct( textureV.AsVector3D(), decalinfo->m_Basis[0] ) ) +
		fabs( decalinfo->m_decalHeight * DotProduct( textureV.AsVector3D(), decalinfo->m_Basis[1] ) );

	// move s,t to upper left corner
	s -= ( w * 0.5 );
	t -= ( h * 0.5 );

	// Is this rect within the surface? -- tex width & height are unsigned
	if( !bForceForDisplacement )
	{
		if ( s <= -w || t <= -h ||
			 s > (MSurf_TextureExtents( surfID )[0]+w) || t > (MSurf_TextureExtents( surfID )[1]+h) )
		{
			return; // nope
		}
	}

	// stamp it
	R_DecalCreate( decalinfo, surfID, s, t, bForceForDisplacement );
}

// Allocate and initialize a decal from the pool, on surface with offsets x, y
// UNDONE: offsets are not really meaningful in new decal coordinate system
// the clipping code will recalc the offsets
static void R_DecalCreate(
	decalinfo_t* decalinfo,
	SurfaceHandle_t surfID,
	float x,
	float y,
	bool bForceForDisplacement )
{
	decal_t			*pdecal;
	int				count, vertCount;

	if( !IS_SURF_VALID( surfID ) )
	{
		ConMsg( "psurface NULL in R_DecalCreate!\n" );
		return;
	}

	decal_t *pold = R_DecalIntersect( decalinfo, surfID, &count );
	if ( count >= MAX_OVERLAP_DECALS )
	{
		R_DecalUnlink( pold, host_state.worldbrush );
		pold = NULL;
	}

	pdecal = R_DecalAlloc( decalinfo->m_Flags );

	pdecal->flags = decalinfo->m_Flags;
	pdecal->color = decalinfo->m_Color;
	VectorCopy( decalinfo->m_Position, pdecal->position );
	if (pdecal->flags & FDECAL_USESAXIS)
		VectorCopy( decalinfo->m_SAxis, pdecal->saxis );
	pdecal->dx = x;
	pdecal->dy = y;
	pdecal->material = decalinfo->m_pMaterial;
	Assert( pdecal->material );
	pdecal->userdata = decalinfo->m_pUserData;

	// Set scaling
	pdecal->scale = decalinfo->m_scale;
	pdecal->entityIndex = decalinfo->m_Entity;

	// Get dynamic information from the material (fade start, fade time)
	bool found;
	IMaterialVar* decalVar = decalinfo->m_pMaterial->FindVar( "$decalFadeDuration", &found, false );
	if ( found  )
	{
		pdecal->flags |= FDECAL_DYNAMIC;
		pdecal->fadeDuration = decalVar->GetFloatValue();
		decalVar = decalinfo->m_pMaterial->FindVar( "$decalFadeTime", &found, false );
		pdecal->fadeStartTime = found ? decalVar->GetFloatValue() : 0.0f;
		pdecal->fadeStartTime += cl.GetTime();
	}

	// Check for Dynamic Scale, and cache values
	decalVar = decalinfo->m_pMaterial->FindVar( "$decalDynamicScale", &found, false );
	if ( found )
	{
		pdecal->flags |= FDECAL_DISTANCESCALE;
	}

	// check for a player spray
	if( pdecal->flags & FDECAL_PLAYERSPRAY )
	{
		// reset the number of rounds this should be visible for
		pdecal->fadeStartTime = 0.0f;

		// Force the scale to 1 for player sprays.
		pdecal->scale = 1.0f;
	}

	// Is this a second-pass decal?
	decalVar = decalinfo->m_pMaterial->FindVar( "$decalSecondPass", &found, false );
	if ( found  )
		pdecal->flags |= FDECAL_SECONDPASS;

	if( !bForceForDisplacement )
	{
		// Check to see if the decal actually intersects the surface
		// if not, then remove the decal
		R_DecalVertsClip( NULL, pdecal, surfID,
			decalinfo->m_pMaterial, &vertCount );
		if ( !vertCount )
		{
			R_DecalUnlink( pdecal, host_state.worldbrush );
			return;
		}
	}

	// Add to the surface's list
	R_AddDecalToSurface( pdecal, surfID, decalinfo );

	// Add decal material/lightmap to sort list.
	R_DecalMaterialSort( pdecal, surfID );
}

// Add the decal to the surface's list of decals.
// If the surface is a displacement, let the displacement precalculate data for the decal.
static void R_AddDecalToSurface(
	decal_t *pdecal,
	SurfaceHandle_t surfID,
	decalinfo_t *decalinfo )
{
	pdecal->pnext = NULL;
	decal_t *pold = MSurf_DecalPointer( surfID );
	if ( pold )
	{
		while ( pold->pnext )
			pold = pold->pnext;
		pold->pnext = pdecal;
	}
	else
	{
		MSurf_Decals( surfID ) = DecalToHandle(pdecal);
	}

	// Tag surface
	pdecal->surfID = surfID;
	pdecal->m_Size = decalinfo->m_Size;

	// Let the dispinfo reclip the decal if need be.
	if( SurfaceHasDispInfo( surfID ) )
	{
		pdecal->m_DispDecal = MSurf_DispInfo( surfID )->NotifyAddDecal( pdecal, decalinfo->m_Size );
	}

	// Add surface to list.
	decalinfo->m_aApplySurfs.AddToTail( surfID );
}
]]

do
	local tr_res = {}
	local tr = {
		collisiongroup = COLLISION_GROUP_NONE,
		mask = MASK_SOLID_BRUSHONLY,
		output = tr_res,
	}

	hook.Add("OnEntityCreated", "spraycan-bootstrap", function(e)
		if not IsValid(e) or e:GetClass() ~= "spraycan" then return end

		local norm = e:GetAngles():Forward()
		local ply  = e:GetOwner()

		tr.filter = ply
		tr.start  = e:GetPos()
		tr.endpos = tr.start + norm * 128
		util.TraceLine(tr)

		if hook.Run("OnSprayCanCreated", ply, tr_res) then
			e:Remove()
		end
	end)
end
