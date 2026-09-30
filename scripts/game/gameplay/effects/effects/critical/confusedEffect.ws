/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ConfuseEffectCustomParams extends W3BuffCustomParams
{
	var criticalHitChanceBonus : float;
}

class W3ConfuseEffect extends W3CriticalEffect
{
	private saved var drainStaminaOnExit : bool;
	private var criticalHitBonus : float;

	default criticalStateType 	= ECST_Confusion;
	default effectType 			= EET_Confusion;
	default resistStat 			= CDS_WillRes;
	default drainStaminaOnExit 	= false;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
		
	public function GetCriticalHitChanceBonus() : float
	{
		return criticalHitBonus;
	}
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3ConfuseEffectCustomParams;
		var npc : CNewNPC;
		
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer)
		{
			thePlayer.HardLockToTarget( false );
		}
		
		
		params = (W3ConfuseEffectCustomParams)customParams;
		if(params)
		{
			criticalHitBonus = params.criticalHitChanceBonus;
		}
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			
			npc.LowerGuard();
			
			if (npc.IsHorse())
			{
				if( npc.GetHorseComponent().IsDismounted() )
					npc.GetHorseComponent().ResetPanic();
				
				if ( IsSignEffect() &&  npc.IsHorse() )
				{
					npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
					npc.SignalGameplayEvent('NoticedObjectReevaluation');
				}
			}
		}
	}
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Signs);
		blockedActions.PushBack(EIAB_DrawWeapon);
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
		
		
		
	}
		
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
		}
		
		if (npc && npc.IsHorse())
			npc.SignalGameplayEvent('WasCharmed');
			
		if(drainStaminaOnExit)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
	}
	
	public function SetDrainStaminaOnExit()
	{
		drainStaminaOnExit = true;
	}
}