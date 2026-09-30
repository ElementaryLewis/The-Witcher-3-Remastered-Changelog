/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIrisPortalIsReady extends IBehTreeTask
{		
	
	
	
	private editable var returnTrueIfOpen : bool;
	
	
	function IsAvailable() : bool
	{
		var l_npc 		: W3NightWraithIris;
		l_npc = (W3NightWraithIris) GetNPC();
		
		if( !l_npc.GetPortal() )
			return false;
		
		if( returnTrueIfOpen )
			return l_npc.GetPortal().IsOpen();
		
		return l_npc.GetPortal().IsReady();
	}
	
}


class BTCondIrisPortalIsReadyDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIrisPortalIsReady';
	
	private editable var returnTrueIfOpen : bool;
}