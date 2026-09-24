/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSoundSwitch extends IBehTreeTask
{
	
	
	
	public var swichGroupName 	: name;
	public var stateName 		: string;
	public var onActivate 		: bool;
	public var onDeactivate		: bool;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( !onActivate ) return BTNS_Active;
		SwitchSound();
		return BTNS_Active;
	}	
	
	
	private function OnDeactivate()
	{
		if( !onDeactivate ) return;
		SwitchSound();
	}
	
	
	private function SwitchSound()
	{
		GetNPC().SoundSwitch( swichGroupName, stateName );
	}
}


class BTTaskSoundSwitchDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSoundSwitch';

	
	
	private editable var swichGroupName : name;
	private editable var stateName 		: string;
	private editable var onActivate		: bool;
	private editable var onDeactivate	: bool;
}