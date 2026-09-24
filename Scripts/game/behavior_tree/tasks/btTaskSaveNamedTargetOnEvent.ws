/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTSaveNamedTargetOnEvent extends IBehTreeTask
{
	
	
	public var namedTargetToSave 			: name;
	public var saveUnder 					: name;
	public var gameplayEventToSaveOn		: name;
	
	
	final function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == gameplayEventToSaveOn )
		{
			SaveTarget();
		}
		
		return true;		
	}
	
	
	private final function SaveTarget()
	{
		if( IsNameValid( saveUnder ) )
		{
			SetNamedTarget( saveUnder, GetNamedTarget( namedTargetToSave ) );
		}
	}
}


class BTSaveNamedTargetOnEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTSaveNamedTargetOnEvent';
	
	
	private editable var namedTargetToSave 			: name;
	private editable var saveUnder		 			: CBehTreeValCName;
	private editable var gameplayEventToSaveOn 		: CBehTreeValCName;
	
	
	final function OnSpawn( taskGen : IBehTreeTask )
	{
		var task 		: BTSaveNamedTargetOnEvent;
		task = (BTSaveNamedTargetOnEvent) taskGen;
		
		if( IsNameValid( task.gameplayEventToSaveOn ) )
		{
			ListenToGameplayEvent( task.gameplayEventToSaveOn );
		}		
	}
}