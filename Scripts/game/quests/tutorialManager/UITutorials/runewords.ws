/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Runewords in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var RUNEWORDS2, ITEMS, ENCHANTS, ENCHANT_DESC, LEVEL, UI : name;
	private var isClosing : bool;
	private const var LEFT_X, LEFT_Y, RIGHT_X, RIGHT_Y : float;
	
		
		default RUNEWORDS2 	= 'TutorialRunewords2';
		default ITEMS 		= 'TutorialEnchantingItems';
		default ENCHANTS	= 'TutorialEnchantingEnchants';
		default ENCHANT_DESC= 'TutorialEnchantingEnchantDescription';		
		default LEVEL 		= 'TutorialEnchantingEnchantLevel';
		default UI			= 'TutorialEnchantingUI';
		
		default LEFT_X		= 0.02f;
		default LEFT_Y		= 0.6f;
		default RIGHT_X		= 0.67f;
		default RIGHT_Y 	= 0.6f;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(RUNEWORDS2, RIGHT_X, RIGHT_Y, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		
		CloseStateHint(RUNEWORDS2);
		CloseStateHint(ITEMS);
		CloseStateHint(ENCHANTS);
		CloseStateHint(ENCHANT_DESC);
		CloseStateHint(LEVEL);
		CloseStateHint(UI);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(RUNEWORDS2);

		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
		
		
		if(hintName == RUNEWORDS2)
		{
			highlights.Resize(1);
			highlights[0].x = 0.05;
			highlights[0].y = 0.13;
			highlights[0].width = 0.325;
			highlights[0].height = 0.85;
			
			CloseStateHint(RUNEWORDS2);
			ShowHint(ITEMS, RIGHT_X, RIGHT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ITEMS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.36;
			highlights[0].y = 0.14;
			highlights[0].width = 0.34;
			highlights[0].height = 0.7;
		
			CloseStateHint(ITEMS);
			ShowHint(ENCHANTS, RIGHT_X, RIGHT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ENCHANTS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.66;
			highlights[0].y = 0.15;
			highlights[0].width = 0.3;
			highlights[0].height = 0.61;
			
			CloseStateHint(ENCHANTS);
			ShowHint(ENCHANT_DESC, LEFT_X, LEFT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ENCHANT_DESC)
		{
			highlights.Resize(1);
			highlights[0].x = 0.66;
			highlights[0].y = 0.25;
			highlights[0].width = 0.15;
			highlights[0].height = 0.15;
			
			CloseStateHint(ENCHANT_DESC);
			ShowHint(LEVEL, LEFT_X, LEFT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == LEVEL)
		{
			CloseStateHint(LEVEL);
			ShowHint(UI, LEFT_X, LEFT_Y, ETHDT_Input);
		}
		else if(hintName == UI)
		{
			QuitState();
		}
	}
}


exec function tutrunewords()
{
	
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	theGame.GetTutorialSystem().UnmarkMessageAsSeen('TutorialRunewords2');
	
	
	TutorialScript3('runewords','');
}