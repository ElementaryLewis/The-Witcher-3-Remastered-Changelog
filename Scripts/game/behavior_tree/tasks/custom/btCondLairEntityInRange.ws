/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondLairEntityInRange extends IBehTreeTask
{
	private var lair 						: CFlyingSwarmMasterLair;
	private var checkCount					: int;
	private var timeStamp 					: float;
	
	function IsAvailable() : bool
	{
		var lairEntities : array<CGameplayEntity>;
		
		if ( !lair && checkCount <= 5 && ( timeStamp + 5 < GetLocalTime() || timeStamp == 0 ) )
		{
			timeStamp = GetLocalTime();
			checkCount += 1;
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		if ( !lair )
		{
			return false;
		}
		return true;
	}
}

class CBTCondLairEntityInRangeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondLairEntityInRange';
};