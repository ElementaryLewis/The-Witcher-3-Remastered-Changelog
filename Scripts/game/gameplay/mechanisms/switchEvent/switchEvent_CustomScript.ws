/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3SE_CustomScript extends W3SwitchEvent
{
	public editable var scriptID : string;
	
	hint scriptID = "Script ID to call (string)";
	
	private function Perform( parnt : CEntity )
	{
		LogChannel('Switch', "W3SE_CustomScript.Activate: custom switch script <<"+scriptID+">> is about to be called");
		
		
	}
}