/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESwitchStateCondition
{
	SSC_TurnedOn,
	SSC_TurnedOff,
	SSC_Enabled,
	SSC_Disabled,
	SSC_Locked,
	SSC_Unlocked,
	SSC_MaxUseCountReached,
};

class W3QuestCond_SwitchState_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_SwitchState;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.switchTag )
		{
			condition.FindSwitch();
		}	
	}
}

class W3QuestCond_SwitchState extends CQuestScriptedCondition
{
	editable var switchTag		: name;
	editable var stateToCheck	: ESwitchStateCondition;
	
	var switchEntity			: W3Switch;
	var listener				: W3QuestCond_SwitchState_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_SwitchState_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, switchTag );
			FindSwitch();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, switchTag );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		FindSwitch();
		if ( !switchEntity )
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
		if ( switchEntity )
		{
			switch ( stateToCheck )
			{
			case SSC_TurnedOn:
				return switchEntity.IsOn();
			case SSC_TurnedOff:
				return !switchEntity.IsOn();
			case SSC_Enabled:
				return switchEntity.IsEnabled();
			case SSC_Disabled:
				return !switchEntity.IsEnabled();
			case SSC_Locked:
				return switchEntity.IsLocked();
			case SSC_Unlocked:
				return !switchEntity.IsLocked();
			case SSC_MaxUseCountReached:
				return switchEntity.IsUseCountReached();
			}
		}
		else if ( !listener )
		{
			RegisterListener( true );
		}
		return false;
	}

	function FindSwitch()
	{
		if ( switchEntity )
		{
			return;
		}
		switchEntity = (W3Switch)theGame.GetEntityByTag( switchTag );
		if ( switchEntity && listener )
		{
			RegisterListener( false );
		}
	}
};