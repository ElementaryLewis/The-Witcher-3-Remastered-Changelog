/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_LynxSetBonus extends CBaseGameplayEffect
{
	default effectType = EET_LynxSetBonus;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var inv			: CInventoryComponent;
		var swEnt		: CItemEntity;
		
		inv = target.GetInventory();
		
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) ) 
		{
			swEnt.PlayEffect( 'fast_attack_buff' );
		}
		
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectRemoved()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.PlayEffectSingle( 'fast_attack_buff_hit' );			
			swEnt.StopEffect( 'fast_attack_buff' );
		}
		
		super.OnEffectRemoved();
	}
	
	protected function OnPaused()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.StopEffect( 'fast_attack_buff' );
		}
		
		super.OnPaused();
	}
	
	protected function OnResumed()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.PlayEffect( 'fast_attack_buff' );
		}
	
		super.OnResumed();
	}
	
};