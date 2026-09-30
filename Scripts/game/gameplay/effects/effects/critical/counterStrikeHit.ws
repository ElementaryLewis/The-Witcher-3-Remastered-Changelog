/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_CounterStrikeHit extends W3CriticalEffect
{
	default criticalStateType		= ECST_CounterStrikeHit;
	default effectType 				= EET_CounterStrikeHit;
	default isDestroyedOnInterrupt 	= true;
	default postponeHandling 		= ECH_Abort;
	default airHandling 			= ECH_Abort;
	default attachedHandling 		= ECH_Abort;
	default onHorseHandling 		= ECH_Abort;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Signs);
		blockedActions.PushBack(EIAB_DrawWeapon);
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Movement);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var actor : CActor;
		
		super.OnEffectAdded(customParams);
				
		if (isOnPlayer && !thePlayer.IsUsingVehicle() )
		{
			actor = (CActor)EntityHandleGet(creatorHandle);
			if(actor)
				thePlayer.SetCustomRotation( 'Stagger',  VecHeading( actor.GetWorldPosition() - thePlayer.GetWorldPosition() ), 0.0f, 0.2f, false );
		}
	}	
}