/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_ReusableClueUsed_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_ReusableClueUsed;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.clueTag )
		{
			condition.EvaluateImpl();		
		}	
	}
}

class W3QuestCond_ReusableClueUsed extends CQuestScriptedCondition
{
	editable var clueTag	 : name; 			hint clueTag = "Tag of clue to be found";
	editable var resetClue	 : bool; 			hint resetClue = "Insert Hint Here";
	editable var leaveFacts  : bool;			hint leaveFacts = "Insert Hint Here";
	editable var keepFocusHighlight : bool; 	hint keepFocusHighlight = "Insert Hint Here";
	default clueTag 		 = '';
	default resetClue		 = true;
	default leaveFacts		 = false;
	default keepFocusHighlight = false;
	
	saved var isFulfilled	: bool;
	var listener			: W3QuestCond_ReusableClueUsed_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_ReusableClueUsed_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnReusableClueUsed ), listener );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnReusableClueUsed ), listener );
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
		var focusModeController : CFocusModeController;

		if ( isFulfilled )
		{
			return;
		}
			
		focusModeController = theGame.GetFocusModeController();
		if ( focusModeController )
		{
			if ( focusModeController.WasReusableClueDetected( clueTag ) )
			{
				if ( resetClue )
				{
					focusModeController.ResetClue( clueTag, !leaveFacts, keepFocusHighlight );
				}
				isFulfilled = true;
			}
		}
	}
}