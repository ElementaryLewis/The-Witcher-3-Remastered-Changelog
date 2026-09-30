/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MutationsCharPanelUnlockedSkillSlot in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var ADDITIONAL_SLOT, COLOR, YELLOW : name;
	private var isClosing : bool;
	private var selectedMutation : EPlayerMutationType;
	
		default ADDITIONAL_SLOT = 'TutorialMutationsAdditionalSkillSlot';
		default COLOR = 'TutorialMutationsSlotColorMatching';
		default YELLOW = 'TutorialMutationsYellowMutations';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		ShowHint( ADDITIONAL_SLOT, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightsCharPanelMutationSkillSlot1() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( ADDITIONAL_SLOT );
		CloseStateHint( COLOR );
		CloseStateHint( YELLOW );
		
		theGame.GetTutorialSystem().MarkMessageAsSeen( ADDITIONAL_SLOT );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
	
	event OnTutorialClosed( hintName : name, closedByParentMenu : bool )
	{
		var highlights : array< STutorialHighlight >;
		
		if( closedByParentMenu || isClosing )
		{
			return true;
		}
		
		if( hintName == ADDITIONAL_SLOT )
		{
			ShowHint( COLOR, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightsCharPanelMutation() );
		}
		if( hintName == COLOR )
		{
			ShowHint( YELLOW, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input );
		}
		if( hintName == YELLOW )
		{
			QuitState();
		}
	}
}