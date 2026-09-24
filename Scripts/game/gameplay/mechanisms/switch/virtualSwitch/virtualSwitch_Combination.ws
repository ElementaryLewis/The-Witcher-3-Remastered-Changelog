/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3VirtualSwitch_Combination extends W3VirtualSwitch
{	
	public function Notify( activeSwitch : W3Switch )
	{
		var i, size : int;
		var switchEntity : W3Switch;
		
		if( !IsAvailable() )
		{
			return;
		}
		
		size = requiredSwitches.Size();
		
		LogChannel( 'Switch', "W3VirtualSwitch_Combination: processing requirements (" + size + ")");
		
		for( i = 0; i < size; i += 1 )
		{
			switchEntity = GetSwitchByTag( requiredSwitches[ i ].requiredSwitchTag );
			if ( switchEntity )
			{
				LogChannel( 'Switch', i + ": " + switchEntity + " " + switchEntity.IsOn() + " " + requiredSwitches[ i ].switchState );
				if ( ( switchEntity.IsOn() && requiredSwitches[ i ].switchState == ERSS_OFF ) ||
					 ( !switchEntity.IsOn() && requiredSwitches[ i ].switchState == ERSS_ON ) )
				{
					Fail( switchEntity );
					return;
				}
			}
		}
		
		if ( IsUseCountReached() )
		{
			return;
		}
		
		Toggle( NULL, false, false );
	}	
}