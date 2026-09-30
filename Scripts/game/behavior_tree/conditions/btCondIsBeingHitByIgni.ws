/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsBeingHitByIgni extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return GetNPC().IsBeingHitByIgni();
	}
};


class CBTCondIsBeingHitByIgniDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsBeingHitByIgni';
};