/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Oils in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_OIL, ON_EQUIPPED, OILS_JOURNAL_ENTRY : name;
	private var isClosing : bool;
	
		default CAN_EQUIP 			= 'TutorialOilCanEquip1';
		default SELECT_TAB 			= 'TutorialOilCanEquip2';
		default EQUIP_OIL 			= 'TutorialOilCanEquip3';
		default ON_EQUIPPED 		= 'TutorialOilEquipped';
		default OILS_JOURNAL_ENTRY 	= 'TutorialJournalOils';	
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y);
		theGame.GetTutorialSystem().ActivateJournalEntry(OILS_JOURNAL_ENTRY);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_OIL);
		CloseStateHint(ON_EQUIPPED);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);
		
		FactsAdd("tut_ui_prep_oils");
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == CAN_EQUIP)
		{
			ShowHint( SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabAlchemy() );
		}
		else if(hintName == ON_EQUIPPED)
		{
			QuitState();
		}
	}
	
	event OnOilTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		ShowHint(EQUIP_OIL, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnOilApplied()
	{
		CloseStateHint(EQUIP_OIL);
		ShowHint( ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y, , , , , true );		
	}
}

exec function tut_oil()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('OilsPreparation', '');
}