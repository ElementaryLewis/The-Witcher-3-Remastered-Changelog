/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class IQuestCombatManagerBaseBlock extends CQuestGraphBlock
{
	function GetBlockName() : string
	{
		return "PLZ_REDEFINE_MA_NAME";
	}
	function GetAITree() : IAITree
	{
		return NULL;
	}
}

class CQuestCombatManagerBlock extends IQuestCombatManagerBaseBlock
{
	editable inlined var combatStyle : CAINpcCombatStyle;
	
	function GetBlockName() : string
	{
		return "CombatManager: Human";
	}
	
	function GetAITree() : IAITree
	{
		return combatStyle;
	}
	
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "VesemirTutorial" );		
		names.PushBack( "OneHandedSword" );			
		names.PushBack( "OneHandedAxe" );			
		names.PushBack( "OneHandedBlunt" );			
		names.PushBack( "OneHandedAny" );			
		names.PushBack( "Fists" );					
		names.PushBack( "Shield" );					
		names.PushBack( "Bow" );					
		names.PushBack( "Crossbow" );				
		names.PushBack( "TwoHandedHammer" );		
		names.PushBack( "TwoHandedAxe" );			
		names.PushBack( "TwoHandedHalberd" );		
		names.PushBack( "TwoHandedSpear" );			
		names.PushBack( "Witcher" );				
	}
	function RunSpecialOption( option : int )
	{
		switch ( option )
		{
			case 0:
			combatStyle = new CAINpcVesemirTutorialCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 1:
			combatStyle = new CAINpcOneHandedSwordCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 2:
			combatStyle = new CAINpcOneHandedAxeCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 3:
			combatStyle = new CAINpcOneHandedBluntCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 4:
			combatStyle = new CAINpcOneHandedAnyCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 5:
			combatStyle = new CAINpcFistsCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 6:
			combatStyle = new CAINpcShieldCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 7:
			combatStyle = new CAINpcBowCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 8:
			combatStyle = new CAINpcCrossbowCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 9:
			combatStyle = new CAINpcTwoHandedHammerCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 10:
			combatStyle = new CAINpcTwoHandedAxeCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 11:
			combatStyle = new CAINpcTwoHandedHalberdCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 12:
			combatStyle = new CAINpcTwoHandedSpearCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 13:
			combatStyle = new CAINpcWitcherCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			default : return;
		}
	}
};

class CQuestMonsterCombatManagerBlock extends IQuestCombatManagerBaseBlock
{
	editable inlined var combatLogic : CAIMonsterCombatLogic;
	
	function GetBlockName() : string
	{
		return "CombatManager: Monster";
	}
	
	function GetAITree() : IAITree
	{
		return combatLogic;
	}
	
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "Witch1" );		
		names.PushBack( "Witch2" );		
		names.PushBack( "Witch3" );		
	}
	function RunSpecialOption( option : int )
	{
		switch ( option )
		{
			case 0:
			combatLogic = new CAIWitchCombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			case 1:
			combatLogic = new CAIWitch2CombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			case 2:
			combatLogic = new CAIWitchCombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			default : return;
		}
	}
};