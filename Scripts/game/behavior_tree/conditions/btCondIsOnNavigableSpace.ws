/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsOnNavigableSpaceDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsOnNavigableSpace';
};

class CBTCondIsOnNavigableSpace extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var mac : CMovingAgentComponent;
		
		mac = GetNPC().GetMovingAgentComponent();
		
		if( mac.IsOnNavigableSpace() )
		{
			return true;
		}
		return false;
	}
}