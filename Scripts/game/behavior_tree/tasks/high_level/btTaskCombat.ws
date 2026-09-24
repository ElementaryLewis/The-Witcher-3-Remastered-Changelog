/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBehTreeHLTaskCombatBase extends IBehTreeTask
{
	var wasHit : bool;
	default wasHit = false;
	
	function OnActivate() : EBTNodeStatus
	{
		wasHit = false;
		
		return BTNS_Active;
	}
}

abstract class CBehTreeHLTaskCombatBaseDef extends IBehTreeHLTaskDefinition
{
};

class CBehTreeHLTaskCombat extends CBehTreeHLTaskCombatBase
{
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();
		if ( isActive )
		{
			if ( owner.IsInHitAnim() )
			{
				return true;
			}
			else if ( !owner.IsInDanger() )
			{
				return false;
			}
		}
		
		return wasHit || owner.IsInDanger() || owner.IsInCombat();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		super.OnActivate();
		
		SetIsInCombat( true );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		SetIsInCombat( false );
		
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( !isActive && (eventName == 'BeingHit' || eventName == 'CriticalState') )
		{
			wasHit = true;
			return true;
		}
		return false;
	}
};

class CBehTreeHLTaskCombatDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskCombat';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
		listenToGameplayEvents.PushBack( 'CriticalState' );
	}
};

class CBehTreeHLTaskAnimalCombat extends CBehTreeHLTaskCombatBase
{
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();
		if ( isActive )
		{
			if ( owner.IsInHitAnim() )
			{
				return true;
			}
			else if ( !owner.IsSeeingNonFriendlyNPC() )
			{
				return false;
			}
		}
		
		return wasHit || owner.IsSeeingNonFriendlyNPC();
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( !isActive && (eventName == 'BeingHit' || eventName == 'CriticalState') )
		{
			wasHit = true;
			return true;
		}
		return false;
	}
};

class CBehTreeHLTaskAnimalCombatDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskAnimalCombat';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
		listenToGameplayEvents.PushBack( 'CriticalState' );
	}
};