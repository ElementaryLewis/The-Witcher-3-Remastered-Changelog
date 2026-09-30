/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function GetDialogActionIcons(flag : int) : array<EDialogActionIcon>
{
	var ret : array<EDialogActionIcon>;
	
	if(flag == 0)
	{
		ret.PushBack(DialogAction_NONE);
		return ret;
	}
	
	if(flag & DialogAction_AXII)				ret.PushBack(DialogAction_AXII);
	if(flag & DialogAction_CONTENT_MISSING)		ret.PushBack(DialogAction_CONTENT_MISSING);
	if(flag & DialogAction_BRIBE)				ret.PushBack(DialogAction_BRIBE);
	if(flag & DialogAction_HOUSE)				ret.PushBack(DialogAction_HOUSE);
	if(flag & DialogAction_PERSUASION)			ret.PushBack(DialogAction_PERSUASION);
	if(flag & DialogAction_GETBACK)				ret.PushBack(DialogAction_GETBACK);
	if(flag & DialogAction_GAME_DICES)			ret.PushBack(DialogAction_GAME_DICES);
	if(flag & DialogAction_GAME_FIGHT)			ret.PushBack(DialogAction_GAME_FIGHT);
	if(flag & DialogAction_GAME_WRESTLE)		ret.PushBack(DialogAction_GAME_WRESTLE);
	if(flag & DialogAction_CRAFTING)			ret.PushBack(DialogAction_CRAFTING);
	if(flag & DialogAction_SHOPPING)			ret.PushBack(DialogAction_SHOPPING);
	if(flag & DialogAction_EXIT)				ret.PushBack(DialogAction_EXIT);
	if(flag & DialogAction_HAIRCUT)				ret.PushBack(DialogAction_HAIRCUT);
	if(flag & DialogAction_MONSTERCONTRACT)		ret.PushBack(DialogAction_MONSTERCONTRACT);
	if(flag & DialogAction_BET)					ret.PushBack(DialogAction_BET);
	if(flag & DialogAction_STORAGE)				ret.PushBack(DialogAction_STORAGE);
	if(flag & DialogAction_GIFT)				ret.PushBack(DialogAction_GIFT);
	if(flag & DialogAction_GAME_DRINK)			ret.PushBack(DialogAction_GAME_DRINK);
	if(flag & DialogAction_GAME_DAGGER)			ret.PushBack(DialogAction_GAME_DAGGER);
	if(flag & DialogAction_SMITH)				ret.PushBack(DialogAction_SMITH);
	if(flag & DialogAction_ARMORER)				ret.PushBack(DialogAction_ARMORER);
	if(flag & DialogAction_RUNESMITH)			ret.PushBack(DialogAction_RUNESMITH);
	if(flag & DialogAction_TEACHER)				ret.PushBack(DialogAction_TEACHER);
	if(flag & DialogAction_FAST_TRAVEL)			ret.PushBack(DialogAction_FAST_TRAVEL);
	if(flag & DialogAction_GAME_CARDS)			ret.PushBack(DialogAction_GAME_CARDS);
	if(flag & DialogAction_SHAVING)				ret.PushBack(DialogAction_SHAVING);
	if(flag & DialogAction_AUCTION)				ret.PushBack(DialogAction_AUCTION);
	
	return ret;
}


class CPayFactBasedStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var valueFact : string;

	function CanUseAction() : bool 
	{
		return thePlayer.GetMoney() >= FactsQuerySum( valueFact );
	}
	
	function PerformAction()
	{
		thePlayer.RemoveMoney( FactsQuerySum( valueFact ) );
		GetWitcherPlayer().AddPoints( EExperiencePoint, CeilF(FactsQuerySum( valueFact ) / 10), true );
		theSound.SoundEvent("gui_bribe");
	}
	
	function GetActionText() : string 				
	{
		var language, audioLanguage : string;
		
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + FactsQuerySum( valueFact ) + ") ";
		}
		else
		{
			return " " + FactsQuerySum( valueFact ) + " ";
		}
	}
	
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_BRIBE; }
}


class CPayStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var money : int;
	editable var dontGrantExp : bool;
	editable var actionIcon : EDialogActionIcon;
			     default actionIcon = DialogAction_NONE;

	function CanUseAction() : bool 
	{
		return thePlayer.GetMoney() >= money; 
	}
	
	function PerformAction()
	{
		thePlayer.RemoveMoney( money );
		
		if( !dontGrantExp )
		{
			GetWitcherPlayer().AddPoints( EExperiencePoint, CeilF(money / 10), true );
		}
		
		theSound.SoundEvent("gui_bribe");
	}
	
	function GetActionText() : string 				
	{
		var language, audioLanguage : string;
		
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + money + ") ";
		}
		else
		{
			return " " + money + " ";
		}
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		if (actionIcon != DialogAction_NONE)
		{
			return actionIcon;
		}
		return DialogAction_BRIBE; 
	}
}

class CAxiiStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var level : int;
	
	function CanUseAction() : bool 
	{ 
		return GetWitcherPlayer().GetAxiiLevel() >= level;
	}
	
	function PerformAction()
	{
		GetWitcherPlayer().AddPoints( EExperiencePoint, 20 + GetWitcherPlayer().GetAxiiLevel() * 5, true );
	}
	
	function GetActionText() : string 				
	{ 
		var intParamsArray : array<int>;
		var language, audioLanguage : string;
		
		if( CanUseAction() )
		{
			return "";
		}
		
		intParamsArray.PushBack(level-1);
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + GetLocStringByKeyExtWithParams( "panel_hud_dialogue_axi_level", intParamsArray ) + ") "; 
		}
		else
		{
			return " " + GetLocStringByKeyExtWithParams( "panel_hud_dialogue_axi_level", intParamsArray ) + " "; 
		}
	}
	
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_AXII; }
}

class CArmWrestlingStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GAME_WRESTLE; }
}

class CDiceStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GAME_DICES; }
}

class CDrinkingStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GAME_DRINK; }
}

class CDaggerThrowingStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GAME_DAGGER; }
}

class CShopStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_SHOPPING; }
}

class CBlacksmithStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_SMITH; }
}

class CArmorerStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_ARMORER; }
}

class CRunesmithStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_RUNESMITH; }
}

class CTeacherStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_TEACHER; }
}

class CExitStorySceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_EXIT; }
}

class CFastTravelStorySceneChoiceAction extends CStorySceneChoiceLineActionScriptedContentGuard
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_FAST_TRAVEL;  }
}

class CHairCutSceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var money : int;

	function CanUseAction() : bool 
	{
		return thePlayer.GetMoney() >= money; 
	}
	
	function PerformAction()
	{
		thePlayer.RemoveMoney( money );
		theSound.SoundEvent("gui_bribe"); 
	}
	
	function GetActionText() : string 				
	{ 
		var language, audioLanguage : string;
		
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + money + ") ";
		}
		else
		{
			return " " + money + " ";
		}
	}
	
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_HAIRCUT;  }
}

class CShavingSceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var money : int;

	function CanUseAction() : bool 
	{
		return thePlayer.GetMoney() >= money; 
	}
	
	function PerformAction()
	{
		thePlayer.RemoveMoney( money );
		theSound.SoundEvent("gui_bribe"); 
	}
	
	function GetActionText() : string
	{ 
		var language, audioLanguage : string;
		
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + money + ") ";
		}
		else
		{
			return " " + money + " ";
		}
	}
	
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_SHAVING;  }
}

class CGameCardsChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GAME_CARDS;  }
	
	function PerformAction()
	{
		var hud : CR4ScriptedHud;
		var dialogueModule : CR4HudModuleDialog;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
			dialogueModule.SetGwentMode( true );
		}
	}
}
 
class CMonsterContractChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_MONSTERCONTRACT;  }
}

class CBetChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_BET;  }

	function CanUseAction()  : bool 				{ return thePlayer.GetMoney() > 0; }
	
	function GetActionText() : string 				
	{ 
		if( CanUseAction() )
			return "";

		return "(" + GetLocStringByKeyExt( "panel_crafting_exception_not_enough_money" ) + ") ";
	}
	
}

class CGetBackChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_GETBACK; }
}

class CHouseChoiceAction extends CStorySceneChoiceLineActionScripted
{
	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_HOUSE; }
}

class CAuctionSceneChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var money : int;

	function GetActionIcon() : EDialogActionIcon 	{ return DialogAction_AUCTION; }
	
	function CanUseAction() : bool 
	{
		return thePlayer.GetMoney() >= money; 
	}	
	
	function GetActionText() : string
	{ 
		var language, audioLanguage : string;
		
		theGame.GetGameLanguageName(audioLanguage,language);
		if (language != "AR")
		{
			return "(" + money + ") ";
		}
		else
		{
			return " " + money + " ";
		}
	}	
	
}