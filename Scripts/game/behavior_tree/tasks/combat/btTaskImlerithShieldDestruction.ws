/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskImlerithShieldDestruction extends IBehTreeTask
{	
	var firstTreshold : float;
	var secondTreshold : float;
	var thirdTreshold : float;
	var finalTreshold : float;
	var dropShield : bool;
	
	var shield : CEntity;
	var shieldState : int;
	
	default shieldState = 0;
	
	function IsAvailable() : bool
	{
		if( dropShield )
		{
			return true;
		}
		else
		{
			if( GetEssence() < firstTreshold && shieldState == 0 )
			{
				return true;
			}
			else if( GetEssence() < secondTreshold && shieldState == 1 )
			{
				return true;
			}
			else if( GetEssence() < thirdTreshold && shieldState == 2 )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if( !dropShield )
		{
			ProcessShieldDestruction();
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'BreakAttachmentShield' && dropShield )
		{
			GetNPC().DropItemFromSlot( 'l_weapon', true );
			return true;
		}
		else if( animEventName == 'ChangePhase' && dropShield )
		{
			GetNPC().SignalGameplayEvent( 'LeaveCurrentCombatStyle' );
			return true;
		}
		
		return false;
	}
	
	function ProcessShieldDestruction()
	{	
		var npc : CNewNPC = GetNPC();
		var effectName : name;
		var appearanceName : name;
		
		if( shieldState == 0 )
		{
			effectName = 'destroy';
			appearanceName = 'damaged';
		}
		else if( shieldState == 1 )
		{
			effectName = 'destroy';
			appearanceName = 'damaged_02';
		}
		else if( shieldState == 2 )
		{
			effectName = 'destroy';
			appearanceName = 'damaged_03';
		}
		
		shieldState += 1;
		
		shield = npc.GetInventory().GetItemEntityUnsafe( npc.GetInventory().GetItemFromSlot( 'l_weapon' ) );
		npc.ToggleEffectOnShield( effectName, true );
		shield.ApplyAppearance( appearanceName );
	}
	
	function GetEssence() : float
	{
		return 100 * GetActor().GetStatPercents( BCS_Essence );
	}
}

class CBTTaskImlerithShieldDestructionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskImlerithShieldDestruction';

	editable var firstTreshold : float;
	editable var secondTreshold : float;
	editable var thirdTreshold : float;
	editable var finalTreshold : float;
	editable var dropShield : bool;
	
	default firstTreshold = 81.25;
	default secondTreshold = 62.5;
	default thirdTreshold = 43.75;
	default finalTreshold = 25.0;
	default dropShield = false;
}
