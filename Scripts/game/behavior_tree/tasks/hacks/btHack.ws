/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTHackDef extends IBehTreeTaskDefinition
{
};

class CBTCondIsMan extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		if ( GetActor().IsMan() )
			return true;
		
		return false;
	}
}

class CBTCondIsManDef extends CBTHackDef
{
	default instanceClass = 'CBTCondIsMan';
};