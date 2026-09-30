/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondActorInDanger extends IBehTreeTask
{
	editable var ignoreEntityWithTag : name;
	public var dangerRadius : float;
	public var callFromQuest : bool;
	public var checkQuestRequests : bool;

	default callFromQuest = false;
	default checkQuestRequests = false;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		var actors : array< CActor >;
		var i : int;
		
		actors = GetActorsInRange(owner, dangerRadius, 1000000, '', true);
		
		for( i = 0; i < actors.Size(); i+=1 )
		{
			if( owner.HasTag( ignoreEntityWithTag ) && actors[i].HasTag( ignoreEntityWithTag ) == false )
			{
				return true;
			}
			
			if( actors[i].IsInCombat() || GetAttitudeBetween( owner, actors[i] ) == AIA_Hostile )
			{
				if( IsNameValid(ignoreEntityWithTag) && actors[i].HasTag( ignoreEntityWithTag ) )
				{
					return false;
				}
				return true;
			}
		}
		if( checkQuestRequests && callFromQuest )
		{
			callFromQuest = false;
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AnimalNervous' )
		{
			callFromQuest = true;
			return true;
		}
		return false;
	}
};

class CBTCondActorInDangerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondActorInDanger';

	editable var dangerRadius : float;
	editable var checkQuestRequests : bool;
	editable var ignoreEntityWithTag : name;
	
	default dangerRadius = 12.f;
	default checkQuestRequests = true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AnimalNervous' );
	}
	
};