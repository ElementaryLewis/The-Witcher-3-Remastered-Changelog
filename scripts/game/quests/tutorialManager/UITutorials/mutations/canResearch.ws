/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MutationsCanResearch in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_ADVANCED, PREREQUISITES, RESEARCHING, SELECT : name;
	private var isClosing : bool;
	private var selectedMutation : EPlayerMutationType;
	
		default SELECT_ADVANCED = 'TutorialMutationsSelectAdvMutation';
		default PREREQUISITES = 'TutorialMutationsPrerequisites';
		default SELECT = 'TutorialMutationsSelect';
		default RESEARCHING = 'TutorialMutationsResearching';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		ShowHint( SELECT, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Infinite, GetHighlightsMutationsInitial() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( SELECT_ADVANCED );
		CloseStateHint( PREREQUISITES );
		CloseStateHint( SELECT );
		CloseStateHint( RESEARCHING );
		
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
	
		if( hintName == RESEARCHING )
		{
			ShowHint( SELECT_ADVANCED, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Infinite, GetHighlightsMutationsAdvanced() );
		}
		else if( hintName == PREREQUISITES )
		{
			QuitState();
		}
	}
	
	
	public final function OnResearch()
	{
	}
		
	public final function OnMutationSelected( mut : EPlayerMutationType )
	{
		selectedMutation = mut;
		
		if( IsCurrentHint( SELECT ) && ( mut == EPMT_Mutation1 || mut == EPMT_Mutation2 || mut == EPMT_Mutation8 ) )
		{
			CloseStateHint( SELECT );	
			ShowHint( RESEARCHING, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input );
		}
		else if( IsCurrentHint( SELECT_ADVANCED ) )
		{
			if( mut == EPMT_Mutation1 || mut == EPMT_Mutation5 || mut == EPMT_Mutation7 || mut == EPMT_Mutation9 || mut == EPMT_Mutation11 || mut == EPMT_Mutation12 )
			{
				CloseStateHint( SELECT_ADVANCED );
				ShowHint( PREREQUISITES, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input );
			}
		}
	}
}