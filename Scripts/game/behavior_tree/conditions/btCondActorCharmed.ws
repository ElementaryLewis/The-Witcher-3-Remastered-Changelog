/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondActorCharmed extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if( owner.HasBuff( EET_AxiiGuardMe ) || owner.HasBuff( EET_Confusion ) )
		{
			return true;
		}
		return false;
	}
};


class CBTCondActorCharmedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondActorCharmed';
};