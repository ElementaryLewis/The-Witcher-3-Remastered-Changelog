/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ChooseGwintTurnPopup extends ConfirmationPopupData
{
	public var gwintMenuRef : CR4GwintGameMenu;
	
	protected function OnUserAccept() : void
	{
		gwintMenuRef.SetPlayerStarts(true);
	}
	
	protected function OnUserDecline() : void
	{
		gwintMenuRef.SetPlayerStarts(false);
	}
	
	protected function GetAcceptText() : string
	{
		return "gwint_choose_start_player_go_first";
	}
	
	protected function GetDeclineText() : string
	{
		return "gwint_choose_start_player_go_second";
	}
}

class CR4GwintGameMenu extends CR4GwintBaseMenu
{	
	protected var chooseTurnPopup : W3ChooseGwintTurnPopup;
	
	private var m_fxSetGwintResult : CScriptedFlashFunction;
	private var m_fxSetWhoStarts : CScriptedFlashFunction;
	private var m_fxShowTutorial : CScriptedFlashFunction;
	
	private var playerWon:bool;
	private var playerForfeited:bool;
	private var tutorialActive:bool; default tutorialActive = false;
	
	function EnableJournalTutorialEnries()
	{
		var tutSystem : CR4TutorialSystem;
		
		tutSystem = theGame.GetTutorialSystem();
		tutSystem.ActivateJournalEntry('gwentintroduction');
		tutSystem.ActivateJournalEntry('gwentstartinghand');
		tutSystem.ActivateJournalEntry('unitcardstrengthNEW');
		tutSystem.ActivateJournalEntry('unitcardrangeNEW');
		tutSystem.ActivateJournalEntry('unitcardsspecialabilityNEW');
		tutSystem.ActivateJournalEntry('weathercards');
		tutSystem.ActivateJournalEntry('redrawcardsNEW');
		tutSystem.ActivateJournalEntry('gwintturns');
		tutSystem.ActivateJournalEntry('gwintleaders');
		tutSystem.ActivateJournalEntry('totalstrengthNEW');
		tutSystem.ActivateJournalEntry('gwintpassing');
		tutSystem.ActivateJournalEntry('endround');
		tutSystem.ActivateJournalEntry('lifegems');
		tutSystem.ActivateJournalEntry('protipsgwent');
		tutSystem.ActivateJournalEntry('findingcards');
	}	
	
	event  OnConfigUI()
	{	
		super.OnConfigUI();
		
		SendCardValues();
		
		SendPlayerNames();
		
		m_fxSetGwintResult = m_flashModule.GetMemberFlashFunction("winGwint");
		m_fxSetWhoStarts = m_flashModule.GetMemberFlashFunction("setFirstTurn");
		m_fxShowTutorial = m_flashModule.GetMemberFlashFunction("showTutorial");
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if (gwintManager.getDoubleAIEnabled())
		{
			m_flashValueStorage.SetFlashBool( "gwint.game.toggleAI", true );
		}
		
		if (!gwintManager.GetHasDoneTutorial())
		{
			EnableJournalTutorialEnries();
			if (!theGame.GetTutorialSystem().AreMessagesEnabled() || FactsQuerySum("NewGamePlus") > 0)
			{
				gwintManager.SetHasDoneTutorial(true);
			}
			else
			{
				m_fxShowTutorial.InvokeSelf();
				sendTutorialStrings();
				tutorialActive = true;
			}
		}
		
		SendDecksInformation();
		
		theSound.SoundLoadBank( "gwint_ep2.bnk", true );
		theSound.EnterGameState( ESGS_Gwent );
		
		theTelemetry.LogWithName( TE_HERO_GWENT_MATCH_STARTED );
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		
		gwintManager.SetHasDoneTutorial(true);
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		if (thePlayer.GetGwintMinigameState() != EMS_End_PlayerWon && thePlayer.GetGwintMinigameState() != EMS_End_PlayerLost && thePlayer.GetGwintMinigameState() != EMS_End_PlayerForfeited)
		{
			if (playerWon)
			{
				thePlayer.SetGwintMinigameState( EMS_End_PlayerWon );
				theTelemetry.LogWithValue( TE_HERO_GWENT_MATCH_ENDED, 1 );
			}
			else
			{
				if(playerForfeited)
					thePlayer.SetGwintMinigameState( EMS_End_PlayerLost | EMS_End_PlayerForfeited);
				else
					thePlayer.SetGwintMinigameState( EMS_End_PlayerLost );
					
				theTelemetry.LogWithValue( TE_HERO_GWENT_MATCH_ENDED, 0 );
			}
		}
		
		if (chooseTurnPopup)
		{
			delete chooseTurnPopup;
		}
		
		theSound.LeaveGameState( ESGS_Gwent );
		
		
		
		theSound.SoundEvent( "system_resume" );
		
		if (!gwintManager.testMatch && theGame.isUserSignedIn())
		{
			theGame.FadeOutAsync( 0 );
			theGame.SetFadeLock( "Gwint_EndFadeOut" );
		}
		gwintManager.testMatch = false;
		
		theSound.SoundUnloadBank( "gwint_ep2.bnk" );
		
		
		theGame.GetGwintManager().SetForcedFaction( GwintFaction_Neutral );
	}
	
	public function OnQuitGameConfirmed()
	{
		playerWon = false;
		playerForfeited = true;
		super.OnQuitGameConfirmed();
	}
	
	private function SendCardValues():void
	{
		var l_flashObject: CScriptedFlashObject;
		
		l_flashObject = flashConstructor.CreateFlashObject("red.game.witcher3.menus.gwint.GwintCardValues");
		
		l_flashObject.SetMemberFlashNumber( "weatherCardValue", 5.0f ); 
		l_flashObject.SetMemberFlashNumber( "hornCardValue", 5.0f );   
		l_flashObject.SetMemberFlashNumber( "drawCardValue", 1.0f ); 	
		l_flashObject.SetMemberFlashNumber( "scorchCardValue", 8.0f );   
		l_flashObject.SetMemberFlashNumber( "summonClonesCardValue", 0.5f );  
		l_flashObject.SetMemberFlashNumber( "unsummonCardValue", 2.0f );   
		l_flashObject.SetMemberFlashNumber( "improveNeighboursCardValue", 4.0f ); 	
		l_flashObject.SetMemberFlashNumber( "nurseCardValue", 3.0f ); 	
		
		m_flashValueStorage.SetFlashObject( "gwint.game.cardValues", l_flashObject );
	}
	
	private function SendDecksInformation():void
	{
		var playerDeck : SDeckDefinition;
		var enemyDeck : SDeckDefinition;
		var playerDeckFlash : CScriptedFlashObject;
		var enemyDeckFlash : CScriptedFlashObject;
		
		if (tutorialActive)
		{
			playerDeck = gwintManager.GetTutorialPlayerDeck();
		}
		else
		{
			playerDeck = gwintManager.GetCurrentPlayerDeck();
		}
		playerDeckFlash = CreateDeckDefinitionFlash(playerDeck);
		
		enemyDeck = gwintManager.GetCurrentAIDeck();
		enemyDeckFlash = CreateDeckDefinitionFlash(enemyDeck);
		
		m_flashValueStorage.SetFlashObject("gwint.game.player.deck", playerDeckFlash);
		m_flashValueStorage.SetFlashObject("gwint.game.enemy.deck", enemyDeckFlash);
	}
	
	private function SendPlayerNames():void
	{
		if (theGame.GameplayFactsQuerySum("q602_geralt_possessed") == 1)
		{
			m_flashValueStorage.SetFlashString("gwint.player.name.one", GetLocStringByKeyExt("gwint_witold"));
		}
		else
		{
			m_flashValueStorage.SetFlashString("gwint.player.name.one", GetLocStringByKeyExt("gwint_geralt"));
		}
		m_flashValueStorage.SetFlashString("gwint.player.name.two", GetLocStringByKeyExt("gwint_opponent"));
	}
	
	event  OnChooseCoinFlip():void
	{
		chooseTurnPopup = new W3ChooseGwintTurnPopup in this;
	
		chooseTurnPopup.SetMessageTitle(GetLocStringByKeyExt("gwint_choose_start_player_popup_title"));
		chooseTurnPopup.SetMessageText(GetLocStringByKeyExt("gwint_choose_start_player_popup_desc"));
		chooseTurnPopup.gwintMenuRef = this;
		chooseTurnPopup.BlurBackground = true;
		
		RequestSubMenu('PopupMenu', chooseTurnPopup);
	}
	
	event  OnMatchResult(pWon : bool):void
	{
		playerWon = pWon;
		playerForfeited = false;
	}
	
	event  OnNeutralRoundVictoryAchievement():void
	{
		theGame.GetGamerProfile().AddAchievement(EA_GeraltandFriends);
	}
	
	event  OnHeroRoundVictoryAchievement():void
	{
		theGame.GetGamerProfile().AddAchievement(EA_Allin);
	}
	
	event  OnKilledItAchievement():void
	{
		theGame.GetGamerProfile().AddAchievement(EA_KilledIt);
	}
	
	public function SetPlayerStarts(playerFirst:bool):void
	{
		m_fxSetWhoStarts.InvokeSelfOneArg(FlashArgBool(playerFirst));
	}
	
	protected function sendTutorialStrings():void
	{
		var l_flashArray : CScriptedFlashArray;
		var maString:string;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_welcome_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_startinghand_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_unitcardstrength_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_unitcardrange_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_unitcardspecialability_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_weather_cards_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_redraw_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_your_battlefield_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_enemy_battlefield_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_turns_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_leaders_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_playing_cards_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_total_strength_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_passing_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_end_round_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_gems_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_protips_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_tut_finding_cards_desc")));
		
		m_flashValueStorage.SetFlashArray( "gwint.tutorial.strings", l_flashArray );
	}
	
	public function EndGwintMatch( result : int )
	{
		m_fxSetGwintResult.InvokeSelfOneArg(FlashArgInt(result));
	}
}