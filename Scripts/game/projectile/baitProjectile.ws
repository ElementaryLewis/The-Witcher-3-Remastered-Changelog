/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3BaitProjectile extends W3BoltProjectile
{
	
	
	
	
	private editable var foodSourceToGenerate		: CEntityTemplate;
	private editable var addScentToCollidedActors	: bool;	
	private editable var attractionDuration			: float;
	
	default	attractionDuration 			= 30;
	
	hint attractionDuration = "-1 means infinite";
	
	
	private var m_BaitEntity	: CEntity;

	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var l_rotation 	: EulerAngles;
		var l_entityHit	: CEntity;
		var victim : CActor;

		victim = (CActor)collidingComponent.GetEntity();
		
		if ( !CanCollideWithVictim( victim ) )
			return true;
		
		if( !m_BaitEntity )
		{
			m_BaitEntity = theGame.CreateEntity( foodSourceToGenerate, pos, l_rotation );
			l_entityHit = collidingComponent.GetEntity();
			m_BaitEntity.CreateAttachment( l_entityHit );
			
			if( attractionDuration > 0 )
			{
				m_BaitEntity.StopAllEffectsAfter( MaxF( attractionDuration - 5, 0 ) );
				m_BaitEntity.DestroyAfter( attractionDuration );
			}
			else
			{
				m_BaitEntity.StopAllEffectsAfter( 55 );
				m_BaitEntity.DestroyAfter( 60 );
			}
		}		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
}