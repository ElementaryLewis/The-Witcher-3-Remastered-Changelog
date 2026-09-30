/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class IBehTreePlayerTaskDefinition extends IBehTreeTaskDefinition
{
};

abstract class IBehTreePlayerConditionalTaskDefinition extends IBehTreeConditionalTaskDefinition
{
};

class CBTTaskPlayerActionDecorator extends IBehTreeTask
{
	public var completeOnInput : bool;
	
	private var prevContext : name;
	
	function OnActivate() : EBTNodeStatus
	{
		if( GetActor() != thePlayer && GetNPC().GetHorseComponent() != thePlayer.GetUsedHorseComponent() )
			return BTNS_Failed;

		prevContext = theInput.GetContext();
		theInput.SetContext( 'ScriptedAction' );
		return BTNS_Active;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			if( 	( theInput.GetContext() != 'ScriptedAction' ) 
				&& 	( theInput.GetContext() != 'EMPTY_CONTEXT' ) 
				&&  ( theInput.GetContext() != GetPhotomodeContextName() )
				)
			{
				prevContext = theInput.GetContext();
				theInput.SetContext( 'ScriptedAction' );
			}
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var currentState : name;
		var contextName : name;
		
		if ( theInput.GetContext() != 'ScriptedAction' )
			return;
		
		currentState = thePlayer.GetCurrentStateName();
		
		switch( currentState )
		{
			case 'Combat' :
			case 'CombatSteel' :
			case 'CombatSilver' :
			case 'CombatFists' : 		
				contextName = thePlayer.GetCombatInputContext();
				break;
			case 'HorseRiding' : 		
				contextName = 'Horse';
				break;
			default :
				contextName = thePlayer.GetExplorationInputContext();
				break;
		}
		
		if( IsNameValid( contextName ) )
		{
			theInput.SetContext( contextName );
			
		}
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var item, itemL : SItemUniqueId;
		var inv : CInventoryComponent;
		
		if( eventName == 'StopPlayerActionOnInput' && completeOnInput )
		{
			inv = thePlayer.GetInventory();
			
			item = inv.GetItemFromSlot( 'r_weapon' );
			itemL = inv.GetItemFromSlot( 'l_weapon' );
			
			if( item != GetInvalidUniqueId() )
			{
				inv.UnmountItem( item, true );
			}
			if( itemL != GetInvalidUniqueId() )
			{
				inv.UnmountItem( itemL, true );
			}
			
			Complete( true );
			return true;
		}
		else if( eventName == 'StopPlayerAction' )
		{
			Complete( true );
			return true;
		}
		return false;
	}
}

class CBTTaskPlayerActionDecoratorDef extends IBehTreePlayerTaskDefinition
{
	default instanceClass = 'CBTTaskPlayerActionDecorator';

	editable var completeOnInput : CBehTreeValBool;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'StopPlayerActionOnInput' );
		listenToGameplayEvents.PushBack( 'StopPlayerAction' );
	}
}