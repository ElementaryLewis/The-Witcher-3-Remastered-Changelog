/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Ragdoll extends W3CriticalEffect
{
	default effectType 					= EET_Ragdoll;
	default criticalStateType 			= ECST_Ragdoll;
	default postponeHandling 			= ECH_Abort;
	default airHandling 				= ECH_HandleNow;
	default attachedHandling 			= ECH_Abort;
	default onHorseHandling 			= ECH_Abort;
	default canBeAppliedOnDeadTarget 	= true;
	default	explorationStateHandling	= ECH_HandleNow;
	default usesFullBodyAnim			= true;
	
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
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
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
	
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var mac : CMovingPhysicalAgentComponent;
		var isInAir : bool;
		
		if ( isActive )
		{
			timeActive += deltaTime;
		}
		
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
		}
		
		if(timeLeft <= 0)
		{
			if(!timeEndedHandled)
			{
				timeEndedHandled = true;				
				
				
				if(isActive && this == target.GetCurrentlyAnimatedCS())
				{				
					target.RequestCriticalAnimStop(target.IsInAir());
				}
				else
				{
					LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
					isActive = false;			
				}
			}
			else if(isActive)
			{
				isInAir = target.IsInAir();
				target.RequestCriticalAnimStop(isInAir);
				isActive = isInAir;
			}
		}
	}
}