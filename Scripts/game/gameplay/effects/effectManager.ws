/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3EffectManager
{
	private var owner : CActor;											
	private saved var effects : array< CBaseGameplayEffect >;			
	private saved var statDeltas : array<float>;						
	private saved var cachedDamages : array<SEffectCachedDamage>;		
	private var isReady : bool;											
	private saved var currentlyAnimatedCS : CBaseGameplayEffect;		
	private var currentlyPlayedFX : array<SCurrentBuffFX>;				
	private saved var pausedEffects : array<STemporarilyPausedEffect>;	
	private saved var pausedNotAppliedAutoBuffs : array<SPausedAutoEffect>;	
	private var ownerIsWitcher : bool;									
	private var isInitializingAutobuffs : bool;							
	private var hasCriticalStateSaveLock : bool;						
	private var criticalStateSaveLockId : int;							
	
	private var vitalityAutoRegenOn 		: bool;		default vitalityAutoRegenOn 		= false;
	private var essenceAutoRegenOn 			: bool;		default essenceAutoRegenOn 			= false;
	private var staminaAutoRegenOn 			: bool;		default staminaAutoRegenOn 			= false;
	private var moraleAutoRegenOn 			: bool;		default moraleAutoRegenOn 			= false;
	private var panicAutoRegenOn			: bool;		default panicAutoRegenOn			= false;
	private var airAutoRegenOn				: bool;		default airAutoRegenOn				= false;
	private var swimmingStaminaAutoRegenOn	: bool;		default swimmingStaminaAutoRegenOn	= false;
	private var adrenalineAutoRegenOn		: bool;		default adrenalineAutoRegenOn		= false;
	
		default isReady = false;
		default isInitializingAutobuffs = false;
		
	
	
	public final function Initialize( actor : CActor )
	{
		var i : int;
		var effect : CBaseGameplayEffect;
		var overridenEffectsIdxs : array<int>;
		var autoEffects : array<name>;
		var type : EEffectType;
		var tmpName : name;
		var npc : CNewNPC;

		owner = actor;
		ownerIsWitcher = (W3PlayerWitcher)owner;
		hasCriticalStateSaveLock = false;
		statDeltas.Grow(EnumGetMax('EBaseCharacterStats')+1);
		for(i=0; i<statDeltas.Size(); i+=1)
			statDeltas[i] = 0;
		
		
		npc = (CNewNPC)actor;
		if( npc )
		{
			if( npc.GetNPCType() != ENGT_Commoner )
			{
				autoEffects = PrepareAutoBuffs();
			}
		}
		else if ( (CR4Player)actor )
			autoEffects = PrepareAutoBuffs();
		
		FilterOutExactly( autoEffects, EET_AutoVitalityRegen );
		FilterOutExactly( autoEffects, EET_AutoEssenceRegen );
		FilterOutExactly( autoEffects, EET_AutoStaminaRegen );
		FilterOutExactly( autoEffects, EET_AutoMoraleRegen );
		FilterOutExactly( autoEffects, EET_AutoPanicRegen );
		FilterOutExactly( autoEffects, EET_AutoAirRegen );
		FilterOutExactly( autoEffects, EET_AutoSwimmingStaminaRegen );
		FilterOutExactly( autoEffects, EET_AdrenalineDrain );
		
		
		if(autoEffects.Size() > 0 && !theGame.IsEffectManagerInitialized())
			theGame.InitializeEffectManager();
		
		isInitializingAutobuffs = true;
		for(i=0; i<autoEffects.Size(); i+=1)
		{
			EffectNameToType(autoEffects[i], type, tmpName);
			InternalAddEffect(type,owner,'autobuff');			
		}
		isInitializingAutobuffs = false;
				
		isReady = true;
	}
	
	
	public final function PerformUpdate(deltaTime : float)
	{
		var i, size : int;
		var delta : float;
		var action : W3DamageAction;
		var wasPaused : bool;
		var carrier, pausedBuff : CBaseGameplayEffect;
		var cachedDeltaRemoved : bool;
			
		
		size = effects.Size();		
		for(i=size-1; i>=0; i -= 1 )
		{
			
			if( effects[ i ].IsPausedDuringDialogAndCutscene() )
			{
				if( theGame.IsDialogOrCutscenePlaying() && !effects[i].IsPaused('dialogOrCutscene'))
				{
					if(IsCriticalEffect(effects[i]))
						RemoveEffect(effects[i], true);
					else
						effects[i].Pause( 'dialogOrCutscene', true );
				}
				else if( !theGame.IsDialogOrCutscenePlaying() && effects[i].IsPaused('dialogOrCutscene'))
				{
					effects[i].Resume( 'dialogOrCutscene' );
				}
			}
		
			
			if( effects[i].IsPaused() )
			{
				continue;
			}
				
			
			if(effects[i].IsActive())
			{
				effects[i].OnTimeUpdated(deltaTime);		
			}
			else
			{
				RemoveEffectOnIndex( i );
			}
		}

		
		
		
		
		
		
		
		
		size = statDeltas.Size();
		cachedDeltaRemoved = false;
		for(i=0; i<size; i+=1)
		{
			delta = statDeltas[i];
			if(delta == 0)
			{
				continue;
			}
			else
			{
				UpdateStatValueChange(i, delta);				
				statDeltas[i] = 0;	
				cachedDeltaRemoved = true;
				
				if(i == BCS_Vitality || i == BCS_Essence)
					owner.ShowFloatingValue(EFVT_Heal, delta, true);
			}
		}
				
		
		size = cachedDamages.Size();
		if( size > 0 )
		{
			action = new W3DamageAction in theGame.damageMgr;
			
			for(i=0; i<size; i+=1)
			{
				action.Initialize( (CGameplayEntity)EntityHandleGet(cachedDamages[i].attacker), owner, cachedDamages[i].carrier, cachedDamages[i].sourceName, EHRT_None, cachedDamages[i].powerStatType, false, false, false, cachedDamages[i].isEnvironment);
				action.AddDamage(cachedDamages[i].dmgType, cachedDamages[i].dmgVal);
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				if(cachedDamages[i].dt > 0)
				{
					action.SetPointResistIgnored(true);
					action.SetIsDoTDamage(cachedDamages[i].dt);
				}
				
				if(cachedDamages[i].dontShowHitParticle)
				{
					action.SetCanPlayHitParticle(false);
				}
				
				theGame.damageMgr.ProcessAction(action);

				
				carrier = cachedDamages[i].carrier;
				if(carrier && carrier.GetEffectType() == EET_Bleeding)
				{
					((W3Effect_Bleeding)carrier).OnDamageDealt( action.DealsAnyDamage() );	
				}
				
				
				if(carrier && carrier.GetEffectType() == EET_Bleeding1)
				{
					((W3Effect_Bleeding1)carrier).OnDamageDealt( action.DealsAnyDamage() );	
				}
				if(carrier && carrier.GetEffectType() == EET_Bleeding2)
				{
					((W3Effect_Bleeding2)carrier).OnDamageDealt( action.DealsAnyDamage() );	
				}
				if(carrier && carrier.GetEffectType() == EET_Bleeding3)
				{
					((W3Effect_Bleeding3)carrier).OnDamageDealt( action.DealsAnyDamage() );	
				}
				
			}

			delete action;
			cachedDamages.Clear();
			owner.SetEffectsUpdateTicking( false ); 
		}
		
		
		for(i=pausedEffects.Size()-1; i>=0; i-=1)
		{
			if(pausedEffects[i].timeLeft > -1)
			{
				pausedEffects[i].timeLeft -= deltaTime;
				if(pausedEffects[i].timeLeft <= 0)
				{
					pausedEffects[i].buff.Resume(pausedEffects[i].source);
					pausedEffects.Erase(i);
				}
			}
		}
		
		
		for(i=pausedNotAppliedAutoBuffs.Size()-1; i>=0; i-=1)
		{
			if(pausedNotAppliedAutoBuffs[i].timeLeft > -1)
			{
				pausedNotAppliedAutoBuffs[i].timeLeft -= deltaTime;
				if(pausedNotAppliedAutoBuffs[i].timeLeft <= 0)
				{
					pausedNotAppliedAutoBuffs.Erase(i);
				}
			}
		}
		
		
		owner.SetEffectsUpdateTicking( false );
	}
	
	
	private final function PrepareAutoBuffs() : array<name>
	{
		var autoEffects : array<name>;
		
		
		owner.GetAutoEffects(autoEffects);
		
		
		
		FilterAutoBuff(autoEffects, CRS_Vitality, EET_AutoVitalityRegen);
		FilterAutoBuff(autoEffects, CRS_Essence, EET_AutoEssenceRegen);
		FilterAutoBuff(autoEffects, CRS_Stamina, EET_AutoStaminaRegen);
		FilterAutoBuff(autoEffects, CRS_Morale, EET_AutoMoraleRegen);
		
		return autoEffects;
	}
	
	
	
	private final function FilterAutoBuff(out autoEffects : array<name>, regenStat : ECharacterRegenStats, effectType : EEffectType)
	{
		var autoName : name;
		var effectValue, null : SAbilityAttributeValue;
		
		effectValue = owner.GetAttributeValue( RegenStatEnumToName(regenStat) );	
		autoName = EffectTypeToName(effectType);		
		
		if(!autoEffects.Contains(autoName) && effectValue != null)
		{
			autoEffects.PushBack(autoName);
		}
		else if(autoEffects.Contains(autoName) && effectValue == null)
		{
			autoEffects.Remove(autoName);
		}
	}
	
	private final function FilterOutAllApart( out autoEffects : array< name >, effectType : EEffectType )
	{
		var i			: int;
		var autoName 	: name;

		autoName = EffectTypeToName(effectType);
		for( i = autoEffects.Size()-1; i >= 0; i -= 1 )
		{
			if( autoEffects[ i ] != autoName )
			{
				autoEffects.Erase( i );
			}
		}
	}
	
	private final function FilterOutExactly( out autoEffects : array< name >, effectType : EEffectType )
	{
		var i			: int;
		var autoName 	: name;

		autoName = EffectTypeToName( effectType );
		for( i = autoEffects.Size()-1; i >= 0; i -= 1 )
		{
			if( autoEffects[ i ] == autoName )
			{
				autoEffects.Erase( i );
			}
		}
	}
	
	public final function StartVitalityRegen() : bool
	{
		if( vitalityAutoRegenOn )
		{
			return false;
		}
		
		vitalityAutoRegenOn = StartRegenInternal( CRS_Vitality, EET_AutoVitalityRegen );
		return vitalityAutoRegenOn;
	}
	
	public final function StopVitalityRegen()
	{
		if( !vitalityAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoVitalityRegen );
		vitalityAutoRegenOn = false;
	}
	
	public final function StartEssenceRegen() : bool
	{
		if( essenceAutoRegenOn )
		{
			return false;
		}
		
		essenceAutoRegenOn = StartRegenInternal( CRS_Essence, EET_AutoEssenceRegen );
		return essenceAutoRegenOn;
	}
	
	public final function StopEssenceRegen()
	{
		if( !essenceAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoEssenceRegen );
		essenceAutoRegenOn = false;
	}
	
	public final function StartStaminaRegen() : bool
	{
		if( staminaAutoRegenOn )
		{
			return false;
		}
		
		staminaAutoRegenOn = StartRegenInternal( CRS_Stamina, EET_AutoStaminaRegen );
		return staminaAutoRegenOn;
	}
	
	public final function StopStaminaRegen()
	{
		if( !staminaAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoStaminaRegen );
		staminaAutoRegenOn = false;
	}
	
	public final function StartMoraleRegen() : bool
	{
		if( moraleAutoRegenOn )
		{
			return false;
		}
		
		moraleAutoRegenOn = StartRegenInternal( CRS_Morale, EET_AutoMoraleRegen );
		return moraleAutoRegenOn;
	}
	
	public final function StopMoraleRegen()
	{
		if( !moraleAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoMoraleRegen );
		moraleAutoRegenOn = false;
	}
	
	public final function StartPanicRegen() : bool
	{
		if( panicAutoRegenOn )
		{
			return false;
		}
		
		panicAutoRegenOn = StartRegenInternal( CRS_Panic, EET_AutoPanicRegen );
		return panicAutoRegenOn;
	}
	
	public final function StopPanicRegen()
	{
		if( !panicAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoPanicRegen );
		panicAutoRegenOn = false;
	}
	
	public final function StartAirRegen() : bool
	{
		if( airAutoRegenOn )
		{
			return false;
		}
		
		airAutoRegenOn = StartRegenInternal( CRS_Air, EET_AutoAirRegen );
		return airAutoRegenOn;
	}
	
	public final function StopAirRegen()
	{
		if( !airAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoAirRegen );
		airAutoRegenOn = false;
	}
	
	public final function StartSwimmingStaminaRegen() : bool
	{
		if( swimmingStaminaAutoRegenOn )
		{
			return false;
		}
		
		swimmingStaminaAutoRegenOn = StartRegenInternal( CRS_SwimmingStamina, EET_AutoSwimmingStaminaRegen );
		return airAutoRegenOn;
	}
	
	public final function StopSwimmingStaminaRegen()
	{
		if( !airAutoRegenOn )
		{
			return;
		}
		
		StopRegenInternal( EET_AutoSwimmingStaminaRegen );
		airAutoRegenOn = false;
	}
	
	private final function StopRegenInternal( effectType : EEffectType )
	{
		var effect : CBaseGameplayEffect;
		effect = GetEffect( effectType );
		RemoveEffect( effect, true );
	}
	
	private final function StartRegenInternal( regenStat : ECharacterRegenStats, effectType : EEffectType ) : bool
	{
		var autoEffects 	: array<name>;
		var npc 			: CNewNPC;
		var i 				: int;
		var addResult		: EEffectInteract;
		
		npc = (CNewNPC)owner;
		if( ( npc && ( npc.GetNPCType() == ENGT_Commoner ) ) || ( !npc && !( (CR4Player )owner ) ) )
		{
			return false;
		}
		
		owner.GetAutoEffects( autoEffects );
		FilterOutAllApart( autoEffects, effectType );
		
		if( regenStat != CRS_UNUSED )
		{
			FilterAutoBuff( autoEffects, regenStat, effectType );
		}
		
		if( autoEffects.Size() > 0 )
		{
			addResult = InternalAddEffect( effectType, owner, 'autobuff' );
			
			if(addResult == EI_Pass)
			{
				return true;		
			}
			else if(addResult == EI_Cumulate)
			{
				owner.SetEffectsUpdateTicking(true);
				return true;
			}				
		}
		
		return false;
	}
	
	
	public final function OnLoad(own : CActor)
	{
		var i : int;
		
		owner = own;
		hasCriticalStateSaveLock = false;
		ownerIsWitcher = (W3PlayerWitcher)owner;
		for(i=0; i<effects.Size(); i+=1)
			effects[i].OnLoad(owner, this);
			
		
		staminaAutoRegenOn = false;		
		essenceAutoRegenOn = false;		
		staminaAutoRegenOn = false;		
		moraleAutoRegenOn = false;		
		panicAutoRegenOn = false;		
		airAutoRegenOn = false;		
		swimmingStaminaAutoRegenOn = false;		
		adrenalineAutoRegenOn = false;		
				
		
		owner.SetEffectsUpdateTicking(true);
		isReady = true;
	}
	
	public final function IsReady() : bool {return isReady;}		
	public final function GetCurrentlyAnimatedCS() : CBaseGameplayEffect			{return currentlyAnimatedCS;}
	public final function SetCurrentlyAnimatedCS(buff : CBaseGameplayEffect)
	{
		if(owner == thePlayer)
			LogCriticalPlayer("** EffectManager.SetCurrentlyAnimatedCS() - current is now <<" + buff + ">>");
			
		if(!buff)
			Log("");
			
		currentlyAnimatedCS = buff;
	}
	
	
	public final function GetCurrentEffects(optional type : EEffectType, optional sourceName : string, optional partialSourceNameSearch : bool) : array< CBaseGameplayEffect >
	{
		var i : int;
		var ret : array< CBaseGameplayEffect >;
		var buffOk, sourceNameSet : bool;
		
		sourceNameSet = (sourceName != "" && sourceName != "None" && sourceName != "none");
		
		if(type == EET_Undefined && !sourceNameSet)
			return effects;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			
			if(effects[i])
			{
				buffOk = true;
				
				
				if(type != EET_Undefined)
				{
					if(type != effects[i].GetEffectType())
						buffOk = false;
				}
				
				if(buffOk)
				{
					if(partialSourceNameSearch)
					{
						buffOk = (StrFindFirst(effects[i].GetSourceName(), sourceName) != -1);
					}
					else
					{
						if(!sourceNameSet)
						{
							buffOk = true;
						}	
						else
						{
							buffOk = (effects[i].GetSourceName() == sourceName);
						} 
					}
					
					if(buffOk)
						ret.PushBack(effects[i]);
				}
			}
		}
		
		return ret;
	}
			
	
	private final function ApplyEffect( effect : CBaseGameplayEffect, overridenEffectsIdxs : array<int>, cumulateIdx : int, customParams : W3BuffCustomParams) : EEffectInteract
	{
		var i, size : int;		
		var effectType : EEffectType;
		
		
		size = overridenEffectsIdxs.Size();
		for(i=size-1; i>=0; i-=1)
		{
			RemoveEffectOnIndex( overridenEffectsIdxs[ i ], true );
		}
		
		
		if(cumulateIdx >= 0)
		{
			effects[cumulateIdx].CumulateWith(effect);
			delete effect;
			return EI_Cumulate;
		}
		
		else
		{
			effect.OnEffectAdded(customParams);
						
			
			if(!effect.IsActive())
			{
				LogAssert(false, "W3EffectManager.ApplyEffect: effect <<" + effect + ">> did not add properly (is inactive just after added) to <<" + owner + ">> and is removed!");
				effect.OnEffectRemoved();
				return EI_Undefined;
			}
			
			
			effectType = effect.GetEffectType();
			if(pausedNotAppliedAutoBuffs.Size() > 0 && IsBuffAutoBuff(effectType))
			{			
				for(i=pausedNotAppliedAutoBuffs.Size()-1; i>=0; i-=1)
				{
					if(pausedNotAppliedAutoBuffs[i].effectType == effectType)
					{
						PauseEffect(effect, pausedNotAppliedAutoBuffs[i].sourceName, pausedNotAppliedAutoBuffs[i].singleLock, pausedNotAppliedAutoBuffs[i].duration, pausedNotAppliedAutoBuffs[i].useMaxDuration);
						pausedNotAppliedAutoBuffs.EraseFast(i);
					}
				}
			}
			
			effects.PushBack( effect );
			owner.SetEffectsUpdateTicking( true, isInitializingAutobuffs );			
			OnBuffAdded(effect);
			
			effect.OnEffectAddedPost();
			
			
			if(size > 0)
				return EI_Override;
			else
				return EI_Pass;
		}
	}
	
	
	private final function OnBuffRemoved()
	{
		if(hasCriticalStateSaveLock && GetCriticalBuffsCount() == 0)
		{
			theGame.ReleaseNoSaveLock(criticalStateSaveLockId);
			hasCriticalStateSaveLock = false;
		}
	}
	
	
	private final function OnBuffAdded(effect : CBaseGameplayEffect)
	{
		var signEffects : array < CBaseGameplayEffect >;
		var npcOwner : CNewNPC;
		var mutagen : W3Mutagen13_Effect;
		var i, doneBuffs : int;
		var effectType : EEffectType;
		
		effectType = effect.GetEffectType();
		
		if(!hasCriticalStateSaveLock && owner == thePlayer && IsCriticalEffectType(effectType) )
		{
			 theGame.CreateNoSaveLock("critical_state", criticalStateSaveLockId);
			 hasCriticalStateSaveLock = true;
		}
		
		
		npcOwner = (CNewNPC)owner;
		if(npcOwner && (effectType == EET_Burning || effectType == EET_Bleeding || effectType == EET_Poison || effectType == EET_PoisonCritical) && !npcOwner.WasBurnedBleedingPoisoned())
		{
			if( owner.HasBuff(EET_Burning) && owner.HasBuff(EET_Bleeding) && (owner.HasBuff(EET_Poison) || owner.HasBuff(EET_PoisonCritical)) )
			{
				theGame.GetGamerProfile().IncStat(ES_BleedingBurnedPoisoned);
				npcOwner.SetBleedBurnPoison();
			}
		}
		
		
		if(owner == thePlayer && IsBuffShrine(effectType))
		{
			doneBuffs = CountShrineBuffs();
			if (doneBuffs >= 5) 
			{
				theGame.GetGamerProfile().AddAchievement(EA_PowerOverwhelming);
			}
			else
			{
				theGame.GetGamerProfile().NoticeAchievementProgress(EA_PowerOverwhelming, doneBuffs);
			}
		}
		
		
		mutagen = (W3Mutagen13_Effect)owner.GetBuff(EET_Mutagen13);
		if(mutagen && mutagen.IsEffectTypeAffected(effectType))
		{					
			effect.SetTimeLeft(mutagen.GetForcedDuration());
		}		
	}
	
	
	public final function UpdateLocalBuffsArray(out localArray : array<CBaseGameplayEffect>)
	{
		var i : int;
		
		for(i=localArray.Size()-1; i>=0; i-=1)
			if(!effects.Contains(localArray[i]))
				localArray.Erase(i);
	}
			
	public final function AddEffectCustom(params : SCustomEffectParams) : EEffectInteract
	{
		return InternalAddEffect(
			params.effectType,
			params.creator,
			params.sourceName,
			params.duration,
			params.effectValue,
			params.customAbilityName,
			params.customFXName,
			params.isSignEffect,
			params.customPowerStatValue,
			params.buffSpecificParams,
			params.vibratePadLowFreq,
			params.vibratePadHighFreq
		);
	}
	
	
	public final function AddEffectDefault(effectType : EEffectType, creat : CGameplayEntity, optional srcName : string, optional signEffect : bool) : EEffectInteract
	{
		var none : SAbilityAttributeValue;
		var noneParams : W3BuffCustomParams;
		
		return InternalAddEffect(effectType, creat, srcName, 0, none, '', '', signEffect, none, noneParams);
	}
	
	
	private final function InternalAddEffect(effectType : EEffectType, creat : CGameplayEntity, srcName : string, optional inDuration : float, optional customVal : SAbilityAttributeValue, optional customAbilityName : name, optional customFXName : name, optional signEffect : bool, optional powerStatValue : SAbilityAttributeValue, optional customParams : W3BuffCustomParams, optional vibratePadLowFreq : float, optional vibratePadHighFreq : float) : EEffectInteract
	{
		var effect : CBaseGameplayEffect;
		var overridenEffectsIdxs : array<int>;
		var cumulateIdx, i : int;
		var npc : CNewNPC;
		var actorCreator : CActor;
		var action : W3DamageAction;
		var hasQuen : bool;
		var damages : array<SRawDamage>;
		var forceOnNpc : bool;
		var npcStorage : CBaseAICombatStorage;
		
		
		var j, focus : int;
		var woundsAll : array<EEffectType>;
		var woundsToAdd : array<EEffectType>;
		
		
		if(effectType == EET_Undefined)
		{
			LogAssert(false, "EffectManager.AddEffectByType: trying to add effect of undefined type!");
			return EI_Undefined;
		}
		
		
		if(effectType == EET_Burning)
		{
			if( ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).GetSubmergeDepth() <= -1)
			{
				LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get burning effect since it's underwater!");
				return EI_Deny;
			}
		}		
		
		else if( effectType == EET_Frozen )
		{
			npc = (CNewNPC)owner;
			if ( npc )
			{
				npcStorage = (CBaseAICombatStorage)npc.GetScriptStorageObject('CombatData');
				if ( npc.IsFlying() )
				{
					LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get frozen effect since it's currently flying!");
					return EI_Deny;
				}
				else if ( npcStorage.GetIsInImportantAnim() )
				{
					LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get frozen effect since it's in an uninterruptable animation!");
					return EI_Deny;
				}
			}
		}
		
		
		if( owner == thePlayer && thePlayer.HasBuff( EET_Mutagen08 ) )
		{
			if( effectType == EET_Knockdown )
			{
				LogEffects( "EffectManager.InternalAddEffect: changing EET_Knockdown to EET_Stagger due to Mutagen 8 in effect" );
				effectType = EET_Stagger;
			}
			else if( effectType == EET_LongStagger || effectType == EET_Stagger )
			{
				LogEffects( "EffectManager.InternalAddEffect: denying " + effectType + " due to Mutagen 8 in effect" );
				return EI_Deny;
			}
		}
		
		
		if( ((W3PlayerWitcher)owner) && GetWitcherPlayer().IsAnyQuenActive())
		{
			hasQuen = true;
			
			if(effectType == EET_Stagger || effectType == EET_LongStagger || effectType == EET_CounterStrikeHit)
			{
				GetWitcherPlayer().FinishQuen(false);
				LogEffects("EffectManager.InternalAddEffect: Geralt has active quen so it breaks and we don't stagger.");
				return EI_Deny;
			}
		}
		
		
		
		
		if( owner == thePlayer && effectType == EET_HeavyKnockdown )
		{
			LogEffects( "EffectManager.InternalAddEffect: changing EET_HeavyKnockdown to EET_Knockdown, general rule for player character" );
			effectType = EET_Knockdown;
		}
		
		
		if(srcName == "" && creat)
			srcName = creat.GetName();
		
		
		
		if( effectType == EET_Bleeding && (CNewNPC)owner && GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ) )
		{
			focus = (int) thePlayer.GetStat(BCS_Focus);
			
			woundsAll.PushBack( EET_Bleeding1 );
			woundsAll.PushBack( EET_Bleeding2 );
			woundsAll.PushBack( EET_Bleeding3 );
			
			if( !owner.HasBuff( EET_Bleeding ) )
			{
				
			}
			else
			{
				woundsToAdd = woundsAll;
				woundsAll.PushBack( EET_Bleeding );
				
				if( owner.HasBuff( EET_Bleeding1 ) ) { woundsToAdd.Remove( EET_Bleeding1 ); j += 1; }
				if( owner.HasBuff( EET_Bleeding2 ) ) { woundsToAdd.Remove( EET_Bleeding2 ); j += 1; }
				if( owner.HasBuff( EET_Bleeding3 ) ) { woundsToAdd.Remove( EET_Bleeding3 ); j += 1; }
				
				
				if( focus > j )
				{
					effectType = woundsToAdd[ RandRange( woundsToAdd.Size() ) ];
				}
				
				
				
				else
				{
					effectType = woundsAll[ RandRange( focus, 0 ) ];
				}
				
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		if(!owner.IsAlive() && !effect.CanBeAppliedOnDeadTarget())
			return EI_Deny;
			
		actorCreator = (CActor)creat;
		
		
		if ( actorCreator.HasAbility('ForceCriticalEffectsAnim') )
		{
			forceOnNpc = true;
		}
		else if ( actorCreator.HasAbility('ForceCriticalEffectsAnimNPCOnly') && owner != thePlayer )
		{
			forceOnNpc = true;
		}
		
		if ( owner.HasTag('vampire') && effectType == EET_SilverDust )
		{
			forceOnNpc = true;
		}
		
		
		
		if(owner.IsImmuneToBuff(effectType) && !forceOnNpc && (!actorCreator.HasAbility('ForceCriticalEffects') || IsCriticalEffectType(effectType)) )
		{
			LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> is immune to effect of this type (" + effectType + ")");
			return EI_Deny;
		}		
		
		
		if( actorCreator && GetAttitudeBetween( actorCreator, owner ) == AIA_Friendly && creat != owner && IsNegativeEffectType( effectType ) && effectType != EET_Confusion && effectType != EET_AxiiGuardMe )
		{
			LogAssert(false, "EffectManager.InternalAddEffect: unit <<" + owner + ">> is friendly to buff creator: <<" + creat + ">> negative buff cannot be added");
			return EI_Deny;
		}
		
		
		effect = theGame.effectMgr.MakeNewEffect(effectType, creat, owner, this, inDuration, srcName, powerStatValue, customVal, customAbilityName, customFXName, signEffect, vibratePadLowFreq, vibratePadHighFreq);
		
		if(effect)
		{
			if((actorCreator && 
				(((W3PlayerWitcher)owner) && 
				(effectType == EET_Stagger || effectType == EET_LongStagger)) &&
				(StrBeginsWith(actorCreator.GetName(), "q701_giant") || 
					StrBeginsWith(actorCreator.GetName(), "scolopendromorph"))) ||
				(srcName == "debuff_projectile"))
			{
				if(effectType == EET_Stagger)
				{
					theSound.TimedSoundEvent(1.5f, "start_stagger", "stop_stagger");
				}
				else if(effectType == EET_LongStagger)
				{
					theSound.TimedSoundEvent(2.f, "start_stagger", "stop_stagger");
				}
			}
			else if(((W3PlayerWitcher)owner) && actorCreator && (effectType == EET_Stagger || effectType == EET_LongStagger)) 
			{
				theSound.TimedSoundEvent(1.f, "start_small_stagger", "stop_small_stagger");
			}
			
			
			if( (hasQuen || (((W3PlayerWitcher)owner) && FactsQuerySum("player_had_quen") > 0)) && IsDoTEffect(effect))
			{
				FactsRemove("player_had_quen");
				
				if((W3DamageOverTimeEffect)effect)
					damages = ((W3DamageOverTimeEffect)effect).GetDamages();
				else if((W3CriticalDOTEffect)effect)
					damages = ((W3CriticalDOTEffect)effect).GetDamages();
				
				action = new W3DamageAction in theGame;
				action.Initialize(creat, owner, effect, srcName, EHRT_None, CPS_Undefined, false, false, false, true);
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				
				for(i=0; i<damages.Size(); i+=1)
				{
					
					action.AddDamage(damages[i].dmgType, damages[i].dmgVal);
				}
				
				action.SetPointResistIgnored(true);
				action.SetIsDoTDamage(0.1f);
				
				theGame.damageMgr.ProcessAction(action);
				delete action;
				
				LogEffects("EffectManager.InternalAddEffect: applying DoT when having quen: dealing 0.1s of damage and aborting");
				return EI_Deny;
			}
			
			
			if(effect.GetDurationLeft() == 0)
			{
				LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">>: effect <<" + effectType + ">> cannot be added as its final duration is 0.");
				LogEffects("EffectManager.InternalAddEffect: this can be due to high unit's resist, which is " + NoTrailZeros(effect.GetBuffResist()*100) + "%.");
				return EI_Deny;
			}
			
			
			if(signEffect && (effectType == EET_Confusion || effectType == EET_Hypnotized) && creat == thePlayer && thePlayer.CanUseSkill(S_Magic_s17) && thePlayer.GetSkillLevel(S_Magic_s17) == 3 && effect.GetDurationLeft() < CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Magic_s17, 'duration_to_force_stagger', false, true)) )
			{				
				LogEffects("EffectManager.InternalAddEffect: Axii effect is blocked, will be stagger from S_Magic_s17 skill");
				return EI_Deny;
			}
			
			
			if( theGame.effectMgr.CheckInteractionWith(this, effect, effects, overridenEffectsIdxs, cumulateIdx) )
				return ApplyEffect(effect, overridenEffectsIdxs, cumulateIdx, customParams);
			else
				return EI_Deny;
		}
		
		return EI_Undefined;
	}
	
	public final function GetDrunkMutagens( optional sourceName : string ) : array<CBaseGameplayEffect>
	{
		var i : int;
		var ret : array<CBaseGameplayEffect>;
		var mutagen : W3Mutagen_Effect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			mutagen = (W3Mutagen_Effect)effects[i];
			if(mutagen)
			{
				if( sourceName == "" || mutagen.GetSourceName() == sourceName )
				{
					ret.PushBack(mutagen);
				}
			}
		}
		
		return ret;
	}
	
	public final function GetMutagenBuffs() : array< W3Mutagen_Effect >
	{
		var i : int;
		var ret : array< W3Mutagen_Effect >;
		var mutagen : W3Mutagen_Effect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			mutagen = (W3Mutagen_Effect) effects[i];
			if( mutagen )
			{
				ret.PushBack( mutagen );
			}
		}
		
		return ret;
	}
	
	public final function GetPotionBuffs() : array<CBaseGameplayEffect>
	{
		var i : int;
		var ret : array<CBaseGameplayEffect>;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			if(effects[i].IsPotionEffect())
				ret.PushBack(effects[i]);
		}
		
		return ret;
	}
	
	public final function GetPotionBuffsCount() : int
	{
		var i, cnt : int;
		
		cnt = 0;
		for(i=0; i<effects.Size(); i+=1)
		{
			if(effects[i].IsPotionEffect())
				cnt += 1;
		}
		
		return cnt;
	}	
	
	
	public final function GetEffect(effectType : EEffectType, optional sourceName : string) : CBaseGameplayEffect
	{
		var i,size : int;
	
		size = effects.Size();
		for(i=0; i<size; i+=1)
		{
			if(effects[i].GetEffectType() == effectType)
			{
				if(StrLen(sourceName) == 0 || sourceName == effects[i].GetSourceName())
					return effects[i];
			}
		}
		
		return NULL;
	}
	
	
	public final function RemoveEffect(effect : CBaseGameplayEffect, optional csForcedRemove : bool)
	{
		var witcher : W3PlayerWitcher;
		var i : int;
		var autoBuffPause : SPausedAutoEffect;
		var isCritical : bool;
		
		if(!effect || !effects.Contains(effect))
			return;
			
		isCritical = IsCriticalEffect(effect);
		
		if(owner == thePlayer && isCritical)
			LogCriticalPlayer("EffectManager.RemoveEffect() | " + effect + " - forced: " + csForcedRemove);
			
		if(!csForcedRemove && isCritical && currentlyAnimatedCS == effect)
		{				
			if(effect.IsActive())
			{
				
				effect.SetTimeLeft(0);
				return;
			}
		}
		
		
		if(isCritical && effect == owner.GetNewRequestedCS())
			owner.SetNewRequestedCS(NULL);
		
		effects.Remove(effect);
		
		if( effects.Size() == 0 )
		{
			owner.SetEffectsUpdateTicking( false );
		}
		
		effect.OnEffectRemoved();
		OnBuffRemoved();
		
		if(ownerIsWitcher)		
		{
			witcher = GetWitcherPlayer();
			if(witcher.GetSkillBonusPotionEffect() == effect)
				witcher.ClearSkillBonusPotionEffect();
		}		

		if(isCritical && currentlyAnimatedCS == effect)
		{
			owner.RaiseEvent( 'CriticalStateEnded' );

			SetCurrentlyAnimatedCS(NULL);
		}	
		
		
		for(i=pausedEffects.Size()-1; i>=0; i-=1)
		{
			if(pausedEffects[i].buff != effect)
				continue;
				
			if(IsBuffAutoBuff(pausedEffects[i].buff.GetEffectType()))
			{
				
				autoBuffPause.effectType = effect.GetEffectType();
				autoBuffPause.duration = pausedEffects[i].duration;
				autoBuffPause.timeLeft = pausedEffects[i].timeLeft;
				autoBuffPause.sourceName = pausedEffects[i].source;
				autoBuffPause.singleLock = pausedEffects[i].singleLock;
				autoBuffPause.useMaxDuration = pausedEffects[i].useMaxDuration;
				
				pausedNotAppliedAutoBuffs.PushBack(autoBuffPause);
			}
			
			
			pausedEffects.EraseFast(i);
			break;
		}
		
		delete effect;
	}
	
	private final function RemoveEffectOnIndex( index : int , optional csForcedRemove : bool)
	{
		RemoveEffect(effects[index], csForcedRemove);
	}
		
	
	public final function RemoveAllPotionEffects(optional skip : array<CBaseGameplayEffect>)
	{
		var size,i : int;
	
		size = effects.Size();
		for(i=size-1; i>=0; i-=1)
		{
			if(effects[i].IsPotionEffect() && (skip.Size() == 0 || !skip.Contains(effects[i])) )
			{
				RemoveEffectOnIndex( i );
			}
		}
	}
	
	
	public final function RemoveAllEffectsOfType(type : EEffectType, optional forced : bool)
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
		{
			if( effects[i].GetEffectType() == type )
			{
				RemoveEffectOnIndex( i, forced );
			}
		}
	}
	
	public function RemoveAllBuffsWithSource( source : string )
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
		{
			if( effects[i].GetSourceName() == source )
			{
				RemoveEffectOnIndex( i, false );
			}
		}
	}
	
	
	public final function RemoveAllNonAutoEffects( optional removeOils : bool, optional skipPerk14 : bool )
	{
		var autoEffects : array<name>;
		var i : int;
		var type : EEffectType;
		var tmpName : name;
		var autos : array<EEffectType>;
				
		
		owner.GetAutoEffects(autoEffects);
		for(i=0; i<autoEffects.Size(); i+=1)		
		{
			EffectNameToType(autoEffects[i], type, tmpName);
			autos.PushBack(type);
		}
		
		
		if(!autos.Contains(EET_AutoVitalityRegen))
			autos.PushBack(EET_AutoVitalityRegen);
		if(!autos.Contains(EET_AutoStaminaRegen))
			autos.PushBack(EET_AutoStaminaRegen);
		if(!autos.Contains(EET_AutoEssenceRegen))
			autos.PushBack(EET_AutoEssenceRegen);
		if(!autos.Contains(EET_AutoMoraleRegen))
			autos.PushBack(EET_AutoMoraleRegen);
		
		
		for(i=effects.Size()-1; i>=0; i-=1)
		{
			type = effects[i].GetEffectType();
			if(!autos.Contains(type))
			{
				if( removeOils || ! ( (W3Effect_Oil)effects[i] ) )
				{
					
					if( skipPerk14 && (W3PlayerWitcher)owner && GetWitcherPlayer().CanUseSkill( S_Perk_14 ) && (W3Effect_Shrine) effects[i] )
					{
						continue;
					}
					
					RemoveEffectOnIndex( i, true );
				}
			}
		}
	}
	
	
	public final function OwnerHasDied()
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
			effects[i].OnTargetDeath();
	}
	
	public final function OwnerHasEnteredUnconscious()
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
			effects[i].OnTargetUnconscious();
	}
	
	public final function OnOwnerRevived()
	{
		var i : int;
	
		RemoveAllNonAutoEffects();		
		cachedDamages.Clear();
		SetCurrentlyAnimatedCS(NULL);
		
		for(i=0; i<statDeltas.Size(); i+=1)
			statDeltas[i] = 0;
		
		ResumeAllBuffsForced();
		
		
		vitalityAutoRegenOn = false;
		essenceAutoRegenOn 			= false;
		staminaAutoRegenOn 			= false;
		moraleAutoRegenOn 			= false;
		panicAutoRegenOn			= false;
		airAutoRegenOn				= false;
		swimmingStaminaAutoRegenOn	= false;
		adrenalineAutoRegenOn		= false;
	
		StartStaminaRegen();
		StartVitalityRegen();
		StartEssenceRegen();
		StartMoraleRegen();
		StartPanicRegen();
		StartAirRegen();
		StartSwimmingStaminaRegen();
	}
	
	
	public final function OwnerHasFinishedDeathAnim()
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
			effects[i].OnTargetDeathAnimFinished();
	}
		
	private final function UpdateStatValueChange(stat : EBaseCharacterStats, val : float)
	{
		var playerOwner : CR4Player;
	
		if(val > 0)
		{
			owner.GainStat(stat, val);
			return;
		}
		else if (val == 0)
		{
			return;
		}
		
		val = -val;
		playerOwner = (CR4Player)owner;
		
		switch(stat)
		{
			case BCS_Stamina :
				owner.DrainStamina(ESAT_FixedValue, val, 1);
				break;
			case BCS_Toxicity :			
				if(playerOwner)
					playerOwner.DrainToxicity(val);
				else
					LogAssert(false, "W3EffectManager.UpdateStatValueChange: trying to drain Toxicity points on non-player!");
				break;			
			case BCS_Focus :
				if(playerOwner)
					playerOwner.DrainFocus(val);
				else
					LogAssert(false, "W3EffectManager.UpdateStatValueChange: trying to drain Focus points on non-player!");
				break;
			case BCS_Morale :
				owner.DrainMorale(val);
				break;
			case BCS_Panic :
				owner.AddPanic(val);
				break;
			case BCS_Air :
				owner.DrainAir(val);
				break;
			case BCS_SwimmingStamina :
				owner.DrainSwimmingStamina(val);
				break;
			default:
				LogAssert(false, "W3EffectManager.UpdateStatValueChange: trying to drain invalid stat <<" + stat + ">>!");
				break;
		}
	}

	public final function HasEffect(effectType : EEffectType) : bool
	{
		var i,size : int;
		
		if(effectType != EET_Undefined)
		{
			size = effects.Size();
			for( i = 0; i < size; i += 1 )
			{
				if(effects[i] && effects[i].GetEffectType() == effectType)
					return true;
			}
		}
		
		return false;
	}

	public final function GetEffectTimePercentageByType(effectType : EEffectType) : int
	{
		var i, size : int;	
		
		if ( effectType != EET_Undefined )
		{
			size = effects.Size();
			for( i = 0; i < size; i += 1 )
				if( effects[i].GetEffectType() == effectType )
					return GetEffectTimePercentage(effects[i]);					
		}		
		return 0;
	}
	
	public final function GetEffectTimePercentage(buff : CBaseGameplayEffect) : int
	{
		var maxDur : float;
		
		if (buff)
		{
			maxDur = buff.GetInitialDurationAfterResists();
			if(maxDur > 0)
			{
				return RoundMath( 100.0f * buff.GetDurationLeft() / maxDur );
			}
			else if( maxDur <= -1 )
			{
				return 100;
			}
		}
		return 0;
	}

	
	public final function AddEffectsFromAction( action : W3DamageAction ) : bool
	{
		var i, size : int;
		var effectInfos : array< SEffectInfo >;
		var ret : EEffectInteract;
		var signProjectile : W3SignProjectile;
		var attackerPowerStatValue : SAbilityAttributeValue;
		var retB, applyBuff : bool;
		var signEntity : W3SignEntity;
		var canLog : bool;
		
		canLog = theGame.CanLog();
		size = action.GetEffects( effectInfos );
		signProjectile = (W3SignProjectile)action.causer;
		attackerPowerStatValue = action.GetPowerStatValue();
		retB = true;
		
		
		signEntity = (W3SignEntity)action.causer;
		if(!signEntity && signProjectile)
			signEntity = signProjectile.GetSignEntity();
			
		for( i = 0; i < size; i += 1 )
		{		
			if ( canLog )
			{
				LogDMHits("Trying to add buff <<" + effectInfos[i].effectType + ">> on target...", action);
			}
			
			
			if(signEntity)
			{
				applyBuff = GetSignApplyBuffTest(signEntity.GetSignType(), effectInfos[i].effectType, attackerPowerStatValue, signEntity.IsAlternateCast(), (CActor)action.attacker, action.GetBuffSourceName() );
			}
			else
			{
				applyBuff = GetNonSignApplyBuffTest(effectInfos[i].applyChance);
			}
			
			if(applyBuff)
			{
				
				ret = InternalAddEffect(effectInfos[i].effectType, action.attacker, action.GetBuffSourceName(), effectInfos[i].effectDuration, effectInfos[i].effectCustomValue, effectInfos[i].effectAbilityName, effectInfos[i].customFXName, signEntity, attackerPowerStatValue, effectInfos[i].effectCustomParam );
			}
			else
			{
				
				if( signEntity && signEntity.GetSignType() == ST_Aard )
				{
					
					ret = InternalAddEffect(EET_Stagger, action.attacker, action.GetBuffSourceName(), effectInfos[i].effectDuration, effectInfos[i].effectCustomValue, effectInfos[i].customFXName, effectInfos[i].effectAbilityName, signEntity, attackerPowerStatValue, effectInfos[i].effectCustomParam );
				}
			}
			
			if ( theGame.CanLog() )
			{
				if(ret == EI_Undefined)
				{
					retB = false;
					LogDMHits("... not valid effect!", action);
				}
				else if(!applyBuff)
					LogDMHits("... failed randomization test.", action);
				else if(ret == EI_Deny)
					LogDMHits("... denied.", action);
				else if(ret == EI_Override)
					LogDMHits("... overriden by other effect already on target.", action);
				else if(ret == EI_Pass)
					LogDMHits("... added.", action);
				else if(ret == EI_Cumulate)
					LogDMHits("... cumulated with existing effect on target.", action);			
			}
			else
			{
				if ( ret == EI_Undefined )
				{
					retB = false;
				}
			}
			
		}
		
		return retB;
	}
	
	
	private final function GetNonSignApplyBuffTest(applyChance : float) : bool
	{
		return RandF() < applyChance;
	}
	
	
	private final function GetSignApplyBuffTest(signType : ESignType, effectType : EEffectType, powerStatValue : SAbilityAttributeValue, isAlternate : bool, caster : CActor, sourceName : string ) : bool
	{
		var sp, res, chance, tempF : float;
		var chanceBonus : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;

		
		witcher = (W3PlayerWitcher)caster;
		if(witcher && witcher.GetPotionBuffLevel(EET_PetriPhiltre) == 3)
			return true;
	
		
		sp = powerStatValue.valueMultiplicative;
		owner.GetResistValue(theGame.effectMgr.GetBuffResistStat(effectType), tempF, res);
		chance = sp / theGame.params.MAX_SPELLPOWER_ASSUMED - res;
		
		if( signType == ST_Yrden || signType == ST_Axii || sourceName == "mutation11" )
		{
			chance = 1;
		}
		else if(signType == ST_Igni)
		{
			chance = ( 1 + LogF( sp ) ) / theGame.params.MAX_SPELLPOWER_ASSUMED - res; 
		
			if(witcher)
			{
				if(witcher.CanUseSkill(S_Magic_s09))
				{
					chanceBonus = witcher.GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, true);
					chance += chance * chanceBonus.valueMultiplicative * witcher.GetSkillLevel(S_Magic_s09) + chanceBonus.valueAdditive * witcher.GetSkillLevel(S_Magic_s09);
				}			
				if(witcher.CanUseSkill(S_Perk_03))
					chance += CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'burning_chance', false, true));
			}
		}
		else if(signType == ST_Quen && effectType == EET_KnockdownTypeApplicator)
		{
			witcher = (W3PlayerWitcher)caster;
			if(witcher)
			{
				chanceBonus = witcher.GetSkillAttributeValue(S_Magic_s13, 'chance_multiplier', false, true);
				chance *= CalculateAttributeValue(chanceBonus);
			}
			if( owner.HasAbility('WeakToAard') )
			{
				chance = 1;
			}
		}
		else if( signType == ST_Aard && owner.HasAbility('WeakToAard') )
		{
			chance = 1;
		}
				
		chance = ClampF(chance, 0, 1);
			
		LogEffects("Buff <<" + effectType + ">> is from sign, chance = " + NoTrailZeros(100*chance) + "%, spell_power = " + NoTrailZeros(sp) + ", resist=" + NoTrailZeros(res));		
		if(RandF() >= chance)
		{
			if ( theGame.CanLog() )
			{
				LogEffects("Sign buff chance failed - no effect applied");
			}
			return false;
		}
		else
		{
			LogEffects("Sign buff chance succeeded!");
		}
		
		return true;
	}
	
	
	public final function ProcessOnHitEffects(victim : CActor, silverSword : bool, steelSword : bool, sign : bool)
	{
		var i : int;
		var applicator : W3Effect_ApplicatorOnHit;
	
		for(i=0; i<effects.Size(); i+=1)
		{
			applicator = (W3Effect_ApplicatorOnHit)effects[i];
			if(applicator)
			{
				applicator.ProcessOnHit(victim, silverSword, steelSword, sign);
			}
		}
	}
	
	
	
	
	public final function PauseEffects(effectType : EEffectType, sourceName : name, optional singleLock : bool, optional duration : float, optional useMaxDuration : bool)
	{
		var i : int;
		var pausedAnyBuff : bool;
		var pause : SPausedAutoEffect;
	
		
		if(duration == 0)
			duration = -1;
			
		
		for(i=0; i<effects.Size(); i+=1)
		{
			if(effects[i].GetEffectType() == effectType)
			{	
				PauseEffect(effects[i], sourceName, singleLock, duration,useMaxDuration);
				pausedAnyBuff = true;
			}
		}
		
		
		if(!pausedAnyBuff && IsBuffAutoBuff(effectType))
		{
			pause.effectType = effectType;
			pause.sourceName = sourceName;
			pause.singleLock = singleLock;
			pause.duration = duration;
			pause.useMaxDuration = useMaxDuration;
			pause.timeLeft = duration;
			
			pausedNotAppliedAutoBuffs.PushBack(pause);
		}
	}
	
	
	
	private final function PauseEffect(buff : CBaseGameplayEffect, sourceName : name, optional singleLock : bool, optional duration : float, optional useMaxDuration : bool)
	{
		var tpe : STemporarilyPausedEffect;
		var j : int;
		var processed : bool;
		
		processed = false;
		
		
		for(j=0; j<pausedEffects.Size(); j+=1)
		{
			if(pausedEffects[j].buff == buff && pausedEffects[j].source == sourceName)
			{
				
				if(duration > 0)
				{
					
					if(useMaxDuration)
						pausedEffects[j].timeLeft = MaxF(pausedEffects[j].timeLeft, duration);
					else 
						pausedEffects[j].timeLeft = duration;
				}
				else if(pausedEffects[j].timeLeft >= 0)
				{
					
					pausedEffects[j].timeLeft = -1;
				}
				
				processed = true;
				buff = pausedEffects[j].buff;
				break;
			}
		}
		
		
		if(!processed)
		{
			tpe.buff = buff;	
			tpe.timeLeft = duration;
			tpe.duration = duration;
			tpe.source = sourceName;
			tpe.singleLock = singleLock;
			tpe.useMaxDuration = useMaxDuration;
		
			pausedEffects.PushBack(tpe);			
		}
		
		buff.Pause(sourceName, singleLock);
	}

	public final function PauseAllRegenEffects(sourceName : name, optional singleLock : bool, optional duration : float, optional useMaxDuration : bool)
	{
		var i : int;
		var regenEffect : W3RegenEffect;
	
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
				PauseEffects(regenEffect.GetEffectType(), sourceName, singleLock, duration, useMaxDuration);
		}
	}
	
	public final function ResumeAllRegenEffects(sourceName : name)
	{
		var i : int;
		var regenEffect : W3RegenEffect;
	
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
				ResumeEffects(regenEffect.GetEffectType(), sourceName);
		}
	}
	
	
	private final function ResumeAllBuffsForced()
	{
		var i : int;
	
		for(i=0; i<effects.Size(); i+=1)
		{
			ResumeEffectsInternal(effects[i].GetEffectType(), '', true);
		}
	}
	
	public final function PauseHPRegenEffects(sourceName : name, optional duration : float)
	{		
		var i : int;
		var regenEffect : W3RegenEffect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
			{
				if(regenEffect.GetRegenStat() == CRS_Vitality || regenEffect.GetRegenStat() == CRS_Essence)
				{
					PauseEffects(effects[i].GetEffectType(), sourceName, true, duration);
				}
			}
		}
	}
	
	public final function PauseStaminaRegen(sourceName : name, optional duration : float)
	{
		var i : int;
		var regenEffect : W3RegenEffect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
			{
				if(regenEffect.GetRegenStat() == CRS_Stamina)
				{
					PauseEffects(effects[i].GetEffectType(), sourceName, true, duration, true);
				}
			}
		}
	}
	
	public final function ResumeStaminaRegen(sourceName : name)
	{
		var i : int;
		var regenEffect : W3RegenEffect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
			{
				if(regenEffect.GetRegenStat() == CRS_Stamina)
				{
					ResumeEffects(effects[i].GetEffectType(), sourceName);
				}
			}
		}
	}
	
	public final function ResumeHPRegenEffects( sourceName : name, optional forceAll : bool )
	{		
		var i : int;
		var regenEffect : W3RegenEffect;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			regenEffect = (W3RegenEffect)effects[i];
			if(regenEffect)
			{
				if(regenEffect.GetRegenStat() == CRS_Vitality || regenEffect.GetRegenStat() == CRS_Essence)
				{
					ResumeEffects( effects[i].GetEffectType(), sourceName, forceAll );
				}
			}
		}
	}
	
	
	public final function ResumeEffects( effectType : EEffectType, sourceName : name, optional forced : bool )
	{
		ResumeEffectsInternal( effectType, sourceName, forced );
	}
	
	
	private final function ResumeEffectsInternal(effectType : EEffectType, optional sourceName : name, optional forced : bool)
	{
		var i, j : int;
		var removedOneLock : bool;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			if(effects[i].GetEffectType() == effectType && (forced || effects[i].IsPaused(sourceName)) )
			{
				if(forced)
					effects[i].ResumeForced();
				else
					effects[i].Resume(sourceName);
				
				
				for(j=0; j<pausedEffects.Size(); j+=1)
				{
					if(pausedEffects[j].buff == effects[i] && (forced || sourceName == pausedEffects[j].source) )
					{
						pausedEffects.EraseFast(j);
					}						
				}					
			}
		}
				
		
		removedOneLock = false;
		for(i=pausedNotAppliedAutoBuffs.Size()-1; i>=0; i-=1)
		{
			if(pausedNotAppliedAutoBuffs[i].effectType == effectType && (forced || pausedNotAppliedAutoBuffs[i].sourceName == sourceName) )
			{
				
				if(pausedNotAppliedAutoBuffs[i].singleLock)
				{
					pausedNotAppliedAutoBuffs.Erase(i);
					continue;
				}
				
				else if(!removedOneLock)
				{
					pausedNotAppliedAutoBuffs.Erase(i);
					removedOneLock = true;
					continue;
				}
			}
		}
	}
		
	
	public final function GetCriticalBuffsCount() : int
	{
		var i, cnt : int;
	
		cnt = 0;
		for(i=0; i<effects.Size(); i+=1)
			if(IsCriticalEffect(effects[i]))
				cnt += 1;
		
		return cnt;
	}
	
	public final function GetCriticalBuffs() : array<CBaseGameplayEffect>
	{
		var i : int;
		var ret : array<CBaseGameplayEffect>;
	
		for(i=0; i<effects.Size(); i+=1)
			if(IsCriticalEffect(effects[i]))
				ret.PushBack(effects[i]);
		
		return ret;
	}
	
	public final function HasPotionBuff() : bool
	{
		var i : int;
	
		for(i=0; i<effects.Size(); i+=1)
			if(effects[i].IsPotionEffect() && effects[i].IsActive())
				return true;
				
		return false;
	}
	
	
	public final function CacheStatUpdate(stat : EBaseCharacterStats, value : float)
	{
		if(value == 0)
		{
			LogAssert(false, "EffectManager.CacheStatUpdate: value is 0 for <<" + owner + ">> and stat <<" + stat + ">> !!!");
			return;
		}
		
		statDeltas[stat] += value;
		owner.SetEffectsUpdateTicking( true );
	}
	
	
	public final function CacheDamage(damageTypeName : name, val : float, attacker : CGameplayEntity, carrier : CBaseGameplayEffect, DoTdt : float, dontShowHitParticle : bool, pwrStatType : ECharacterPowerStats, isEnvironment : bool)
	{
		var dmg : SEffectCachedDamage;
		var eh : EntityHandle;
	
		if(val <= 0)
		{
			LogAssert(false, "EffectManager.CacheDamage: value is <= 0!");
			return;
		}
		
		EntityHandleSet(eh, attacker);
		
		dmg.dmgType = damageTypeName;
		dmg.dmgVal = val;
		dmg.attacker = eh;
		dmg.carrier = carrier;
		dmg.dt = DoTdt;
		dmg.dontShowHitParticle = dontShowHitParticle;
		dmg.powerStatType = pwrStatType;
		dmg.isEnvironment = isEnvironment;
		
		if(carrier)
			dmg.sourceName = carrier.GetSourceName();
			
		cachedDamages.PushBack(dmg);
		owner.SetEffectsUpdateTicking( true );
	}
	
	
	public final function RecalcEffectDurations()
	{
		var i : int;
		
		for(i=0; i<effects.Size(); i+=1)
			effects[i].RecalcDuration();
	}
	
	
	public final function GetPotionBuffLevel(effectType : EEffectType) : int
	{
		var buff : CBaseGameplayEffect;
		
		buff = GetEffect(effectType);
		
		if(buff && buff.IsPotionEffect())
			return buff.GetBuffLevel();
			
		return 0;
	}
	
	public final function CanBeRemoved() : bool
	{
		var i : int;
		
		if( effects.Size() > 0 )
		{
			return false; 
		}
	
		if( cachedDamages.Size() > 0 )
		{
			return false; 
		}
	
		for( i = 0; i < statDeltas.Size(); i += 1 )
		{
			if( statDeltas[ i ] != 0 )
			{
				return false; 
			}
		}
		
		
		for(i=0; i<pausedEffects.Size(); i+=1)
		{
			if(pausedEffects[i].duration != -1)
				return false;
		}
		
		
		for(i=0; i<pausedNotAppliedAutoBuffs.Size(); i+=1)
		{
			if(pausedNotAppliedAutoBuffs[i].duration != -1)
				return false;
		}
		
		return true;
	}
	
	public final function ShouldStopFx(fx : name) : bool
	{
		var i : int;
		
		for(i=0; i<currentlyPlayedFX.Size(); i+=1)
		{
			if(currentlyPlayedFX[i].fx == fx)
				return currentlyPlayedFX[i].sources.Size() == 1;	
		}
		
		
		return false;
	}
	
	public final function IsPlayingFX(fx : name) : bool
	{
		var i : int;
		
		for(i=0; i<currentlyPlayedFX.Size(); i+=1)
		{
			if(currentlyPlayedFX[i].fx == fx)
				return true;
		}
		
		return false;
	}
	
	public final function AddPlayedFX(fx : name, sourceName : string)
	{
		var i : int;
		var f : SCurrentBuffFX;
		
		for(i=0; i<currentlyPlayedFX.Size(); i+=1)
		{
			if(currentlyPlayedFX[i].fx == fx)
			{
				if(!currentlyPlayedFX[i].sources.Contains(sourceName))
					currentlyPlayedFX[i].sources.PushBack(sourceName);
					
				return;
			}
		}

		
		f.fx = fx;
		f.sources.PushBack(sourceName);
		
		currentlyPlayedFX.PushBack(f);
	}
	
	public final function RemovePlayedFX(fx : name, sourceName : string)
	{
		var i : int;
		
		for(i=0; i<currentlyPlayedFX.Size(); i+=1)
		{
			if(currentlyPlayedFX[i].fx == fx)
			{
				currentlyPlayedFX[i].sources.Remove(sourceName);
				
				if(currentlyPlayedFX[i].sources.Size() == 0)
					currentlyPlayedFX.EraseFast(i);
					
				return;
			}
		}
	}
	
	
	public final function SimulateBuffTimePassing(simulatedTime : float)
	{
		var i : int;
		
		for(i=effects.Size()-1; i>=0; i-=1)
		{
			
			if(owner == GetWitcherPlayer() && (W3RepairObjectEnhancement)effects[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats'))
			{
				effects[i].OnTimeUpdated(simulatedTime);
				continue;
			}
				
			if(effects[i].GetTimeLeft() != -1)
			{
				RemoveEffectOnIndex(i, true);
			}
		}
	}
	
	public final function Debug_ReleaseCriticalStateSaveLocks()
	{
		if(hasCriticalStateSaveLock)
			theGame.ReleaseNoSaveLock(criticalStateSaveLockId);
	}
	
	private final function CountShrineBuffs() : int
	{
		var i, doneBuffs : int;
		var type : EEffectType;
		
		doneBuffs = 0;
		for(i=0; i<effects.Size(); i+=1)
		{
			type = effects[i].GetEffectType();
			
			switch(type)
			{
				case EET_ShrineAard:
					doneBuffs += 1;
					break;
				case EET_ShrineAxii:
					doneBuffs += 1;
					break;
				case EET_ShrineIgni:
					doneBuffs += 1;
					break;
				case EET_ShrineQuen:
					doneBuffs += 1;
					break;
				case EET_ShrineYrden:
					doneBuffs += 1;
					break;					
				default:
					break;
			}			
		}

		return doneBuffs;
	}
	
	public final function HasAnyMutagen23ShrineBuff() : bool
	{
		var i : int;
		var shrineBuff : W3Effect_Shrine;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			shrineBuff = (W3Effect_Shrine) effects[i];
			if(shrineBuff && shrineBuff.IsFromMutagen23())
				return true;
		}
		
		return false;
	}
	
	public final function HasAnyShrineBuff() : bool
	{
		var i : int;
		var shrineBuff : W3Effect_Shrine;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			shrineBuff = (W3Effect_Shrine) effects[i];
			if(shrineBuff)
				return true;
		}
		
		return false;
	}
	
	public final function GetShrineBuffs() : array<CBaseGameplayEffect>
	{
		var i : int;
		var shrineBuff : W3Effect_Shrine;
		var ret : array<CBaseGameplayEffect>;
		
		for(i=0; i<effects.Size(); i+=1)
		{
			shrineBuff = (W3Effect_Shrine) effects[i];
			if(shrineBuff)
				ret.PushBack(effects[i]);
		}
		
		return ret;
	}
}
