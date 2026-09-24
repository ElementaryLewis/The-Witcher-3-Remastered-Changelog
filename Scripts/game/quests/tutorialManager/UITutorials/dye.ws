/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Dye in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DYE, DYE2, DYE_REMOVER, DYE_PREVIEW : name;
	private var isClosing : bool;
	
		default DYE 			= 'TutorialDye';
		default DYE2 			= 'TutorialDye2';
		default DYE_REMOVER		= 'TutorialDyeRemover';
		default DYE_PREVIEW		= 'TutorialDyePreview';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( DYE );
		CloseStateHint( DYE2 );
		CloseStateHint( DYE_REMOVER );
		CloseStateHint( DYE_PREVIEW );
		
		LogTutorial( "UIHandler: leaving state <" + this + ">, next will be <" + nextStateName + ">" );
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == DYE )
		{
			ShowHint( DYE2, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == DYE2 )
		{
			ShowHint( DYE_PREVIEW, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == DYE_PREVIEW )
		{
			ShowHint( DYE_REMOVER, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == DYE_REMOVER )
		{
			QuitState();
		}
	}
	
	event OnDyeSelected()
	{
		ShowHint(DYE, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, , , , true);		
	}
}

exec function tut_dye()
{
	TutorialMessagesEnable( true );
	theGame.GetTutorialSystem().TutorialStart( false );
	TutorialScript( 'dye', '' );
}