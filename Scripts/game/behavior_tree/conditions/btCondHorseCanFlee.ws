/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondHorseCanFlee extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if( GetNPC().GetCanFlee() )
		{
			return true;
		}
		return false;
	}
};

class CBTCondHorseCanFleeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseCanFlee';
};
