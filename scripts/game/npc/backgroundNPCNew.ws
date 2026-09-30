/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3NPCBackgroundNew extends CEntity
{
	editable var behaviorWorkNumber : int;	
	editable var randomized : bool;
	editable var maxWorkNumber : int;
	editable var excludeIdle : bool;

	event OnSpawned(spawnData : SEntitySpawnData)
	{
		if(randomized)
		{
			if(excludeIdle)
			{
				SetBehaviorVariable( 'WorkTypeEnum_Single', RandRange(maxWorkNumber) +1 );
			}
			else
			{
				SetBehaviorVariable( 'WorkTypeEnum_Single', RandRange(maxWorkNumber +1) );
			}
		}
		else
		{
			SetBehaviorVariable( 'WorkTypeEnum_Single', behaviorWorkNumber);
		}
		
	}
	
}