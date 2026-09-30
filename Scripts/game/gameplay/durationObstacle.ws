/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DurationObstacle extends CGameplayEntity
{
	
	
	
	protected editable var	lifeTimeDuration				: SRangeF;
	protected editable var	disappearanceEffectDuration		: float; default disappearanceEffectDuration 	= 3;
	protected editable var	disappearEffectName				: name;
	protected editable var	simplyStopEffect				: bool;
	
	hint simplyStopEffect = "Instead of playing a new effect when disappear, will just stop the named effect";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( lifeTimeDuration.min > 0 || lifeTimeDuration.max > 0 )
		{
			AddTimer('Disappear', RandRangeF( lifeTimeDuration.max, lifeTimeDuration.min) , false, , , true);
		}
	}
	
	
	public timer function Disappear( optional delta:float, optional id : int)
	{
		if( simplyStopEffect )
		{
			StopEffect( disappearEffectName );
		}
		else
		{
			PlayEffect( disappearEffectName );
		}
		AddTimer('DestroyTimer', disappearanceEffectDuration, false, , , true);
		
		SpecificDisappear();
	}
	
	
	
	private function SpecificDisappear()
	{	
	}
}