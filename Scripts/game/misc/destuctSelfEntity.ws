/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DestructSelfEntity extends CGameplayEntity
{
	private editable var destructAfterDelay	: float;
	private editable var stopEffectDuration	: float;
	private editable var effectToStop 		: name;
	
	hint stopEffectDuration = "time that the effect takes to completely stops. The stop effect function will be called that long before destroying the entity";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		SetTimer( destructAfterDelay );
	}
	
	
	public final function SetTimer( _DestructAfterDelay : float )
	{
		var delayToStopEffect : float; 
		
		RemoveTimer( 'Destroy' );
		RemoveTimer( 'StopEffectAfter' );
		
		if( _DestructAfterDelay < 0 ) return;
		
		if ( IsNameValid( effectToStop  ) )
		{
			delayToStopEffect = ClampF( destructAfterDelay - stopEffectDuration, 0, destructAfterDelay );
			AddTimer('StopEffectAfter', delayToStopEffect ,false, , , true);
		}
		
		DestroyAfter( destructAfterDelay );
		
	}
	
	
	private final timer function StopEffectAfter( delta : float , id : int)
	{
		StopEffect( effectToStop );
	}
	
}