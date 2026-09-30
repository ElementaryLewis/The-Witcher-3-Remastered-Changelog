/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskShouldBeScaredOnOverlay extends IBehTreeTask
{
	protected var infantInHand : bool;
	protected var catOnLap : bool;
	var jobTreeType : EJobTreeType;
	
	function ShouldBeScaredOnOverlay() : bool
	{
		var isInLeaveAction : bool;
		var npc				: CNewNPC;
		
		if ( !GetNPC().IsAtWork() )
			return false;
			
		jobTreeType = GetNPC().GetCurrentJTType();
		
		if ( jobTreeType == EJTT_Sitting )
		{
			npc = GetNPC();
			isInLeaveAction = npc.IsInLeaveAction();
			return !isInLeaveAction;
		}
		else if ( jobTreeType == EJTT_InfantInHand )
		{
			infantInHand = true;
			return true;
		}
		else if ( jobTreeType == EJTT_CatOnLap )
		{
			catOnLap = true;
			return true;
		}
		
		return false;
	}
	
	
}

class CBTTaskScaredWhileSitting extends CBTTaskShouldBeScaredOnOverlay
{
	var leftItem 	: CDrawableComponent;
	var rightItem 	: CDrawableComponent;
	var entity 		: CEntity;
	
	function IsAvailable() : bool
	{
		return ShouldBeScaredOnOverlay();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var leftItemAnimatedComponent 	: CAnimatedComponent;
		var rightItemAnimatedComponent 	: CAnimatedComponent;
		var inv 						: CInventoryComponent;
		var itemId 						: SItemUniqueId;
		
		leftItem = NULL;
		rightItem = NULL;
		
		if ( infantInHand )
		{
			GetNPC().RaiseEvent('ScaredWithInfant');
		}
		
		else if ( catOnLap )
		{
			
		}
		else
		{
			inv = GetNPC().GetInventory();
			itemId = inv.GetItemFromSlot( 'l_weapon' );
			if ( inv.IsIdValid(itemId) )
			{
				leftItem = (CDrawableComponent)((inv.GetItemEntityUnsafe(itemId)).GetMeshComponent());
				if ( leftItem )
					leftItem.SetVisible(false);
			}
			itemId = inv.GetItemFromSlot( 'r_weapon' );
			if ( inv.IsIdValid(itemId) )
			{
				rightItem = (CDrawableComponent)((inv.GetItemEntityUnsafe(itemId)).GetMeshComponent());
				if ( rightItem )
					rightItem.SetVisible(false);
			}
			
			GetNPC().RaiseEvent('ScaredWhileSitting');
		}
		
		GetNPC().SignalGameplayEvent( 'AI_PauseWorkAnimation' );
		
		GetNPC().GetMovingAgentComponent().SetUseExtractedMotion(false);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( leftItem )
			leftItem.SetVisible(true);
		if ( rightItem )
			rightItem.SetVisible(true);
		if ( entity )
			entity.Destroy();
		GetNPC().RaiseEvent('ScaredOverlayEnd');
		GetNPC().SignalGameplayEvent( 'AI_UnPauseWorkAnimation' );
		
		GetNPC().GetMovingAgentComponent().SetUseExtractedMotion(true);
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AI_ShouldBeScaredOnOverlay' )
		{
			if ( IsAvailable() )
				SetEventRetvalInt( 1 );
		}
		return false;
	}
}

class CBTTaskScaredWhileSittingDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskScaredWhileSitting';
	
	function InitializeEvents()
	{
		listenToGameplayEvents.PushBack( 'AI_ShouldBeScaredOnOverlay' );
	}
}



class CBTCondIsSittingInInterior extends CBTTaskShouldBeScaredOnOverlay
{
	function IsAvailable() : bool
	{
		return ShouldBeScaredOnOverlay();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsSittingInInteriorDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsSittingInInterior';
}