/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CRandomFXEntity extends CEntity
{
	editable 	var fxName 			: array<name>;
	editable 	var intervalMin		: float;
	editable 	var intervalMax		: float;
	editable 	var fxTwiceInARow 	: bool;
	editable 	var soundEvent		: string;
	editable 	var soundDelay		: float;
	protected 	var fxIndex, size	: int;
	protected	var interval		: float;
	
	
	default fxTwiceInARow = true;
	default intervalMin = 1;
	default intervalMax = 10;
	default soundEvent = "thunder_close";
	default soundDelay = 0.6;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		size = fxName.Size();
		super.OnSpawned( spawnData );
		interval = RandRangeF( intervalMax, intervalMin );
		AddTimer( 'PlayEffectInterval', interval, false );
	}
	
	function EndFX()
	{
		RemoveTimer('PlayEffectInterval');
	}
	
	function DestroyFX()
	{
		EndFX();
		AddTimer( 'TimerDestroy', 3.0, false, , , true );
	}
	
	timer function TimerDestroy( td : float , id : int)
	{
		Destroy();
	}
	
	timer function TimerSoundEvent( td : float , id : int)
	{
		theSound.SoundEvent(soundEvent);
	}
	
	timer function PlayEffectInterval( t : float , id : int)
	{
		var i : int;
		
		if( size )
		{
			if ( !fxTwiceInARow )
			{
				fxIndex = RandDifferent( fxIndex, size );
				PlayEffect( fxName[ fxIndex ] );
			}
			else
			{
				PlayEffect( fxName[ RandRange( size ) ] );
			}
		}
		
		AddTimer('TimerSoundEvent', soundDelay, , , , true);
		
		interval = RandRangeF( intervalMax, intervalMin );
		RemoveTimer('PlayEffectInterval');
		AddTimer('PlayEffectInterval', interval, false);
	}
};