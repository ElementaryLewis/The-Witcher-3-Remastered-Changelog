/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_OilApplied_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_OilApplied;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}


class W3QuestCond_OilApplied extends CQuestScriptedCondition
{
	editable var swordType 		: EQuestSword;
	editable var oilName		: name;

	saved var	isFulfilled		: bool;
	var listener				: W3QuestCond_OilApplied_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_OilApplied_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnItemEquipped ), listener );		
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnOilApplied ), listener );		
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnItemEquipped ), listener );		
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnOilApplied ), listener );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		isFulfilled = false;
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterListener( true );
		}		
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}

	function Evaluate() : bool
	{
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}
		return isFulfilled;
	}

	function EvaluateImpl()
	{
		var steel, silver : bool;
	
		if ( isFulfilled )
		{
			return;
		}
	
		if( thePlayer != GetWitcherPlayer() )
		{
			LogQuest( "W3QuestCond_OilApplied: player is not a witcher so there can be no oil upgrade!" );
			return;
		}
	
		if ( swordType != EQS_Steel )
		{
			silver = GetWitcherPlayer().IsEquippedSwordUpgradedWithOil( false, oilName );
		}
		if ( swordType != EQS_Silver )
		{
			steel = GetWitcherPlayer().IsEquippedSwordUpgradedWithOil( true, oilName );
		}
		
		if ( swordType == EQS_Steel )
		{
			isFulfilled = steel;
		}
		else if ( swordType == EQS_Silver )
		{
			isFulfilled = silver;
		}
		else
		{
			isFulfilled = ( steel || silver );
		}
	}
}