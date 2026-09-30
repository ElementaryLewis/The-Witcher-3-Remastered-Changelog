/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ETestSubject
{
	ETS_Player,
	ETS_Owner
}
 
 
class CBTCondIsInInterior extends IBehTreeTask
{
	var testSubject : ETestSubject;

	function IsAvailable() : bool
	{
		var owner : CNewNPC;

		if ( testSubject == ETS_Player )
		{
			return thePlayer.IsInInterior();
		}
		else
		{
			owner = GetNPC();
			if ( owner )
			{
				return owner.IsInInterior();
			}
		}
		
		return false;
	}
};

class CBTCondIsInInteriorDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsInInterior';

	editable var testSubject : ETestSubject;
	default testSubject = ETS_Owner;
};
