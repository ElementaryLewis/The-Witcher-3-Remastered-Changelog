/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CWaterfallRumble extends CEntity
{
	editable var vibrateStrong : bool;
	private var duration : float;
	default duration = 0.2f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		AddTimer('Rumble', duration, true);
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		RemoveTimer('Rumble');
	}
	
	private timer function Rumble(dt : float, id : int)
	{
		
		
		
		if(vibrateStrong)
		{
			VibrateStrong();
		}
		else
		{
			VibrateLight();
		}
	}
	
	private function VibrateLight()
	{
		if(theGame.IsSpecificRumbleActive(0.05, 0))
		{
			theGame.OverrideRumbleDuration(0.05, 0, duration);
		}
		else
		{
			theGame.VibrateController(0.05, 0, duration);
		}
	}
	
	private function VibrateStrong()
	{
		if(theGame.IsSpecificRumbleActive(0.25, 0))
		{
			theGame.OverrideRumbleDuration(0.25, 0, duration);
		}
		else
		{
			theGame.VibrateController(0.25, 0, duration);
		}
	}
};