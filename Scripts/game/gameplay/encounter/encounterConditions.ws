/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class ISpawnCondition extends IScriptable
{
}


import abstract class ISpawnScriptCondition extends ISpawnCondition
{
	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		return true;
	}
}



class W3FactCondition extends ISpawnScriptCondition
{
	editable var fact 		: string;
	editable var factValue 	: int;
	editable var operator 	: EOperator;
	
	var queryFactVal : int; 

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		queryFactVal = FactsQuerySum( fact );
		
		switch ( operator )
		{
			case EO_Equal:			return queryFactVal == factValue;
			case EO_NotEqual:		return queryFactVal != factValue;
			case EO_Less:			return queryFactVal < factValue;
			case EO_LessEqual:		return queryFactVal <= factValue;
			case EO_Greater:		return queryFactVal > factValue;
			case EO_GreaterEqual:	return queryFactVal >= factValue;
			default : 				return false;
		}
	}
}

class W3KilledCounterCondition extends ISpawnScriptCondition
{
	
	editable var killedValue 	: int;
	editable var operator 	: EOperator;
	
	var killedCreatures : int;
	var dataManager		: CEncounterDataManager;

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		dataManager = encounter.GetEncounterDataManager();
		if ( !dataManager )
		{			
			encounter.InitializeEncounterDataManager();	
			dataManager = encounter.GetEncounterDataManager();
		}
		
		killedCreatures = dataManager.GetKilledCreatures();
		
		switch ( operator )
		{
			case EO_Equal:			return killedCreatures == killedValue;
			case EO_NotEqual:		return killedCreatures != killedValue;
			case EO_Less:			return killedCreatures < killedValue;
			case EO_LessEqual:		return killedCreatures <= killedValue;
			case EO_Greater:		return killedCreatures > killedValue;
			case EO_GreaterEqual:	return killedCreatures >= killedValue;
			default : 				return false;
		}
	}
}

class W3KilledCounterByEntryCondition extends ISpawnScriptCondition
{
	
	editable var killedValue 	: int;
	editable var entryNme		: name;
	editable var operator 		: EOperator;
	
	var killedCreatures : int;
	var dataManager		: CEncounterDataManager;

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		dataManager = encounter.GetEncounterDataManager();
		if ( !dataManager )
		{
			encounter.InitializeEncounterDataManager();
			dataManager = encounter.GetEncounterDataManager();		
		}
		
		killedCreatures = dataManager.GetKilledCreaturesByEntry( entryNme );
		
		switch ( operator )
		{
			case EO_Equal:			return killedCreatures == killedValue;
			case EO_NotEqual:		return killedCreatures != killedValue;
			case EO_Less:			return killedCreatures < killedValue;
			case EO_LessEqual:		return killedCreatures <= killedValue;
			case EO_Greater:		return killedCreatures > killedValue;
			case EO_GreaterEqual:	return killedCreatures >= killedValue;
			default : 				return false;
		}
	}
}

class W3SpawnedCounterCondition extends ISpawnScriptCondition
{
	
	editable var spawnedValue 	: int;
	editable var operator 	: EOperator;
	
	var spawnedCreatures : int;
	var dataManager		: CEncounterDataManager;

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		dataManager = encounter.GetEncounterDataManager();
		if ( !dataManager )
		{
			encounter.InitializeEncounterDataManager();
			dataManager = encounter.GetEncounterDataManager();
		}
		
		spawnedCreatures = dataManager.GetCurrentlySpawnedCreatures();
		
		switch ( operator )
		{
			case EO_Equal:			return spawnedCreatures == spawnedValue;
			case EO_NotEqual:		return spawnedCreatures != spawnedValue;
			case EO_Less:			return spawnedCreatures < spawnedValue;
			case EO_LessEqual:		return spawnedCreatures <= spawnedValue;
			case EO_Greater:		return spawnedCreatures > spawnedValue;
			case EO_GreaterEqual:	return spawnedCreatures >= spawnedValue;
			default : 				return false;
		}
	}
}

class W3SpawnedCounterByEntryCondition extends ISpawnScriptCondition
{
	
	editable var spawnedValue 	: int;
	editable var entryName 		: name;
	editable var operator 	: EOperator;
	
	var spawnedCreatures : int;
	var dataManager		: CEncounterDataManager;

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		dataManager = encounter.GetEncounterDataManager( );
		if ( !dataManager )
		{
			encounter.InitializeEncounterDataManager();
			dataManager = encounter.GetEncounterDataManager();		
		}
		
		spawnedCreatures = dataManager.GetCurrentlySpawnedCreaturesByEntry( entryName );
		
		switch ( operator )
		{
			case EO_Equal:			return spawnedCreatures == spawnedValue;
			case EO_NotEqual:		return spawnedCreatures != spawnedValue;
			case EO_Less:			return spawnedCreatures < spawnedValue;
			case EO_LessEqual:		return spawnedCreatures <= spawnedValue;
			case EO_Greater:		return spawnedCreatures > spawnedValue;
			case EO_GreaterEqual:	return spawnedCreatures >= spawnedValue;
			default : 				return false;
		}
	}
}

class W3ConditionSpawnDuringCombat extends ISpawnScriptCondition
{
	editable var spawnDuringCombat : bool;
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		return (!thePlayer.IsInCombat() || thePlayer.IsInCombat() == spawnDuringCombat);
	}
}


class W3CreaturesGroupEnabledCondition extends ISpawnScriptCondition
{
	
	editable var groupName		: name;
	
	var disabledBySources 		: int;
	var dataManager		  		: CEncounterDataManager;

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		dataManager = encounter.GetEncounterDataManager();
		if ( !dataManager )
		{
			encounter.InitializeEncounterDataManager();
			dataManager = encounter.GetEncounterDataManager();
		}
		
		disabledBySources = dataManager.GetDisabledCreaturesGroupSourcesAmount ( groupName );
		
		if ( disabledBySources > 0 || dataManager.IsCreatureGroupDisableByAnySource( groupName )  )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
}

class W3HasItemCondition extends ISpawnScriptCondition
{
	editable var item			:SItemNameProperty;
	editable var actorTag		: name;
	

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		var actor : CActor;
		
		if ( actorTag == 'PLAYER' )
		{
			actor = (CActor)thePlayer;
		}
		else
		{
			actor = theGame.GetActorByTag ( actorTag );
		}
		
		if ( actor )
		{
			return actor.GetInventory().HasItem ( item.itemName );
		}
		return false;
	}
}

class W3HasItemByCategoryCondition extends ISpawnScriptCondition
{
	editable var itemCategory	: name;
	editable var actorTag		: name;
	

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		var actor : CActor;
		var items : array < SItemUniqueId>;
		
		if ( actorTag == 'PLAYER' )
		{
			actor = (CActor)thePlayer;
		}
		else
		{
			actor = theGame.GetActorByTag ( actorTag );
		}
		
		if ( actor )
		{
			items = actor.GetInventory().GetItemsByCategory ( itemCategory );
			
			return items.Size() > 0;
		}
		return false;
	}
}

class W3PlayerLevelCondition extends ISpawnScriptCondition
{
	editable var level 	: int;
	editable var operator 	: EOperator;
	
	var queryVal : int; 

	
	
	function TestCondition( encounter : CEncounter ) : bool
	{
		queryVal = thePlayer.GetLevel();
		
		switch ( operator )
		{
			case EO_Equal:			return queryVal == level;
			case EO_NotEqual:		return queryVal != level;
			case EO_Less:			return queryVal < level;
			case EO_LessEqual:		return queryVal <= level;
			case EO_Greater:		return queryVal > level;
			case EO_GreaterEqual:	return queryVal >= level;
			default : 				return false;
		}
	}
}