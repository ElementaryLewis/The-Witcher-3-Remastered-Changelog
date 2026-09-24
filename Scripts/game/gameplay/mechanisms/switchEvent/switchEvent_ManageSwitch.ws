/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageSwitch extends W3SwitchEvent
{
	editable var switchTag	: name;
	editable var operations	: array< ESwitchOperation >;
	editable var force		: bool;							default force		= true;
	editable var skipEvents	: bool;							default skipEvents	= true;
	
	hint switchTag	= "Tag of the switch";
	hint operation	= "Operations to perform on switch";
	hint force		= "Force even if switch is disabled (applicable only for turning on/off)";
	hint skipEvents	= "Skip events associated with with switch (applicable only for turning on/off)";
	
	public function Perform( parnt : CEntity )
	{
		var switchEntity : W3Switch;
		
		switchEntity = GetSwitchByTag( switchTag );
		if ( !switchEntity )
		{
			LogChannel( 'Switch', "W3SE_ManageSwitch::Activate - cannot find switch with tag <" + switchTag + ">");
			return;
		}
		
		switchEntity.OnManageSwitch( operations, force, skipEvents );
	}
}