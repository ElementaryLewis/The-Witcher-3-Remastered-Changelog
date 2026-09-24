/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EFlyingCheck
{
	EFC_TakeOff,
	EFC_Landing,
}

class CBTTaskCheckFlyingActors extends IBehTreeTask
{
	var minFlyingActors	: int;
	var maxFlyingActors	: int;
	var flyingCheckType	: EFlyingCheck;
	var nextActionTime	: float;
	var delay			: float;
	var ifNot			: bool;
	
	default nextActionTime = 0;
	default delay = 1.0;
	
	function IsAvailable() 	: bool
	{
		if ( nextActionTime > GetLocalTime() )
		{
			return false;
		}
		return ActorNumberCheck();
	}
	
	function OnDeactivate()
	{
		nextActionTime = GetLocalTime() + delay;
	}
	
	function ActorNumberCheck() : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var i 				: int;
		var flyingActors 	: int;
		var actors 			: array< CGameplayEntity >;
		
		flyingActors = 0;
		FindGameplayEntitiesInRange( actors, npc, 50, 50, 'flying', FLAG_OnlyAliveActors );
		for ( i=0; i < actors.Size(); i+=1 )
		{
			if ( flyingCheckType == EFC_Landing )
			{
				if ( ((CActor)actors[i]).GetBehaviorVariable( 'npcStance' ) == (int)NS_Fly )
				{
					flyingActors += 1;
				}
			}
			else
			{
				if ( ((CActor)actors[i]).GetBehaviorVariable( 'npcStance' ) != (int)NS_Fly )
				{
					flyingActors += 1;
				}
			}
		}
		
		if ( flyingActors >= RandRange( maxFlyingActors, minFlyingActors ) )
		{
			if ( ifNot )
			{
				return false;
			}
			return true;
		}
		return false;
	}
};

class CBTTaskCheckFlyingActorsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCheckFlyingActors';

	editable var minFlyingActors	: int;
	editable var maxFlyingActors	: int;
	editable var flyingCheckType	: EFlyingCheck;
	editable var ifNot				: bool;
};
