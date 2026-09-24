/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ERequiredSwitchState
{
	ERSS_ON,
	ERSS_OFF
}


struct SRequiredSwitch
{
	editable var requiredSwitchTag : name;
	editable var switchState : ERequiredSwitchState;
	
	hint requiredSwitch = "Tag of the required switch";
	hint switchState = "Desired state of the switch";
}

abstract class W3VirtualSwitch extends W3Switch
{
	protected editable var requiredSwitches : array<SRequiredSwitch>;
	
	default isInitiallyOn = false;
	
	hint requiredSwitches = "Array of required switches to activate this switch";
		
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		super.OnSpawned(spawnData);

		if (!spawnData.restored)
		{
			AddTimer( 'OnGetRequiredSwitches', 0.1, , , , true );
		}
	}

	timer function OnGetRequiredSwitches( timeDelta : float , id : int)
	{
		var i : int;
		var switchEntity : W3Switch;
	
		for(i=requiredSwitches.Size(); i>=0; i-=1)
		{
			switchEntity = GetSwitchByTag( requiredSwitches[i].requiredSwitchTag );
			if( switchEntity )
			{
				switchEntity.AddLinkToVirtualSwitch( this );
			}
			else
			{
				requiredSwitches.Erase(i);
			}
		}
	}
	
	
	public function Notify( activeSwitch : W3Switch );
	
	
	protected function Fail( failed : W3Switch )
	{
		LogChannel( 'Switch', "W3VirtualSwitch <<"+this+">> failed !" );
	}
	
	
	
	public function Turn( on : bool, actor : CActor, force : bool, skip : bool )
	{
		if ( IsAvailable() || force )
		{
			if ( on && ( IsOff() || IsUndefined() ) )
			{
				ProcessPostTurnActions( force, skip );
				OnAnimSwitchedOn();
			}
			else if ( !on && ( IsOn() || IsUndefined() ) )
			{
				ProcessPostTurnActions( force, skip );
				OnAnimSwitchedOff();
			}
		}
	}

}
