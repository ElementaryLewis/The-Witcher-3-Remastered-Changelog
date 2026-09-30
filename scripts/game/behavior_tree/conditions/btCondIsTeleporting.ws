/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTeleporting extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		
		if ( !npc )
		{
			npc = GetNPC();
		}
		
		return npc.IsTeleporting();
	}
}

class CBTCondIsTeleportingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondIsTeleporting';
};