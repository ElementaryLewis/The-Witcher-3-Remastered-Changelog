/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Shop in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, BUY, CLOSE : name;
	private var isClosing : bool;
	private const var SHOP_POS_CLOSE_X, SHOP_POS_CLOSE_Y, SHOP_POS_X, SHOP_POS_Y : float;
	
		default DESCRIPTION = 'TutorialShopDescription';
		default BUY = 'TutorialShopBuy';
		default CLOSE = 'TutorialShopClose';
		default SHOP_POS_X = 0.3;
		default SHOP_POS_Y = 0.4;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(BUY);
		CloseStateHint(CLOSE);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		
	}
	
	event OnBoughtItem()
	{
		
	}
}