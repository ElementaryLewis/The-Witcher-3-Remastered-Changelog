/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4DeckBuilderMenu extends CR4GwintBaseMenu
{
	private var m_fxSetSelectedDeck	: CScriptedFlashFunction;
	private var m_fxSetGwintGamePending : CScriptedFlashFunction;
	private var m_fxShowTutorial : CScriptedFlashFunction;
	private var m_fxContinueTutorial : CScriptedFlashFunction;
	private var m_fxSetPassiveAbilString : CScriptedFlashFunction;
	
	function EnableJournalTutorialEnries()
	{
		var tutSystem : CR4TutorialSystem;
		
		tutSystem = theGame.GetTutorialSystem();
		tutSystem.ActivateJournalEntry('deckpanelMERGEDNEW');
		tutSystem.ActivateJournalEntry('deckcompositionNEW');
		
	}
	
	event  OnConfigUI()
	{
		var selectedDeckIndex : eGwintFaction;
		var tutSystem : CR4TutorialSystem;		
		super.OnConfigUI();
		
		m_fxSetSelectedDeck = m_flashModule.GetMemberFlashFunction("setSelectedDeck");
		m_fxSetGwintGamePending = m_flashModule.GetMemberFlashFunction("setGwintGamePending");
		m_fxShowTutorial = m_flashModule.GetMemberFlashFunction("showTutorial");
		m_fxContinueTutorial = m_flashModule.GetMemberFlashFunction("continueTutorial");
		m_fxSetPassiveAbilString = m_flashModule.GetMemberFlashFunction("setPassiveAbilityString");
		
		m_fxSetPassiveAbilString.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("gwint_passive_ability")));	
		
		selectedDeckIndex = gwintManager.GetForcedFaction();
		if (selectedDeckIndex == GwintFaction_Neutral)
		{
			selectedDeckIndex = gwintManager.GetSelectedPlayerDeck();
		}
		
		m_fxSetSelectedDeck.InvokeSelfOneArg(FlashArgInt(selectedDeckIndex));
		m_fxSetGwintGamePending.InvokeSelfOneArg(FlashArgBool(gwintManager.gameRequested));
		
		SendDeckInformation();
		SendCollectionInformation();
		SendLeaderCollectionInformation();
		theSound.EnterGameState( ESGS_Gwent );
		
		theGame.GetGuiManager().RequestMouseCursor(true);

		if (theInput.IsMousePresent())
		{
			theGame.CenterMouse();
		}
		
		if (!gwintManager.GetHasDoneDeckTutorial())
		{
			EnableJournalTutorialEnries();
			if (!theGame.GetTutorialSystem().AreMessagesEnabled() || FactsQuerySum("NewGamePlus") > 0)
			{
				gwintManager.SetHasDoneDeckTutorial(true);
			}
			else
			{
				sendTutorialStrings();
				m_fxShowTutorial.InvokeSelf();
			}
		}

		CloseNewCardPopup();
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		gwintManager.SetHasDoneDeckTutorial(true);
		
		if (gwintManager.gameRequested)
		{
			gwintManager.gameRequested = false;
			theGame.RequestMenu( 'GwintGame' );
		}
		else
		{
			theSound.LeaveGameState( ESGS_Gwent );
			
			
			theGame.GetGwintManager().SetForcedFaction( GwintFaction_Neutral );
		}
	}
	
	public function OnQuitGameConfirmed()
	{
		if (gwintManager.gameRequested)
		{
			if (!gwintManager.testMatch && theGame.isUserSignedIn())
			{
				theGame.FadeOutAsync( 0 );
				theGame.SetFadeLock( "Gwint_EndFadeOut" );
			}
			gwintManager.testMatch = false;
			
			gwintManager.gameRequested = false;
			thePlayer.SetGwintMinigameState( EMS_End_PlayerLost | EMS_End_PlayerForfeited );
		}
		super.OnQuitGameConfirmed();
	}
	
	protected function SendDeckInformation():void
	{
		var deckListArray : CScriptedFlashArray;
		var deckInfo : CScriptedFlashObject;
		var currentDeckInfo : SDeckDefinition;
		var i : int;
		
		deckListArray = m_flashValueStorage.CreateTempFlashArray();
		
		if (gwintManager.GetFactionDeck(GwintFaction_NothernKingdom, currentDeckInfo) && currentDeckInfo.unlocked && 
			(gwintManager.GetForcedFaction() == GwintFaction_Neutral || gwintManager.GetForcedFaction() == GwintFaction_NothernKingdom))
		{
			deckInfo = CreateDeckDefinitionFlash(currentDeckInfo);
			deckListArray.PushBackFlashObject(deckInfo);
		}
		
		if (gwintManager.GetFactionDeck(GwintFaction_Nilfgaard, currentDeckInfo) && currentDeckInfo.unlocked && 
			(gwintManager.GetForcedFaction() == GwintFaction_Neutral || gwintManager.GetForcedFaction() == GwintFaction_Nilfgaard))
		{
			deckInfo = CreateDeckDefinitionFlash(currentDeckInfo);
			deckListArray.PushBackFlashObject(deckInfo);
		}
		
		if (gwintManager.GetFactionDeck(GwintFaction_Scoiatael, currentDeckInfo) && currentDeckInfo.unlocked && 
			(gwintManager.GetForcedFaction() == GwintFaction_Neutral || gwintManager.GetForcedFaction() == GwintFaction_Scoiatael))
		{
			deckInfo = CreateDeckDefinitionFlash(currentDeckInfo);
			deckListArray.PushBackFlashObject(deckInfo);
		}
		
		if (gwintManager.GetFactionDeck(GwintFaction_NoMansLand, currentDeckInfo) && currentDeckInfo.unlocked && 
			(gwintManager.GetForcedFaction() == GwintFaction_Neutral || gwintManager.GetForcedFaction() == GwintFaction_NoMansLand))
		{
			deckInfo = CreateDeckDefinitionFlash(currentDeckInfo);
			deckListArray.PushBackFlashObject(deckInfo);
		}

		if (theGame.GetDLCManager().IsEP2Available() && gwintManager.GetFactionDeck(GwintFaction_Skellige, currentDeckInfo) && currentDeckInfo.unlocked && 
			(gwintManager.GetForcedFaction() == GwintFaction_Neutral || gwintManager.GetForcedFaction() == GwintFaction_Skellige))
		{
			deckInfo = CreateDeckDefinitionFlash(currentDeckInfo);
			deckListArray.PushBackFlashObject(deckInfo);
		}
		
		m_flashValueStorage.SetFlashArray("gwint.deckbuilder.decks", deckListArray);
	}
	
	protected function SendCollectionInformation():void
	{
		var colList : CScriptedFlashArray;
		
		colList = m_flashValueStorage.CreateTempFlashArray();
		FillArrayWithCardList(gwintManager.GetPlayerCollection(), colList);
		
		m_flashValueStorage.SetFlashArray("gwint.deckbuilder.collection", colList);
	}
	
	protected function SendLeaderCollectionInformation():void
	{
		var colList : CScriptedFlashArray;
		
		colList = m_flashValueStorage.CreateTempFlashArray();
		FillArrayWithCardList(gwintManager.GetPlayerLeaderCollection(), colList);
		
		m_flashValueStorage.SetFlashArray("gwint.deckbuilder.leaderList", colList);
	}
	
	event  OnTabChanged(tabIndex:int)
	{
	}
	
	event  OnCardAddedToDeck(factionID:int, cardId:int)
	{
		gwintManager.AddCardToDeck(factionID, cardId);
	}
	
	event  OnCardRemovedFromDeck(factionID:int, cardId:int)
	{
		gwintManager.RemoveCardFromDeck(factionID, cardId);
	}
	
	event  OnSelectedDeckChanged(factionID:int)
	{
		gwintManager.SetSelectedPlayerDeck(factionID);
	}
	
	event  OnLeaderChanged(factionID:int, leaderID:int)
	{
		var deckDefinition : SDeckDefinition;
		var oldCardDefinition : SCardDefinition;
		var newCardDefinition : SCardDefinition;
		
		if (gwintManager.GetFactionDeck(factionID, deckDefinition))
		{
			if ( gwintManager.GetGwentCard( deckDefinition.leaderCard, oldCardDefinition ) )
			{
				if(gwintManager.GetIndex(oldCardDefinition) != leaderID)
				{
					OnPlaySoundEvent("gui_gwint_leader_change");
					
					
					if ( gwintManager.GetGwentCardByIndex(leaderID, newCardDefinition) )
					{
						deckDefinition.leaderCard = newCardDefinition.cardName;
						gwintManager.SetFactionDeck(factionID, deckDefinition);
					}
				}
			}
		}
	}
	
	event  OnLackOfUnitsError(numCards:int)
	{
		var errorString:string;
		var argsInt : array<int>;
		
		argsInt.PushBack(22 - numCards);
		
		errorString = GetLocStringByKeyExtWithParams("gwint_more_units", argsInt);
		
		showNotification(errorString);
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnTooManySpecialCards()
	{
		showNotification(GetLocStringByKeyExt("gwint_special_card_limit"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	protected function sendTutorialStrings():void
	{
		var l_flashArray : CScriptedFlashArray;
		var maString:string;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_welcome_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_factions_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_leaders_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_leaders_2_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_collection_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_in_deck_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_composition_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_full_deck_desc")));
		l_flashArray.PushBackFlashString(ReplaceTagsToIcons(GetLocStringByKeyExt("gwint_deck_tut_full_deck_2_desc")));
		
		
		m_flashValueStorage.SetFlashArray( "gwint.tutorial.strings", l_flashArray );
	}

	private function CloseNewCardPopup():void
	{
		theGame.GetTutorialSystem().HideTutorialHint('TutorialGwentDeckBuilder2');
	}
}