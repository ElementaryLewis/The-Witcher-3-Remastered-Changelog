/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskPlayHitOnShield extends IBehTreeTask
{
	private var resourceName : name;
	private var shieldFxName : name;
	
	private var npc : CNewNPC;
	private var entityTemplate : CEntityTemplate;
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		entityTemplate = (CEntityTemplate)LoadResource( resourceName );
		
		return BTNS_Active;
	}

	function OnGameplayEvent( eventName : name ) : bool
	{
		if( eventName == 'BeingHit' )
		{
			if( IsNameValid( shieldFxName ) && npc.IsEffectActive( shieldFxName, false ) )
			{
				SpawnHitFXEntity();
			}
			else if( !IsNameValid( shieldFxName ) )
			{
				SpawnHitFXEntity();
			}
			else
			{
				npc.RaiseEvent( 'AdditiveHitReaction' );
			}
		}
		
		return true;
	}
	
	private function SpawnHitFXEntity()
	{
		var entity : CEntity;
		var npcPos, playerPos, spawnPos : Vector;
		var spawnRot : EulerAngles;
		var spawnYaw, spawnPitch, heightDiff, distDiff : float;
		
		npcPos = npc.GetWorldPosition();
		playerPos = thePlayer.GetWorldPosition();
		
		spawnPos = npcPos;
		
		spawnYaw = VecHeading( playerPos - npcPos ); 
		spawnRot.Yaw = spawnYaw;
		
		heightDiff = npcPos.Z - playerPos.Z;
		distDiff = VecDistance2D( npcPos, playerPos );
		
		spawnPitch = -( 90 - Rad2Deg( AtanF( distDiff, heightDiff ) ) );
		spawnRot.Pitch = spawnPitch;
	
		entity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
		
		if( entity )
		{
			entity.DestroyAfter( 3.0 );
		}
	}
}




class BTTaskPlayHitOnShieldDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskPlayHitOnShield';
	
	editable var resourceName : name;
	editable var shieldFxName : name;
	
	default resourceName = 'fairytale_witch_shield_hit';
	default shieldFxName = 'shield';
}