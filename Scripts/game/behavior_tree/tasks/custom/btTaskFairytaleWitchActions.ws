/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFairytaleWitchActions extends IBehTreeTask
{
	private var action : EFairytaleWitchAction;
	private var npc : CNewNPC;

	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		Execute();
		
		return BTNS_Active;
	}
	
	private function Execute()
	{
		switch( action )
		{
			case EFWA_GoBackToFlight:
			{
				SetBroomAsVisible();
				npc.AddAbility( 'FairytaleWitchDelay', false );
				
				
				
				
				break;
			}
			
			default:
			{
				break;
			}
		}
	}
	
	private function SetBroomAsVisible()
	{
		var broom : SItemUniqueId;
		var broomEntity : CEntity;
		var drawableComp : CDrawableComponent;

		broom = npc.GetInventory().GetItemFromSlot( 'broom_slot' );
		broomEntity = npc.GetInventory().GetItemEntityUnsafe( broom );
		if( broomEntity )
		{
			drawableComp = (CDrawableComponent)broomEntity.GetComponentByClassName( 'CDrawableComponent' );
			if( drawableComp )
			{
				drawableComp.SetVisible( true );
			}
		}
	}
}

class CBTTaskFairytaleWitchActionsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFairytaleWitchActions';
	
	editable var action : EFairytaleWitchAction;
}

enum EFairytaleWitchAction
{
	EFWA_GoBackToFlight
};