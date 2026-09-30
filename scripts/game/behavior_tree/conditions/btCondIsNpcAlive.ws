/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsNpcAlive extends IBehTreeTask
{
	private var npcTag : name;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		
		npc = (CNewNPC)theGame.GetNodeByTag( npcTag );
		
		if( npc )
		{
			if( npc.IsAlive() )
			{
				return true;
			}
		}
			
		return false;
	}
};

class CBTCondIsNpcAliveDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsNpcAlive';
	
	editable var npcTag : name;
};