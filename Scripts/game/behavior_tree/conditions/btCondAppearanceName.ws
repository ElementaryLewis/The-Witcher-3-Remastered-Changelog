/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondAppearanceName extends IBehTreeTask
{
	var appearanceName : name;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		var currentAppearance : name;
		
		currentAppearance = owner.GetAppearance();
		
		
		if( currentAppearance == appearanceName )
		{
			return true;
		}
		else
		{
			return false;		
		}
	}
};


class CBTCondAppearanceNameDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondAppearanceName';

	editable var appearanceName : name;
};