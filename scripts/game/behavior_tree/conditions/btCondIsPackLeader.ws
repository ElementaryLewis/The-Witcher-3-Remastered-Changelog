/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsPackLeader extends IBehTreeTask
{
	
	
	
	
	
	
	function IsAvailable() : bool
	{
		if ( GetNPC().isPackLeader )
			return true;
		else 
			return false;
	}

}



class BTCondIsPackLeaderDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsPackLeader';	
}