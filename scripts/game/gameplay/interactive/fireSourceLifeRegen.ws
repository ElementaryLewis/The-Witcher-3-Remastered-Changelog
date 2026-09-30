/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FireSourceLifeRegen extends W3FireSource
{
	private var healthRegenOn : bool;
		
 		
 	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		if ( !glComponent )
		{
			glComponent = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		}
		
		if ( glComponent)
		{
			AddTimer('LifeRegenUpdate', 1.0f, true );
			if ( glComponent.IsLightOn())
			{
				ApplyEffects( thePlayer );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if ( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		RemoveTimer('LifeRegenUpdate');
		RemoveEffects( thePlayer );
	}

	timer function LifeRegenUpdate( deltaTime : float, id: int )
	{
		if ( glComponent.IsLightOn() && !healthRegenOn )
		{
			ApplyEffects(thePlayer);
		}
		if ( !glComponent.IsLightOn() && healthRegenOn )
		{
			RemoveEffects(thePlayer);
		}
	}
	private function ApplyEffects( target : CActor )
	{
		healthRegenOn = true;
		target.AddAbility( 'BoostedVitalityRegenExt', false );
	}
	
	private function RemoveEffects( target : CActor )
	{
		healthRegenOn = false;
		target.RemoveAbility( 'BoostedVitalityRegenExt' );
	}

}