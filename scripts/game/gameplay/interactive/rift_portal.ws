/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3OnSpawnPortal extends CEntity
{
	editable var fxName 			 : name; default fxName = 'teleport';
	editable var fxTimeout  		 : float; default fxTimeout = 3.f;
	editable var creatureAppearAfter : float; default creatureAppearAfter = 0.8f;
	private var spawnedActor		 : CActor;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		PlayEffect ( fxName, this );
		AddTimer( 'StopFxTimer', fxTimeout, false, , , true );
	}
	
	public function HideCreature ( _actor : CActor )
	{
		spawnedActor = _actor;
		SetVisibility (spawnedActor, false );
		AddTimer( 'ShowCreatureTimer', creatureAppearAfter, false, , , true );
	}
	public function SetFxTimeout ( _timeout : float )
	{
		fxTimeout = _timeout;
	}
	
	public function SetFxName ( _fxName : name )
	{
		fxName = _fxName;
	}
	
	timer function StopFxTimer ( _timeDelta : float , id : int)
	{
		StopEffect ( fxName );
		AddTimer( 'DestroyPortalTimer', 3.5f + creatureAppearAfter, false, , , true );
	}
	
	timer function DestroyPortalTimer ( _timeDelta : float , id : int)
	{
		Destroy();
	}
	
	timer function ShowCreatureTimer ( _timeDelta : float , id : int)
	{
		SetVisibility ( spawnedActor, true );
	}
	
	
	private function SetVisibility (_actor : CActor, _isVisible : bool )
	{
		_actor.SetVisibility( _isVisible );
	}
	
}