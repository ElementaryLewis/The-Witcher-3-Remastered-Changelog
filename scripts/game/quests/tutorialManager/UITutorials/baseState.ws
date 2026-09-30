/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state TutHandlerBaseState in W3TutorialManagerUIHandler
{
	protected var defaultTutorialMessage : STutorialMessage;
	private var currentlyShownHint : name;
	
	
	public const var POS_INVENTORY_X, POS_INVENTORY_Y, POS_ALCHEMY_X, POS_ALCHEMY_Y, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, 
						POS_MUTATIONS_X, POS_MUTATIONS_Y, POS_MAP_X, POS_MAP_Y, POS_QUESTS_X, POS_QUESTS_Y,
						POS_GEEKPAGE_X, POS_GEEKPAGE_Y, POS_DISMANTLE_X, POS_DISMANTLE_Y, POS_RADIAL_X, POS_RADIAL_Y : float;
	
		default POS_INVENTORY_X = 0.05f;
		default POS_INVENTORY_Y = 0.63f;
		default POS_ALCHEMY_X = 0.67f;
		default POS_ALCHEMY_Y = 0.65f;
		default POS_CHAR_DEV_X = 0.3f;
		default POS_CHAR_DEV_Y = 0.7f;
		default POS_MUTATIONS_X = 0.02f;
		default POS_MUTATIONS_Y = 0.7f;
		default POS_MAP_X = 0.05f;
		default POS_MAP_Y = 0.5f;
		default POS_QUESTS_X = 0.375f;
		default POS_QUESTS_Y = 0.5f;
		default POS_GEEKPAGE_X = 0.35f;
		default POS_GEEKPAGE_Y = 0.6f;
		default POS_DISMANTLE_X = 0.3f;
		default POS_DISMANTLE_Y = 0.7f;
		default POS_RADIAL_X = .7f;
		default POS_RADIAL_Y = .6f;
	
	event OnEnterState(prevStateName : name)
	{	
		
		defaultTutorialMessage.type = ETMT_Hint;
		defaultTutorialMessage.forceToQueueFront = true;
		defaultTutorialMessage.canBeShownInMenus = true;
		defaultTutorialMessage.canBeShownInDialogs = true;
		defaultTutorialMessage.hintPositionType = ETHPT_DefaultUI;
		defaultTutorialMessage.disableHorizontalResize = true;
	}
	
	event OnLeaveState( nextStateName : name )
	{
		LogTutorial( "UIHandler: leaving state <" + this + ">, next will be <" + nextStateName + ">" );
	
		
		theGame.GetTutorialSystem().uiHandler.UnregisterUIState(GetStateName());
	}
	
	protected final function QuitState()
	{
		var entersNew : bool;
		
		
		if(this != theGame.GetTutorialSystem().uiHandler.GetCurrentState())
			return;
		
		
		entersNew = theGame.GetTutorialSystem().uiHandler.UnregisterUIState(GetStateName());
		
		
		if(!entersNew)
			virtual_parent.GotoState('Tutorial_Idle');
	}
	
	protected final function CloseStateHint(n : name)
	{
		if( IsCurrentHint( n ) )
		{
			theGame.GetTutorialSystem().HideTutorialHint(n);
			currentlyShownHint = '';
		}
	}
	
	protected final function IsCurrentHint(h : name) : bool
	{
		return currentlyShownHint == h;
	}
	
	protected final function ShowHint(tutorialScriptName : name, optional x : float, optional y : float, optional durationType : ETutorialHintDurationType, optional highlights : array<STutorialHighlight>, optional fullscreen : bool, optional isHudTutorial : bool, optional markSeen : bool )
	{
		var tut : STutorialMessage;
	
		tut = defaultTutorialMessage;
		tut.tutorialScriptTag = tutorialScriptName;		
		tut.highlightAreas = highlights;
		tut.forceToQueueFront = true;	
		tut.canBeShownInMenus = true;
		tut.isHUDTutorial = isHudTutorial;
		tut.disableHorizontalResize = true;
		tut.markAsSeenOnShow = markSeen;
		
		if(x != 0 || y != 0)
		{			
			tut.hintPositionType = ETHPT_Custom;
		}
		else
		{
			tut.hintPositionType = ETHPT_DefaultGlobal;
		}
		
		tut.hintPosX = x;
		tut.hintPosY = y;
		
		if(durationType == ETHDT_NotSet)
			tut.hintDurationType = ETHDT_Input;
		else
			tut.hintDurationType = durationType;
		
		if(fullscreen)
		{
			tut.blockInput = true;
			tut.pauseGame = true;
			tut.fullscreen = true;
		}
				
		theGame.GetTutorialSystem().DisplayTutorial(tut);
		currentlyShownHint = tutorialScriptName;
	}
	
	
	
	
	
	protected function AddHighlight( out highlights : array< STutorialHighlight >, x : float, y : float, width : float, height : float )
	{
		var h : STutorialHighlight;
		
		h.x = x;
		h.y = y;
		h.width = width;
		h.height = height;
		
		highlights.PushBack( h );
	}
	
	protected function HighlightsCombine( out highlights : array< STutorialHighlight >, toAppend : array< STutorialHighlight > )
	{
		var i : int;
		
		for( i=0; i<toAppend.Size(); i+=1 )
		{
			highlights.PushBack( toAppend[i] );
		}
	}
	
	
	
	protected function GetHighlightRadialItems() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .37f, .48f, .08f, .15f );
		AddHighlight( highlights, .545f, .48f, .08f, .15f );
		
		return highlights;
	}
	
	protected function GetHighlightRadialBolts() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .455f, .525f, .08f, .15f );
		
		return highlights;
	}
	
	protected function GetHighlightRadialBuffs() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .03f, .05f, .35f, .2f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightMapFilters() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .02f, .78f, .2f, .15f );
		
		return highlights;
	}
	
	protected function GetHighlightMapObjectives() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .68f, .09f, .3f, .25f );
		
		return highlights;
	}
	
	protected function GetHighlightMapWorldMap() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		var temp : string;
		
		temp = theGame.GetInGameConfigWrapper().GetVarValue('Hidden', 'WorldMapPreviewMode' );
		
		if( StringToInt( temp ) == 1 )
		{
			
			AddHighlight( highlights, .83f, .65f, .155f, .28f );
		}
		else if( StringToInt( temp ) == 2 )
		{
			
			AddHighlight( highlights, .75f, .57f, .24f, .36f );
		}
		
		return highlights;
	}
	
	
	
	protected function GetHighlightDismantleItems() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .115f, .17f, .35f, .55f );
		
		return highlights;
	}
	
	protected function GetHighlightDismantleComponents() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .56f, .275f, .3f, .3f );
		
		return highlights;
	}
	
	protected function GetHighlightDismantleCost() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .62f, .76f, .18f, .15f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightGeekPagePrimary() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .04f, .165f, .3f, .63f );
		
		return highlights;
	}
	
	protected function GetHighlightGeekPageSecondary() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .71f, .165f, .27f, .65f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightBlacksmithItems() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .115f, .17f, .345f, .57f );
		
		return highlights;
	}
	
	protected function GetHighlightBlacksmithSockets() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .62f, .44f, .18f, .36f );
		
		return highlights;
	}
	
	protected function GetHighlightBlacksmithPrice() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .62f, .76f, .18f, .15f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightCraftingList() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .04f, .15f, .34f, .8f );
		
		return highlights;
	}
	
	protected function GetHighlightCraftingItemDescription() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .69f, .13f, .29f, .39f );
		
		return highlights;
	}
	
	protected function GetHighlightCraftingIngredients() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .4f, .3f, .27f, .15f );
		
		return highlights;
	}
	
	protected function GetHighlightCraftingPrice() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .44f, .54f, .18f, .15f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightAlchemyIngredients() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .42f, .3f, .22f, .17f );
		
		return highlights;
	}
	
	protected function GetHighlightAlchemyItemDesc() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .69f, .13f, .29f, .5f );
		
		return highlights;
	}
	
	protected function GetHighlightAlchemyList() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .035f, .145f, .345f, .8f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightCharDevSkillSlotGroups() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .57f, .16f, .135f, .65f );
		
		return highlights;
	}
	
	protected function GetHighlightCharDevSkillSlotGroup1() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.565f, 0.145f, 0.08f, 0.33f );
		
		return highlights;
	}
	
	protected function GetHighlightCharDevSkills() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.085f, 0.35f, 0.27f, 0.37f );
		
		return highlights;
	}
	
	protected function GetHighlightCharDevSkillGroups() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.07f, 0.11f, 0.24f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightCharDevTabMutagens() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .295f, .115f, .07f, .12f );
		
		return highlights;
	}
	
	protected function GetHighlightCharDevMutagenBonusString() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .37f, .3f, .2f, .15f );
		
		return highlights;
	}

	protected function GetHighlightCharDevSkillPoints() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.135f, 0.745f, 0.15f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightsCharPanelMutation() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.587f, 0.4f, 0.1f, 0.17f );
		
		return highlights;
	}
	
	protected function GetHighlightsCharPanelMutagenSlots() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.43f, 0.19f, 0.08f, 0.15f );
		AddHighlight( highlights, 0.76f, 0.19f, 0.08f, 0.15f );
		AddHighlight( highlights, 0.76f, 0.64f, 0.08f, 0.15f );
		AddHighlight( highlights, 0.43f, 0.64f, 0.08f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightsCharPanelMutationSkillSlots() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.6f, 0.2f, 0.08f, 0.22f );
		AddHighlight( highlights, 0.6f, 0.57f, 0.08f, 0.22f );
		
		return highlights;
	}
	
	protected function GetHighlightsCharPanelMutationSkillSlot1() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.6f, 0.19f, 0.08f, 0.15f );
		
		return highlights;
	}	
	
	
	
	protected function GetHighlightHubMenuCharDev() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.645f, 0.42f, 0.13f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightHubMenuGlossary() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.11f, 0.42f, 0.13f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightHubMenuBestiary() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.135f, 0.46f, 0.13f, 0.15f );
		
		return highlights;
	}

	protected function GetHighlightHubMenuBooks() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.47f, 0.46f, 0.13f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightHubMenuInventory() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.325f, 0.42f, 0.13f, 0.15f );
		
		return highlights;
	}
	
	protected function GetHighlightHubMenuMap() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.43f, 0.42f, 0.13f, 0.15f );
		
		return highlights;
	}
	
	
	
	protected function GetHighlightInvTabCrafting() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.08f, 0.1f, 0.08f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightInvTabQuest() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.13f, 0.1f, 0.08f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightInvTabMisc() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.17f, 0.1f, 0.08f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightInvTabAlchemy() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.22f, 0.1f, 0.08f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightInvTabWeapons() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.26f, 0.1f, 0.08f, 0.14f );
		
		return highlights;
	}
	
	protected function GetHighlightForPaperdoll() : STutorialHighlight
	{
		var h : STutorialHighlight;
		
		h.x = 0.48;
		h.y = 0.12;
		h.width = 0.47;
		h.height = 0.78;
		
		return h;
	}
	
	protected function GetHighlightForItemsGrid() : STutorialHighlight
	{
		var h : STutorialHighlight;
		
		h.x = 0.05;
		h.y = 0.18;
		h.width = 0.335;
		h.height = 0.32;
		
		return h;
	}
	
	protected function GetHighlightForInventoryTabs() : STutorialHighlight
	{
		var h : STutorialHighlight;
		
		h.x = 0.1;
		h.y = 0.1;
		h.width = 0.23;
		h.height = 0.14;
		
		return h;
	}
	
	
	
	protected function GetHighlightsMutationsMaster() : array< STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, .43f, .59f, .125f, .21f );
		
		return highlights;
	}
	
	protected final function GetHighlightsMutationsAdvanced() : array < STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.15f, 0.11f, 0.1f, 0.15f );
		AddHighlight( highlights, 0.27f, 0.23f, 0.1f, 0.15f );
		AddHighlight( highlights, 0.285f, 0.7f, 0.1f, 0.15f );
		AddHighlight( highlights, 0.6f, 0.7f, 0.1f, 0.15f );
		AddHighlight( highlights, 0.62f, 0.23f, 0.1f, 0.15f );
		AddHighlight( highlights, 0.735f, 0.11f, 0.1f, 0.15f );
		
		return highlights;
	}
	
	protected final function GetHighlightsMutationsInitial() : array < STutorialHighlight >
	{
		var highlights : array< STutorialHighlight >;
		
		AddHighlight( highlights, 0.36f, 0.48f, 0.09f, 0.15f );
		AddHighlight( highlights, 0.45f, 0.34f, 0.09f, 0.15f );
		AddHighlight( highlights, 0.54f, 0.48f, 0.09f, 0.15f );
		
		return highlights;
	}
	
	
	
	
	
	
	event OnMenuClosing(menuName : name) 	{}
	event OnMenuClosed(menuName : name) 	{}
	event OnMenuOpening(menuName : name) 	{}
	event OnMenuOpened(menuName : name) 	{}
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool) {}
}