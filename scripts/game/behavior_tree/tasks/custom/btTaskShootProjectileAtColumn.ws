/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskShootProjectileAtColumn extends IBehTreeTask
{
	var l_npc			: CNewNPC;
	var l_projRot		: EulerAngles;
	var l_projPos		: Vector;
	var l_projectile	: W3AdvancedProjectile;
	var projEntity		: CEntityTemplate;
	var l_columnArray	: array<CEntity>;
	
	function OnActivate() : EBTNodeStatus
	{
		l_npc = GetNPC();
		l_columnArray.Clear();
		theGame.GetEntitiesByTag('arena_support', l_columnArray );
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var i : int;
		
		if ( animEventName == 'Shoot' )
		{
			if( l_columnArray.Size() > 0 )
			{			
				for ( i = 0; i < l_columnArray.Size(); i += 1 )
				{
					l_projPos 		= l_npc.GetWorldPosition();
					l_projRot 		= l_npc.GetWorldRotation();
					l_projectile 	= (W3AdvancedProjectile)theGame.CreateEntity( projEntity, l_projPos, l_projRot );
					l_projectile.Init( l_npc );
					l_projectile.ShootProjectileAtNode( l_projectile.projAngle, l_projectile.projSpeed, l_columnArray[i], 20.f );
				}
				
				return true;
			}
			else return false;
		}
		else return false;
	}
}
class CBTTaskShootProjectileAtColumnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskShootProjectileAtColumn';
	var l_npc					: CNewNPC;
	var l_projRot				: EulerAngles;
	var l_projPos				: Vector;
	var l_projectile			: W3AdvancedProjectile;
	var l_columnArray			: array<CEntity>;
	editable var projEntity		: CEntityTemplate;
}