/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskToadBackProjectiles extends CBTTaskProjectileAttackWithPrepare
{
	var minDistFromTarget 	: float;
	var maxDistFromTarget 	: float;
	var range				: float;
	var animEvent			: array<name>;
	var boneNames			: array<name>;
	var projectilesShot		: bool;
	var npc					: CNewNPC;

	
	function Initialize()
	{
		npc = GetNPC();
		projectilesShot = false;
	}	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		var i 	: int;
		
		if ( animEventName == 'Prepare' )
		{
			CreateProjectile( 4 );
			npc.StopEffect( 'back_light' );
			
			
			for( i=0; i<m_Projectiles.Size(); i+=1 )
			{	
				m_Projectiles[i].CreateAttachment( GetActor(), boneNames[i] );
				thePlayer.GetVisualDebug().AddSphere( 'c1', 0.5, m_Projectiles[i].GetWorldPosition(), true, Color( 255, 1, 0 ), 3.0 );
			}
			return true;
		}
		else if ( animEvent.Contains(animEventName) )
		{
			i = m_Projectiles.Size()-1;
			
			if ( i < 0 )
				return false;
			
			m_Projectiles[i].BreakAttachment();
			m_Projectiles[i].ShootProjectileAtPosition( m_Projectiles[i].projAngle, m_Projectiles[i].projSpeed, FindPosition(), range );
			thePlayer.GetVisualDebug().AddArrow( 'correctionLine', m_Projectiles[i].GetWorldPosition(), FindPosition(), 1, 0.3, 0.3, true, Color( 255, 255, 255 ), true, 5.0 );
			m_Projectiles.Erase(i);
			return true;
		}
		
		
		
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		return res;
	}
	
	function FindPosition() : Vector
	{
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos : Vector;
		var outPos : Vector;
		
		targetPos = GetCombatTarget().GetWorldPosition();
		randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
		
		outPos = targetPos + randVec;
		thePlayer.GetVisualDebug().AddSphere( 'c1', 2, outPos, true, Color( 0, 255, 0 ), 3.0 );
		
		return outPos;
	}
	
	function OnDeactivate()
	{
		var i : int;
		
		for(i=0; i<m_Projectiles.Size(); i+=1)
		{
			m_Projectiles[i].Destroy();
		}
		if( !npc.IsEffectActive( 'back_light' , false ) )
		{
			npc.PlayEffect( 'back_light' );
		}
		
	}
	
}

class CBTTaskToadBackProjectilesDef extends CBTTaskProjectileAttackWithPrepareDef
{
	default instanceClass = 'CBTTaskToadBackProjectiles';
	
	editable 	var minDistFromTarget 	: float;
	editable 	var maxDistFromTarget 	: float;
	editable 	var range 				: float;
	editable 	var animEvent			: array<name>;
	editable 	var boneNames			: array<name>;
	
}