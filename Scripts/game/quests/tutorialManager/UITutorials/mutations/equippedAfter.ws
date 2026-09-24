/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MutationsEquippedAfter in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var EQUIPPING_ONLY_ONE, MASTER, CHAR_PANEL : name;
	private var isClosing, activated : bool;
	
		default EQUIPPING_ONLY_ONE = 'TutorialMutationsEquippingOnlyOne';
		default MASTER = 'TutorialMutationsMasterMutation';
		default CHAR_PANEL = 'TutorialMutationsOpenCharPanel';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		activated = false;
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( EQUIPPING_ONLY_ONE );
		CloseStateHint( MASTER );
		CloseStateHint( CHAR_PANEL );
		
		theGame.GetTutorialSystem().MarkMessageAsSeen( EQUIPPING_ONLY_ONE );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		if( activated )
		{
			QuitState();
		}
	}
	
	event OnTutorialClosed( hintName : name, closedByParentMenu : bool )
	{
		if( closedByParentMenu || isClosing )
		{
			return true;
		}
	
		if( hintName == EQUIPPING_ONLY_ONE )
		{			
			ShowHint( MASTER, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input, GetHighlightsMutationsMaster() );
		}
		else if( hintName == MASTER )
		{
			ShowHint( CHAR_PANEL, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Infinite );
		}
	}
	
	public final function OnMutationEquippedPost()
	{
		ShowHint( EQUIPPING_ONLY_ONE, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input );
		activated = true;
	}
}