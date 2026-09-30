/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GwintQuitConfPopup extends ConfirmationPopupData
{
	public var gwintMenuRef : CR4GwintBaseMenu;
	
	protected function OnUserAccept() : void
	{
		gwintMenuRef.OnQuitGameConfirmed();
	}
}

class CR4GwintBaseMenu extends CR4MenuBase
{	
	protected var quitConfPopup : W3GwintQuitConfPopup;
	
	protected var gwintManager : CR4GwintManager;
	protected var flashConstructor : CScriptedFlashObject;

	event  OnConfigUI()
	{
		m_hideTutorial = true;
		m_forceHideTutorial = true;
		super.OnConfigUI();
		flashConstructor = m_flashValueStorage.CreateTempFlashObject();
		gwintManager = theGame.GetGwintManager();
		SendCardTemplates();
		theInput.StoreContext( 'EMPTY_CONTEXT' );

		theGame.ResetFadeLock( "GwintStart" );
		theGame.FadeInAsync( 0.2 );
	}
	
	event  OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		super.OnClosingMenu();
		
		if (quitConfPopup)
		{
			delete quitConfPopup;
		}
	}
	
	public function OnQuitGameConfirmed()
	{
		CloseMenu();
	}
	
	protected function SendCardTemplates()
	{
		var l_flashArray : CScriptedFlashArray;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		AddCardsToFlashArray(l_flashArray, gwintManager.GetCardDefs());
		AddCardsToFlashArray(l_flashArray, gwintManager.GetLeaderDefs());
		
		m_flashValueStorage.SetFlashArray( "gwint.card.templates", l_flashArray );
	}
	
	private function AddCardsToFlashArray(l_flashArray : CScriptedFlashArray, cards : array< SCardDefinition >)
	{
		var l_flashObject : CScriptedFlashObject;
		var currentCard : SCardDefinition;
		var combinedType : int;
		var i : int;
		var imageLoc : string;
		
		for (i = 0; i < cards.Size(); i += 1)
		{
			currentCard = cards[i];
			
			l_flashObject = flashConstructor.CreateFlashObject("red.game.witcher3.menus.gwint.CardTemplate");
			
			imageLoc = currentCard.picture;
			
			if (IsNameValid(currentCard.dlcPictureFlag) && theGame.GetDLCManager().IsDLCAvailable('dlc_008_001') && 
				theGame.GetInGameConfigWrapper().GetVarValue('DLC', 'dlc_008_001') == "true")
			{
				imageLoc = currentCard.dlcPicture;
			}
			
			l_flashObject.SetMemberFlashInt("index", theGame.GetGwintManager().GetIndex(currentCard));
			l_flashObject.SetMemberFlashString("title", GetLocStringByKeyExt(currentCard.title));
			l_flashObject.SetMemberFlashString("description", GetLocStringByKeyExt(currentCard.description));
			l_flashObject.SetMemberFlashInt("power", currentCard.power);
			l_flashObject.SetMemberFlashString("imageLoc", imageLoc);
			l_flashObject.SetMemberFlashInt("factionIdx", currentCard.faction);

			if (theGame.GetGwintManager().IsKingCard(currentCard))
			{
				
				l_flashObject.SetMemberFlashInt("typeArray", 0);
			}
			else
			{
				l_flashObject.SetMemberFlashInt("typeArray", currentCard.typeFlags);
			}
			
			AddCardEffectsToFlashObject(l_flashObject, currentCard);
			AddSummonFlagsToObject(l_flashObject, currentCard);
			
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
	}
	
	private function AddCardEffectsToFlashObject(flashObject:CScriptedFlashObject, card : SCardDefinition)
	{
		var flashEffectArray : CScriptedFlashArray;
		var i : int;
		
		flashEffectArray = m_flashValueStorage.CreateTempFlashArray();
		
		for (i = 0; i < card.effectFlags.Size(); i += 1)
		{
			flashEffectArray.PushBackFlashInt(card.effectFlags[i]);
		}
		
		flashObject.SetMemberFlashArray("effectFlags", flashEffectArray);
	}
	
	private function AddSummonFlagsToObject(flashObject:CScriptedFlashObject, card : SCardDefinition)
	{
		var flashSummonArray : CScriptedFlashArray;
		var i : int;
		var summon : SCardDefinition;
		
		flashSummonArray = m_flashValueStorage.CreateTempFlashArray();
		
		for (i = 0; i < card.summonFlags.Size(); i += 1)
		{
			if ( theGame.GetGwintManager().GetGwentCard( card.summonFlags[i], summon ) )
			{
				flashSummonArray.PushBackFlashInt( theGame.GetGwintManager().GetIndex(summon) );
			}
			else
			{
				LogChannel( 'Gwint', "Summon for card not found: " + NameToString(card.cardName) );
			}
		}
		
		flashObject.SetMemberFlashArray("summonFlags", flashSummonArray);
	}
	
	public function CreateDeckDefinitionFlash(deckInfo : SDeckDefinition, optional additionalCards: array<name>) : CScriptedFlashObject
	{
		var deckFlashObject : CScriptedFlashObject;
		var indicesFlashArray : CScriptedFlashArray;
		var dynCardRequirements : CScriptedFlashArray;
		var dynCards : CScriptedFlashArray;
		var i, diff : int;
		var card : SCardDefinition;
		var dynamicCards: array<SDynamicCard>;
		var allCards : array<name> = deckInfo.cards;

		
		for (i = 0; i < additionalCards.Size(); i += 1)
		{
			allCards.PushBack(additionalCards[i]);
		}
		
		deckFlashObject = flashConstructor.CreateFlashObject("red.game.witcher3.menus.gwint.GwintDeck");
		indicesFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		deckFlashObject.SetMemberFlashString("deckName", "");
		
		for (i = 0; i < allCards.Size(); i += 1)
		{
			if ( theGame.GetGwintManager().GetGwentCard( allCards[i], card ) )
			{
				indicesFlashArray.PushBackFlashInt( theGame.GetGwintManager().GetIndex(card) );
			}
			else
			{
				LogChannel( 'Gwint', NameToString(deckInfo.deckName) + ": card not found: " + NameToString(card.cardName) );
			}
		}
		deckFlashObject.SetMemberFlashArray("cardIndices", indicesFlashArray);
		deckFlashObject.SetMemberFlashBool("isUnlocked", deckInfo.unlocked);
		
		if ( theGame.GetGwintManager().GetGwentCard( deckInfo.leaderCard, card ) )
		{
			deckFlashObject.SetMemberFlashInt("selectedKingIndex", theGame.GetGwintManager().GetIndex(card));
		}
		else
		{
			LogChannel( 'Gwint', NameToString(deckInfo.deckName) + ": leaderCard not found: "+ NameToString(deckInfo.leaderCard) );
			deckFlashObject.SetMemberFlashInt("selectedKingIndex", -1);
		}
		
		if ( theGame.GetGwintManager().GetGwentCard( deckInfo.specialCard, card ) )
		{
			deckFlashObject.SetMemberFlashInt("specialCard", theGame.GetGwintManager().GetIndex(card));
		}
		else
		{
			LogChannel( 'Gwint', NameToString(deckInfo.deckName) + ": specialCard not found: "+ NameToString(deckInfo.specialCard) );
			deckFlashObject.SetMemberFlashInt("specialCard", -1);
		}
		
		
		dynCardRequirements = m_flashValueStorage.CreateTempFlashArray();
		dynCards = m_flashValueStorage.CreateTempFlashArray();

		dynamicCards = theGame.GetGwintManager().GetDynamicCards(deckInfo.deckName);
		for (i = 0; i < dynamicCards.Size(); i += 1)
		{
			if ( theGame.GetGwintManager().GetGwentCard( dynamicCards[i].cardName, card ) )
			{
				diff = theGame.GetGwintManager().GetDifficulty(dynamicCards[i].difficulty);
				
				dynCardRequirements.PushBackFlashInt(diff);
				dynCards.PushBackFlashInt(theGame.GetGwintManager().GetIndex(card));
			}
		}
		deckFlashObject.SetMemberFlashArray("dynamicCardRequirements", dynCardRequirements);
		deckFlashObject.SetMemberFlashArray("dynamicCards", dynCards);		
		
		return deckFlashObject;
	}

	
	
	public function FillArrayWithCardList(cardList:array< name >, targetArray:CScriptedFlashArray):void
	{
		var cardInfo : CScriptedFlashObject;
		var card: SCardDefinition;
		var i : int;
		
		for (i = 0; i < cardList.Size(); i += 1)
		{
			cardInfo = m_flashValueStorage.CreateTempFlashObject();

			if ( theGame.GetGwintManager().GetGwentCard( cardList[i], card ) )
			{
				cardInfo.SetMemberFlashInt("cardID", theGame.GetGwintManager().GetIndex(card));
				cardInfo.SetMemberFlashInt("numCopies", theGame.GetGwintManager().GetPlayerCardCount(cardList[i]));
				targetArray.PushBackFlashObject(cardInfo);
			}
		}
	}
	
	event  OnConfirmSurrender():void
	{
		quitConfPopup = new W3GwintQuitConfPopup in this;
		
		quitConfPopup.SetMessageTitle(GetLocStringByKeyExt("gwint_pass_game"));
		quitConfPopup.SetMessageText(GetLocStringByKeyExt("gwint_surrender_message_desc"));
		quitConfPopup.gwintMenuRef = this;
		quitConfPopup.BlurBackground = true;
		
		RequestSubMenu('PopupMenu', quitConfPopup);
	}
}