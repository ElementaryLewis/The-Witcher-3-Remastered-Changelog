/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3StallEntity extends CGameplayEntity
{

	function ChangeStallApearance()
	{
		var curGameHour: int;
		var curGameMin: int;
		var curGameTime : GameTime;
		
		curGameTime = GameTimeCreate();
		curGameHour = GameTimeHours( curGameTime );	
        curGameMin = GameTimeMinutes( curGameTime );		
        
		if ( curGameHour >= 22 || curGameHour < 6 )
			{
				ApplyAppearance("close");
			}   else
			{
				ApplyAppearance("open");
			}
	}

	timer function ChangeStallApearanceTimer( dt : float , id : int)
	{	
		ChangeStallApearance();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		ChangeStallApearance();
		AddTimer( 'ChangeStallApearanceTimer', RandRange(120, 160 ), true );
	}
}