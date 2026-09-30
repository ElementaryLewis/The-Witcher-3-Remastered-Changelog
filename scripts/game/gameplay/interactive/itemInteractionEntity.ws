/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CItemInteractionEntity extends CGameplayEntity
{
	var itemId 																				: SItemUniqueId;

	
	event OnInteraction( actionName : string, activator : CEntity )
	{

	}
	
	public function TurnOffAndDestroy ( shouldTurnOff : bool, shouldDestroy : bool )
	{
		var interactionComponent : CInteractionComponent;

		interactionComponent = (CInteractionComponent)GetComponent( 'CInteractionComponent0' );
		if ( interactionComponent )
		{
			interactionComponent.isEnabled = !shouldTurnOff;
		}
		
		if ( shouldDestroy )
		{
			this.DestroyAfter( 0.5f );
		}
	}
}