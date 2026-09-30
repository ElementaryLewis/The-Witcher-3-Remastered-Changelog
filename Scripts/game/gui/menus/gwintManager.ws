/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SCardDefinition
{
	import var cardName			: name;
	import var title			: string;
	import var itemName			: name;		
	import var description		: string;
	import var power			: int;
	import var picture			: string;
	import var faction			: eGwintFaction;
	import var typeFlags		: int;
	import var effectFlags		: array< eGwintEffect >;
	import var summonFlags		: array< name >;
	
	
	import var dlcPictureFlag	: name; 	
	import var dlcPicture		: string;
}


import struct SDeckDefinition
{
	import var deckName					: name;
	import var leaderCard 				: name;
	import var specialCard 				: name;
	import var difficulty 				: int;
	import var cards 					: array< name >;
	import var unlocked					: bool;
};

import struct SDynamicCard
{
	import var cardName		: name;
	import var difficulty	: int;
}

import class CR4GwintManager extends IGameSystem
{
	public var testMatch:bool; default testMatch = false;
	
	import final function GetCardDefs() : array<SCardDefinition>;
	import final function GetLeaderDefs() : array<SCardDefinition>;
	
	import final function GetGwentCard( cardName: name, out card:SCardDefinition ) : bool;
	import final function GetGwentCardByIndex( cardIndex : int, out card:SCardDefinition ) : bool;

	import final function GetIndex( card: SCardDefinition ) 		: int;
	import final function IsKingCard( card: SCardDefinition ) 	: bool;

	
	import final function GetDeck( deckName: name, difficulty: int, out deck:SDeckDefinition) : bool;
	import final function GetDynamicCards( deckName: name ) : array<SDynamicCard>;

	
	import final function GetPlayerCollection() : array<CName>;
	import final function GetPlayerLeaderCollection() : array<CName>;
	import final function GetPlayerCardCount(cardName: name) : int;
	
	import final function GetSelectedPlayerDeck() : eGwintFaction;
	import final function SetSelectedPlayerDeck(index : eGwintFaction) : void;
	
	import final function UnlockDeck(index : eGwintFaction) : void;
	import final function IsDeckUnlocked(index : eGwintFaction) : bool;
	
	import final function AddCardToCollection(cardName : name) : void;
	import final function RemoveCardFromCollection(cardName : name) : void;
	import final function HasCardInCollection(cardName : name) : bool;
	import final function HasCardsOfFactionInCollection(faction : eGwintFaction, optional includeLeaders : bool) : bool;
	
	import final function AddCardToDeck(faction:eGwintFaction, cardIndex : int) : void;
	import final function RemoveCardFromDeck(faction:eGwintFaction, cardIndex : int) : void;
	import final function GetFactionDeck(faction:eGwintFaction, out deck:SDeckDefinition) : bool;
	import final function SetFactionDeck(faction:eGwintFaction, deck:SDeckDefinition) : void;
	
	import final function GetHasDoneTutorial() : bool;
	import final function SetHasDoneTutorial(value : bool) : void;
	
	import final function GetHasDoneDeckTutorial() : bool;
	import final function SetHasDoneDeckTutorial(value : bool) : void;
	
	public function HasLootedCard() : bool
	{
		return FactsDoesExist("Gwint_Card_Looted");
	}

	
	public function GetGwentCardIndex( cardName: name ) : int
	{
		var card: SCardDefinition;

		if ( GetGwentCard( cardName, card ) )
		{
			return GetIndex(card);
		}

		return -1;
	}

	public function GetCardNameFromItemName( itemName: name ) : name
	{
		var cardDefinitions : array<SCardDefinition>;
		var cardDefinition : SCardDefinition;
		var cardName : name;
		var i : int;

		cardDefinitions = theGame.GetGwintManager().GetCardDefs();
		for(i = 0; i < cardDefinitions.Size(); i+=1)
		{
			cardDefinition = cardDefinitions[i];
			if( cardDefinition.itemName == itemName )
			{
				cardName = cardDefinition.cardName;
				break;
			}
		}

		if ( cardName != '' )
		{
			return cardName;
		}

		cardDefinitions = theGame.GetGwintManager().GetLeaderDefs();
		for(i = 0; i < cardDefinitions.Size(); i+=1)
		{
			cardDefinition = cardDefinitions[i];
			if( cardDefinition.itemName == itemName )
			{
				cardName = cardDefinition.cardName;
				break;
			}
		}

		return cardName;
	}
	
	public function OpponentFaction() : eGwintFaction
	{
		var deck : SDeckDefinition;
		var card: SCardDefinition;

		if ( GetDeck( selectedEnemyDeck, difficulty, deck) )
		{
			
			if ( GetGwentCard( deck.leaderCard, card ) )
			{
				return card.faction;
			}
		}
		
		
		return GwintFaction_Neutral;
	}
	
	event  OnGwintSetupNewgame()
	{		
		var deck : SDeckDefinition;

		AddCardToCollection('yarpen');
		AddCardToCollection('redanian2');

		if ( GetDeck( 'North', 1, deck) )
		{
			SetFactionDeck(GwintFaction_NothernKingdom, deck);
		}
		if ( GetDeck( 'Nilf', 1, deck) )
		{
			SetFactionDeck(GwintFaction_Nilfgaard, deck);
		}
		if ( GetDeck( 'scotial', 1, deck) )
		{
			SetFactionDeck(GwintFaction_Scoiatael, deck);
		}
		if ( GetDeck( 'nml', 1, deck) )
		{
			SetFactionDeck(GwintFaction_NoMansLand, deck);
		}
		if ( GetDeck( 'ske', 1, deck) )
		{
			SetFactionDeck(GwintFaction_Skellige, deck);
		}

		UnlockDeck(GwintFaction_NothernKingdom);
		UnlockDeck(GwintFaction_Nilfgaard);
		UnlockDeck(GwintFaction_Scoiatael);
		UnlockDeck(GwintFaction_NoMansLand);

		SetSelectedPlayerDeck(GwintFaction_NothernKingdom);
	}
	
	event  OnGwintSetupSkellige()
	{
		var skePlayerDeck : SDeckDefinition;
		
		skePlayerDeck.leaderCard = 'Crach_an_Craite';	
		skePlayerDeck.specialCard = '';	
		skePlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Skellige, skePlayerDeck);
		
		
	}
	
	
	
	
	
	private var selectedEnemyDeck : name;
	private var additionalEnemyCards: array<name>;
	private var forcePlayerFaction : eGwintFaction;
	
	private var difficulty : int;
	private var difficultybalance: array<int>;

	
	
	public function GetDifficulty( diffIndex: int ) : int
	{
		if (difficultybalance.Size() < diffIndex + 1)
		{
			return difficultybalance[diffIndex - 1];
		}

		return 0;
	}
	
	private var doubleAIEnabled : bool;
	
	public var gameRequested : bool; default gameRequested = false;
	
	public function setDoubleAIEnabled(value:bool):void
	{
		doubleAIEnabled = value;
	}
	
	public function getDoubleAIEnabled():bool
	{
		return doubleAIEnabled;
	}
	
	public function GetForcedFaction():eGwintFaction
	{
		return forcePlayerFaction;
	}
	
	public function SetForcedFaction(faction : eGwintFaction):void
	{
		forcePlayerFaction = faction;
	}
	
	public function GetCurrentPlayerDeck() : SDeckDefinition
	{
		var selectedDeck : SDeckDefinition;
		
		if (forcePlayerFaction == GwintFaction_Neutral)
		{
			GetFactionDeck(GetSelectedPlayerDeck(), selectedDeck);
		}
		else
		{
			GetFactionDeck(forcePlayerFaction, selectedDeck);
		}
		
		return selectedDeck;
	}
	
	public function HasUnlockedDeck():bool
	{
		if (!IsDeckUnlocked(GwintFaction_NoMansLand) && !IsDeckUnlocked(GwintFaction_Nilfgaard) &&
			!IsDeckUnlocked(GwintFaction_NothernKingdom) && !IsDeckUnlocked(GwintFaction_Scoiatael))
		{
			return false;
		}
		
		return true;
	}
	
	public function SetEnemyDeck( deckName: name ) : void
	{
		selectedEnemyDeck = deckName;
	}
	
	public function SetAdditionalCards( cards: array<name> ) : void
	{
		additionalEnemyCards = cards;
	}

	public function AddAdditionalEnemyCard(card: name)
	{
		additionalEnemyCards.PushBack(card);
	}

	public function GetAdditionalCards() : array<name>
	{
		return additionalEnemyCards;
	}
	
	public function GetCurrentAIDeck() : SDeckDefinition
	{
		var deck : SDeckDefinition;

		
		GenerateDifficultyData();

		if ( GetDeck( selectedEnemyDeck, difficulty, deck) )
		{
			return deck;
		}
		else
		{
			
			GetDeck( 'NilfEasy', difficulty, deck);
			return deck;
		}
	}
		
	private function GenerateDifficultyData()
	{
		var difficultyBalanceValue : int;

		difficulty = FactsQueryLatestValue("gwent_difficulty");

		if (difficulty)
		{
			
			if (difficulty == 1) 
			{ 
				difficultyBalanceValue += 80;
			}
			
			if (difficulty == 2) 
			{ 
				difficultyBalanceValue += 0;
			}
			
			if (difficulty == 3) 
			{ 
				difficultyBalanceValue -= 80;
			}
		}

		difficultybalance.Clear();
		difficultybalance.Resize(15);

		difficultybalance[0] = 145 + difficultyBalanceValue;
		difficultybalance[1] = 150 + difficultyBalanceValue;
		difficultybalance[2] = 155 + difficultyBalanceValue;
		difficultybalance[3] = 160 + difficultyBalanceValue;
		difficultybalance[4] = 165 + difficultyBalanceValue;
		difficultybalance[5] = 170 + difficultyBalanceValue;
		difficultybalance[6] = 175 + difficultyBalanceValue;
		difficultybalance[7] = 180 + difficultyBalanceValue;
		difficultybalance[8] = 185 + difficultyBalanceValue;
		difficultybalance[9] = 190 + difficultyBalanceValue;
		difficultybalance[10] = 205 + difficultyBalanceValue;
		difficultybalance[11] = 215 + difficultyBalanceValue;
		difficultybalance[12] = 220 + difficultyBalanceValue;
		difficultybalance[13] = 225 + difficultyBalanceValue;
		difficultybalance[14] = 230 + difficultyBalanceValue;		
	}


}

import struct SGwintCardNameProperty
{
	import editable var cardName : name;
};

quest function AddAdditionalEnemyCards(cards: array<SGwintCardNameProperty>)
{
	var i: int;

	for (i = 0; i < cards.Size(); i += 1)
	{
		theGame.GetGwintManager().AddAdditionalEnemyCard(cards[i].cardName);
	}
}