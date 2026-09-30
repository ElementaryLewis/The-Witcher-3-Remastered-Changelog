/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CGwintMenuInitData extends CObject
{
	import public var deckName : name;
	import public var difficulty : EGwintDifficultyMode;
	import public var aggression : EGwintAggressionMode;
	import public var allowMultipleMatches : bool;
};

class CR4GwintMenu extends CR4MenuBase
{

	event  OnConfigUI()
	{	
		
	}

	event  OnClosingMenu()
	{
	}

	event OnCloseMenu()
	{
		CloseMenu();
	}

	event  OnTraceMe(text : string)	
	{	
	}
	
	event  OnPlaySound(text : string)	
	{		
	}
	
	event  OnBattleResults(playerLivesLeft : int, enemyLivesLeft : int )	
	{	
		CloseMenu();
	}	
	
	event  OnGetPlayerDeck(index : int)	
	{	
	}
	
	event  OnSetPlayerDeck( factionIndex : int, cardIndex : int)	
	{	
	}
	
	event  OnNewKingChosen( factionIndex : int, kingIndex : int)	
	{		
	}

	event  OnCustomPowersReques(index : int)	
	{	
		
	}
	
	
	function GetPlayerDeck(out container : CScriptedFlashArray, faction : int) :void
	{
		
	}

	function SetBattlefieldAngles() :void
	{
	}
	
	function GameplaySettings() :void
	{	
	}
	
	function SetCardAttributeValue() :void
	{
		
	}	
	
	function GetAICardCollection(out container : CScriptedFlashArray) :void
	{
		
	}

	function GetPlayerCardCollection(out container : CScriptedFlashArray) :void
	{		
		
	}	

	function GetCardDefinitionTest(out container : CScriptedFlashArray) :void
	{
		
	}
		
	function GetKingChoices(out container : CScriptedFlashArray) :void
	{		
	}
	
	function GetKingDefinition(out container : CScriptedFlashArray) :void
	{
	}
	
	function AddIndex(out container : CScriptedFlashArray, index:int):void
	{
	}
	
	function BuildCardObject(out container : CScriptedFlashArray, cardDef : SCardDefinition )
	{
	
	}
	
	function AddPower(out container : CScriptedFlashArray, index:int, playerOwner:bool):void
	{
		
	}
	
	private function ClearDeckDef( out deckDef : SDeckDefinition )
	{
	}

	private function ClearCardDef( out cardDef : SCardDefinition )
	{
	}

} 